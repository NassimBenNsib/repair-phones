import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/cheques/application/cheques_controller.dart';
import 'package:atelier_reparation/features/cheques/domain/cheque.dart';
import 'package:atelier_reparation/features/invoices/application/invoices_controller.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container() => ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())],
    );

void main() {
  test('bounce reverses the invoice payment and reopens the balance', () {
    final c = _container();
    addTearDown(c.dispose);

    // Issued invoice of 120 TTC.
    final inv = c.read(invoicesProvider.notifier).createFrom(
      clientId: 'c1',
      clientName: 'X',
      lines: [const LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)],
      taxRate: 0.20,
    );
    c.read(invoicesProvider.notifier).issue(inv.id);

    // Pay it by cheque.
    final payment = Payment(
        id: 'pay1',
        date: DateTime(2026, 6, 1),
        amount: 120,
        method: PaymentMethod.check);
    c.read(invoicesProvider.notifier).addPayment(inv.id, payment);

    final cheque = Cheque(
      id: 'chq1',
      invoiceId: inv.id,
      clientId: 'c1',
      clientName: 'X',
      paymentId: payment.id,
      amount: 120,
      receivedDate: DateTime(2026, 6, 1),
    );
    c.read(chequesProvider.notifier).add(cheque);

    // Invoice is paid.
    expect(c.read(invoicesProvider).single.status, InvoiceStatus.paid);
    expect(c.read(invoicesProvider).single.balanceDue, closeTo(0, 1e-9));

    // Cheque bounces → payment reversed, invoice reopens.
    c.read(chequesProvider.notifier).bounce('chq1');

    final after = c.read(invoicesProvider).single;
    expect(after.balanceDue, closeTo(120, 1e-9));
    expect(after.status, InvoiceStatus.issued);
    expect(c.read(chequesProvider).single.status, ChequeStatus.bounced);
  });

  test('advancing status: pending → deposited → cleared keeps invoice paid', () {
    final c = _container();
    addTearDown(c.dispose);
    final ctrl = c.read(chequesProvider.notifier);
    ctrl.add(Cheque(
        id: 'chq2', amount: 50, receivedDate: DateTime(2026, 1, 1)));

    ctrl.setStatus('chq2', ChequeStatus.deposited);
    expect(c.read(chequesProvider).single.status, ChequeStatus.deposited);
    expect(c.read(chequesProvider).single.depositDate, isNotNull);

    ctrl.setStatus('chq2', ChequeStatus.cleared);
    expect(c.read(chequesProvider).single.status, ChequeStatus.cleared);
  });
}
