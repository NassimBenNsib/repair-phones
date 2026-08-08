import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/accounting/application/accounting_summary.dart';
import 'package:atelier_reparation/features/clients/application/client_payments_controller.dart';
import 'package:atelier_reparation/features/clients/domain/client_payment.dart';
import 'package:atelier_reparation/features/invoices/application/invoices_controller.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container() => ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())],
    );

void main() {
  test('availableCredit sums signed ledger entries', () {
    final ledger = [
      ClientPayment(
          id: '1',
          clientId: 'c1',
          date: DateTime(2026),
          amount: 100,
          kind: ClientPaymentKind.deposit),
      ClientPayment(
          id: '2',
          clientId: 'c1',
          date: DateTime(2026),
          amount: 30,
          kind: ClientPaymentKind.application),
      ClientPayment(
          id: '3',
          clientId: 'c1',
          date: DateTime(2026),
          amount: 10,
          kind: ClientPaymentKind.refund),
      // Other client → ignored.
      ClientPayment(
          id: '4',
          clientId: 'other',
          date: DateTime(2026),
          amount: 500,
          kind: ClientPaymentKind.deposit),
    ];
    expect(availableCredit('c1', ledger), closeTo(60, 1e-9));
  });

  test('deposit is NOT revenue; applying credit settles invoice AND recognises it',
      () {
    final c = _container();
    addTearDown(c.dispose);
    final year = DateTime.now().year;

    // An issued invoice of 120 TTC for client c1.
    final inv = c.read(invoicesProvider.notifier).createFrom(
      clientId: 'c1',
      clientName: 'X',
      lines: [const LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)],
      taxRate: 0.20,
    );
    c.read(invoicesProvider.notifier).issue(inv.id);

    final cp = c.read(clientPaymentsProvider.notifier);
    cp.addDeposit('c1', 200, PaymentMethod.cash);
    expect(cp.creditOf('c1'), closeTo(200, 1e-9));

    // Accounting BEFORE applying: the deposit is not collected revenue.
    expect(computeYearSummary(c.read(invoicesProvider), year).collected,
        closeTo(0, 1e-9));

    // Apply credit → the invoice is settled from the 120 due.
    final applied = cp.applyCredit('c1');
    expect(applied, closeTo(120, 1e-9));
    expect(cp.creditOf('c1'), closeTo(80, 1e-9)); // 200 - 120

    final settled =
        c.read(invoicesProvider).firstWhere((i) => i.id == inv.id);
    expect(settled.balanceDue, closeTo(0, 1e-9));
    expect(settled.status, InvoiceStatus.paid);

    // Accounting AFTER applying: now recognised as collected.
    expect(computeYearSummary(c.read(invoicesProvider), year).collected,
        closeTo(120, 1e-9));
  });

  test('refund reduces credit, capped at available, and is cash-out', () {
    final c = _container();
    addTearDown(c.dispose);
    final cp = c.read(clientPaymentsProvider.notifier);
    cp.addDeposit('c1', 100, PaymentMethod.cash);

    // Refund more than available → capped to 100.
    final refunded = cp.refund('c1', 500, PaymentMethod.cash);
    expect(refunded, closeTo(100, 1e-9));
    expect(cp.creditOf('c1'), closeTo(0, 1e-9));
  });

  test('settleClient clears every outstanding invoice of the client', () {
    final c = _container();
    addTearDown(c.dispose);
    final ctrl = c.read(invoicesProvider.notifier);
    for (var i = 0; i < 3; i++) {
      final inv = ctrl.createFrom(
        clientId: 'c1',
        clientName: 'X',
        lines: [const LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 50)],
        taxRate: 0.20,
      );
      ctrl.issue(inv.id);
    }
    final total = ctrl.settleClient('c1', PaymentMethod.cash);
    expect(total, closeTo(180, 1e-9)); // 3 × 60 TTC
    expect(
        c.read(invoicesProvider).where((i) => i.balanceDue > 0.005).isEmpty,
        isTrue);
  });
}
