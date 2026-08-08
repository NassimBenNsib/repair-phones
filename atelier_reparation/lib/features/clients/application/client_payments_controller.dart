import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/domain/invoice.dart';
import '../data/client_payment_mapper.dart';
import '../domain/client_payment.dart';

final clientPaymentStoreProvider = Provider<CollectionStore<ClientPayment>>(
  (ref) => CollectionStore<ClientPayment>(
      ref.watch(localStoreProvider), ClientPaymentMapper()),
);

/// Grand-livre « compte client » (acomptes / avoirs) et son application aux
/// factures. Les acomptes ne deviennent du chiffre d'affaires qu'à l'application
/// (qui crée un paiement de facture réel via [InvoicesController.addPayment]).
class ClientPaymentsController extends Notifier<List<ClientPayment>> {
  CollectionStore<ClientPayment> get _store =>
      ref.read(clientPaymentStoreProvider);
  int _seq = 0;

  @override
  List<ClientPayment> build() => _store.loadAll();

  String _id() => 'cpay-${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  /// Crédit disponible du client.
  double creditOf(String clientId) => availableCredit(clientId, state);

  void _add(ClientPayment e) {
    _store.upsert(e);
    state = [e, ...state];
  }

  /// Enregistre un acompte reçu sur le compte (crédit +).
  void addDeposit(String clientId, double amount, PaymentMethod method,
      {String? note}) {
    if (amount <= 0) return;
    _add(ClientPayment(
      id: _id(),
      clientId: clientId,
      date: DateTime.now(),
      amount: amount,
      kind: ClientPaymentKind.deposit,
      method: method,
      note: note,
    ));
  }

  /// Rembourse du crédit au client (sortie de trésorerie, crédit −).
  /// Plafonné au crédit disponible. Renvoie le montant remboursé.
  double refund(String clientId, double amount, PaymentMethod method) {
    final avail = creditOf(clientId);
    final take = amount < avail ? amount : avail;
    if (take <= 0.005) return 0;
    _add(ClientPayment(
      id: _id(),
      clientId: clientId,
      date: DateTime.now(),
      amount: take,
      kind: ClientPaymentKind.refund,
      method: method,
    ));
    return take;
  }

  /// Applique le crédit disponible aux factures émises dues (plus anciennes
  /// d'abord). Renvoie le total appliqué.
  double applyCredit(String clientId) {
    var credit = creditOf(clientId);
    if (credit <= 0.005) return 0;
    final invCtrl = ref.read(invoicesProvider.notifier);
    final due = ref
        .read(invoicesProvider)
        .where((i) =>
            i.clientId == clientId && i.isIssued && i.balanceDue > 0.005)
        .toList()
      ..sort((a, b) => (a.issueDate ?? a.date).compareTo(b.issueDate ?? b.date));

    final now = DateTime.now();
    var applied = 0.0;
    for (final inv in due) {
      if (credit <= 0.005) break;
      final take = credit < inv.balanceDue ? credit : inv.balanceDue;
      // Règle la facture (devient encaissé/CA à cet instant).
      invCtrl.addPayment(
        inv.id,
        Payment(
          id: 'cr-${now.microsecondsSinceEpoch}_$_seq',
          date: now,
          amount: take,
          method: PaymentMethod.credit,
        ),
      );
      // Écriture d'application (crédit −).
      _add(ClientPayment(
        id: _id(),
        clientId: clientId,
        date: now,
        amount: take,
        kind: ClientPaymentKind.application,
        method: PaymentMethod.credit,
        invoiceId: inv.id,
      ));
      credit -= take;
      applied += take;
    }
    return applied;
  }
}

final clientPaymentsProvider =
    NotifierProvider<ClientPaymentsController, List<ClientPayment>>(
        ClientPaymentsController.new);
