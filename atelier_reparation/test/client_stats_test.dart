import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/clients/application/client_stats.dart';
import 'package:atelier_reparation/features/clients/domain/client.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:atelier_reparation/features/quotes/domain/quote.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:flutter_test/flutter_test.dart';

const _client = Client(id: 'c1', name: 'Sofia', phone: '1');

Invoice _inv({
  required String number,
  required String clientId,
  double unitPrice = 100,
  List<Payment> payments = const [],
  DateTime? issueDate,
}) =>
    Invoice(
      id: 'i-$number',
      number: number,
      clientId: clientId,
      clientName: 'Sofia',
      status: InvoiceStatus.issued,
      date: DateTime(2026, 1, 1),
      issueDate: issueDate ?? DateTime(2026, 6, 1),
      lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: unitPrice)],
      payments: payments,
      taxRate: 0.20,
    );

void main() {
  test('aggregates invoiced/collected/outstanding for the client only', () {
    final invoices = [
      _inv(number: 'F1', clientId: 'c1', payments: [
        Payment(id: 'p', date: DateTime(2026, 6, 5), amount: 50),
      ]),
      // Draft (no number) → excluded from money totals but still listed.
      _inv(number: '', clientId: 'c1'),
      // Another client → excluded entirely.
      _inv(number: 'F9', clientId: 'other'),
    ];
    final quotes = [
      Quote(
          id: 'q1',
          number: 'D1',
          clientId: 'c1',
          clientName: 'Sofia',
          status: QuoteStatus.accepted,
          date: DateTime(2026, 7, 1)),
      Quote(
          id: 'q2',
          number: 'D2',
          clientId: 'other',
          clientName: 'X',
          date: DateTime(2026, 7, 2)),
    ];

    final s = computeClientStats(_client,
        invoices: invoices, quotes: quotes, repairs: const []);

    expect(s.invoiceCount, 2); // F1 + draft (client's)
    expect(s.invoicedTotal, closeTo(120, 1e-9)); // only issued F1 (100 + 20%)
    expect(s.collected, closeTo(50, 1e-9));
    expect(s.outstanding, closeTo(70, 1e-9));
    expect(s.quoteCount, 1);
    expect(s.acceptedQuotes, 1);
    expect(s.lastActivity, DateTime(2026, 7, 1)); // most recent quote date
  });

  test('repairs match by clientId, else by label fallback', () {
    final repairs = [
      Repair(
        reference: '#R-1',
        device: 'iPhone',
        kind: DeviceKind.phone,
        client: 'Sofia', // no clientId → label fallback
        status: RepairStatus.inProgress,
        priority: RepairPriority.normal,
        progress: 0,
        updatedLabel: '',
        hoursAgo: 1,
      ),
      Repair(
        reference: '#R-2',
        device: 'iPad',
        kind: DeviceKind.tablet,
        client: 'Someone else',
        clientId: 'c1', // explicit id wins
        status: RepairStatus.completed,
        priority: RepairPriority.normal,
        progress: 1,
        updatedLabel: '',
        hoursAgo: 2,
      ),
    ];
    final s = computeClientStats(_client,
        invoices: const [], quotes: const [], repairs: repairs);
    expect(s.repairCount, 2);
  });
}
