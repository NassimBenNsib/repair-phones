import '../../invoices/domain/invoice.dart';
import '../../quotes/domain/quote.dart';
import '../../repairs/domain/repair.dart';
import '../domain/client.dart';

/// Synthèse par client : historiques liés + agrégats financiers. Pure (testable).
class ClientStats {
  const ClientStats({
    required this.invoices,
    required this.quotes,
    required this.repairs,
    required this.invoicedTotal,
    required this.collected,
    required this.outstanding,
    required this.acceptedQuotes,
    required this.lastActivity,
  });

  final List<Invoice> invoices; // émises + brouillons, récentes d'abord
  final List<Quote> quotes;
  final List<Repair> repairs;

  final double invoicedTotal; // TTC des factures émises
  final double collected; // encaissé sur les factures émises
  final double outstanding; // reste dû sur les factures émises
  final int acceptedQuotes;
  final DateTime? lastActivity;

  int get invoiceCount => invoices.length;
  int get quoteCount => quotes.length;
  int get repairCount => repairs.length;
}

DateTime? _maxDate(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isAfter(b) ? a : b;
}

/// Calcule la synthèse d'un [client] à partir des collections globales.
/// Les factures/devis sont reliés par `clientId` ; les réparations par
/// `clientId` avec repli sur le libellé (données héritées).
ClientStats computeClientStats(
  Client client, {
  required List<Invoice> invoices,
  required List<Quote> quotes,
  required List<Repair> repairs,
}) {
  final id = client.id;

  final cInvoices = invoices.where((i) => i.clientId == id).toList()
    ..sort((a, b) =>
        (b.issueDate ?? b.date).compareTo(a.issueDate ?? a.date));
  final cQuotes = quotes.where((q) => q.clientId == id).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  final cRepairs = repairs
      .where((r) =>
          r.clientId != null ? r.clientId == id : client.matchesLabel(r.client))
      .toList()
    ..sort((a, b) => a.hoursAgo.compareTo(b.hoursAgo));

  final issued = cInvoices.where((i) => i.isIssued);
  final invoicedTotal = issued.fold<double>(0, (s, i) => s + i.totals.total);
  final collected = issued.fold<double>(0, (s, i) => s + i.amountPaid);
  final outstanding = issued.fold<double>(0, (s, i) => s + i.balanceDue);
  final accepted =
      cQuotes.where((q) => q.status == QuoteStatus.accepted).length;

  DateTime? last;
  for (final i in cInvoices) {
    last = _maxDate(last, i.issueDate ?? i.date);
  }
  for (final q in cQuotes) {
    last = _maxDate(last, q.date);
  }
  for (final r in cRepairs) {
    last = _maxDate(last, r.completedAt ?? r.createdAt);
  }

  return ClientStats(
    invoices: cInvoices,
    quotes: cQuotes,
    repairs: cRepairs,
    invoicedTotal: invoicedTotal,
    collected: collected,
    outstanding: outstanding,
    acceptedQuotes: accepted,
    lastActivity: last,
  );
}
