import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/clients/domain/client_payment.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:atelier_reparation/features/payments/application/payment_history.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _inv(String clientId, List<Payment> payments) => Invoice(
      id: 'i-$clientId-${payments.length}',
      number: 'FACT-1',
      clientId: clientId,
      clientName: 'C',
      status: InvoiceStatus.issued,
      date: DateTime(2026, 1, 1),
      issueDate: DateTime(2026, 1, 1),
      lines: const [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)],
      payments: payments,
      taxRate: 0.20,
    );

void main() {
  test('net cash = cash-in − refunds, excluding credit-funded invoice payments',
      () {
    final invoices = [
      _inv('c1', [
        Payment(id: 'p1', date: DateTime(2026, 6, 1), amount: 60), // cash
        Payment(
            id: 'p2',
            date: DateTime(2026, 6, 2),
            amount: 60,
            method: PaymentMethod.credit), // funded by deposit → excluded
      ]),
    ];
    final ledger = [
      ClientPayment(
          id: 'd1',
          clientId: 'c1',
          date: DateTime(2026, 5, 1),
          amount: 200,
          kind: ClientPaymentKind.deposit), // cash-in
      ClientPayment(
          id: 'a1',
          clientId: 'c1',
          date: DateTime(2026, 6, 2),
          amount: 60,
          kind: ClientPaymentKind.application), // internal → 0
      ClientPayment(
          id: 'r1',
          clientId: 'c1',
          date: DateTime(2026, 7, 1),
          amount: 30,
          kind: ClientPaymentKind.refund), // cash-out
    ];

    final entries =
        buildPaymentHistory(invoices: invoices, clientPayments: ledger);

    // The credit-funded invoice payment is not listed.
    expect(entries.where((e) => e.kind == LedgerKind.invoicePayment).length, 1);
    expect(entries.length, 4); // 1 invoice payment + deposit + application + refund
    // Net cash = 60 (invoice) + 200 (deposit) − 30 (refund) + 0 (application).
    expect(netCash(entries), closeTo(230, 1e-9));
    // Sorted most-recent first.
    expect(entries.first.date, DateTime(2026, 7, 1));
  });

  test('filters by clientId', () {
    final invoices = [
      _inv('c1', [Payment(id: 'p', date: DateTime(2026, 6, 1), amount: 10)]),
      _inv('c2', [Payment(id: 'q', date: DateTime(2026, 6, 1), amount: 99)]),
    ];
    final entries = buildPaymentHistory(
        invoices: invoices, clientPayments: const [], clientId: 'c1');
    expect(entries.length, 1);
    expect(entries.single.amount, 10);
  });
}
