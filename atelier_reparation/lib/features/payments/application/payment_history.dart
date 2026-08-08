import '../../clients/domain/client_payment.dart';
import '../../invoices/domain/invoice.dart';

/// Nature d'une écriture du journal complet des paiements.
enum LedgerKind { invoicePayment, deposit, application, refund }

/// Écriture unifiée : paiement de facture ou mouvement de compte client.
class LedgerEntry {
  const LedgerEntry({
    required this.kind,
    required this.date,
    required this.amount,
    required this.method,
    required this.clientId,
    required this.clientName,
    this.invoiceId,
    this.invoiceNumber,
  });

  final LedgerKind kind;
  final DateTime date;
  final double amount; // magnitude positive
  final PaymentMethod method;
  final String clientId;
  final String clientName;
  final String? invoiceId;
  final String? invoiceNumber;

  /// Contribution à la trésorerie nette (encaissements réels, hors interne).
  ///
  /// Les paiements de facture « par avoir » sont exclus **avant** construction
  /// (déjà représentés par l'acompte) ; l'application de crédit est interne → 0.
  double get cash => switch (kind) {
        LedgerKind.invoicePayment => amount,
        LedgerKind.deposit => amount,
        LedgerKind.refund => -amount,
        LedgerKind.application => 0,
      };

  bool get isCashOut => kind == LedgerKind.refund;
  bool get isInternal => kind == LedgerKind.application;
}

/// Trésorerie nette d'un ensemble d'écritures.
double netCash(Iterable<LedgerEntry> entries) =>
    entries.fold<double>(0, (s, e) => s + e.cash);

/// Journal complet des paiements : encaissements de factures (hors « avoir ») +
/// mouvements de compte client (acomptes / avoirs appliqués / remboursements).
/// Filtrable par [clientId]. Trié du plus récent au plus ancien.
List<LedgerEntry> buildPaymentHistory({
  required List<Invoice> invoices,
  required List<ClientPayment> clientPayments,
  Map<String, String> clientNames = const {},
  String? clientId,
}) {
  final out = <LedgerEntry>[];

  for (final inv in invoices) {
    for (final p in inv.payments) {
      // Réglé par avoir → financé par un acompte déjà compté : exclu.
      if (p.method == PaymentMethod.credit) continue;
      out.add(LedgerEntry(
        kind: LedgerKind.invoicePayment,
        date: p.date,
        amount: p.amount,
        method: p.method,
        clientId: inv.clientId,
        clientName: inv.clientName,
        invoiceId: inv.id,
        invoiceNumber: inv.number,
      ));
    }
  }

  for (final cp in clientPayments) {
    final kind = switch (cp.kind) {
      ClientPaymentKind.deposit => LedgerKind.deposit,
      ClientPaymentKind.application => LedgerKind.application,
      ClientPaymentKind.refund => LedgerKind.refund,
    };
    out.add(LedgerEntry(
      kind: kind,
      date: cp.date,
      amount: cp.amount,
      method: cp.method,
      clientId: cp.clientId,
      clientName: clientNames[cp.clientId] ?? '',
      invoiceId: cp.invoiceId,
    ));
  }

  final filtered =
      clientId == null ? out : out.where((e) => e.clientId == clientId).toList();
  filtered.sort((a, b) => b.date.compareTo(a.date));
  return filtered;
}
