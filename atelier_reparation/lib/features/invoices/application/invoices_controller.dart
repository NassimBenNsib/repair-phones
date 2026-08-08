import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/numbering.dart';
import '../data/invoice_mapper.dart';
import '../domain/invoice.dart';

final invoiceStoreProvider = Provider<CollectionStore<Invoice>>(
  (ref) =>
      CollectionStore<Invoice>(ref.watch(localStoreProvider), InvoiceMapper()),
);

/// Factures, adossées au stockage local.
class InvoicesController extends Notifier<List<Invoice>> {
  CollectionStore<Invoice> get _store => ref.read(invoiceStoreProvider);
  int _seq = 0;

  @override
  List<Invoice> build() => _store.loadAll();

  String _id() => 'f-${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  /// Crée une facture brouillon (numéro attribué plus tard, à l'émission).
  Invoice create({required String clientId, required String clientName}) =>
      createFrom(clientId: clientId, clientName: clientName);

  /// Crée une facture brouillon à partir de lignes existantes (devis/réparation).
  Invoice createFrom({
    required String clientId,
    required String clientName,
    List<LineItem> lines = const [],
    String? quoteId,
    String? repairId,
    double discount = 0,
    double taxRate = 0.20,
    double deposit = 0,
  }) {
    final inv = Invoice(
      id: _id(),
      clientId: clientId,
      clientName: clientName,
      quoteId: quoteId,
      repairId: repairId,
      date: DateTime.now(),
      lines: lines,
      discount: discount,
      taxRate: taxRate,
      deposit: deposit,
    );
    _store.upsert(inv);
    state = [inv, ...state];
    return inv;
  }

  void update(Invoice i) {
    _store.upsert(i);
    state = [for (final x in state) if (x.id == i.id) i else x];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final x in state) if (x.id != id) x];
  }

  Invoice? byId(String id) {
    for (final i in state) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// Émet la facture : attribue le numéro légal séquentiel (immuable) et
  /// verrouille les lignes.
  void issue(String id) {
    final i = byId(id);
    if (i == null || i.isIssued) return;
    final number = ref.read(numberingProvider).next('FACT', DateTime.now().year);
    final now = DateTime.now();
    update(i.copyWith(
      number: number,
      status: InvoiceStatus.issued,
      issueDate: now,
      dueDate: now.add(const Duration(days: 30)),
    ));
  }

  void addLine(String id, LineItem line) {
    final i = byId(id);
    if (i != null) update(i.copyWith(lines: [...i.lines, line]));
  }

  void updateLine(String id, LineItem line) {
    final i = byId(id);
    if (i == null) return;
    update(i.copyWith(
        lines: [for (final l in i.lines) if (l.id == line.id) line else l]));
  }

  void removeLine(String id, String lineId) {
    final i = byId(id);
    if (i == null) return;
    update(i.copyWith(lines: [for (final l in i.lines) if (l.id != lineId) l]));
  }

  /// Enregistre un paiement puis recalcule le statut (partiel/payée).
  void addPayment(String id, Payment payment) {
    final i = byId(id);
    if (i == null) return;
    final payments = [...i.payments, payment];
    final withPayment = i.copyWith(payments: payments);
    final status = withPayment.balanceDue <= 0.005
        ? InvoiceStatus.paid
        : InvoiceStatus.partial;
    update(withPayment.copyWith(status: status));
  }

  void setStatus(String id, InvoiceStatus status) {
    final i = byId(id);
    if (i != null) update(i.copyWith(status: status));
  }

  /// Retire un paiement (ex. chèque rejeté) et rouvre le solde de la facture.
  void removePayment(String id, String paymentId) {
    final i = byId(id);
    if (i == null) return;
    final payments = [for (final p in i.payments) if (p.id != paymentId) p];
    final without = i.copyWith(payments: payments);
    final status = without.amountPaid <= 0.005
        ? InvoiceStatus.issued
        : (without.balanceDue <= 0.005
            ? InvoiceStatus.paid
            : InvoiceStatus.partial);
    update(without.copyWith(status: status));
  }

  /// Solde toutes les factures émises non réglées d'un client avec [method].
  /// Renvoie le total encaissé. Réutilise [addPayment] (statut mis à jour).
  double settleClient(String clientId, PaymentMethod method, {DateTime? at}) {
    final now = at ?? DateTime.now();
    var seq = 0;
    var total = 0.0;
    for (final i in [...state]) {
      if (i.clientId != clientId || !i.isIssued) continue;
      final due = i.balanceDue;
      if (due <= 0.005) continue;
      addPayment(
        i.id,
        Payment(
          id: 'cp-${now.microsecondsSinceEpoch}_${seq++}',
          date: now,
          amount: due,
          method: method,
        ),
      );
      total += due;
    }
    return total;
  }
}

final invoicesProvider =
    NotifierProvider<InvoicesController, List<Invoice>>(InvoicesController.new);
