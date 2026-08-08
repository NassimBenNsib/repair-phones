// AP1 — comptabilité fournisseur : règlements sur commande (payé / reste dû),
// plafonnement au solde, persistance et suppression.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart'
    show PaymentMethod;
import 'package:atelier_reparation/features/orders/application/orders_controller.dart';
import 'package:atelier_reparation/features/orders/domain/purchase_order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container() {
  final c = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
  addTearDown(c.dispose);
  return c;
}

PurchaseOrder _seed(OrdersController ctrl, {double unitPrice = 100}) {
  final po = ctrl.create('s1');
  ctrl.addLine(po.id,
      LineItem(id: 'l1', label: 'Écran', qty: 1, unitPrice: unitPrice));
  ctrl.update(ctrl.byId(po.id)!.copyWith(status: PoStatus.ordered));
  return ctrl.byId(po.id)!;
}

void main() {
  test('balanceDue / amountPaid / isPaid', () {
    final o = PurchaseOrder(
      id: 'o1',
      number: 'CMD1',
      supplierId: 's1',
      status: PoStatus.received,
      date: DateTime(2026, 1, 1),
      taxRate: 0,
      lines: const [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)],
    );
    expect(o.amountPaid, 0);
    expect(o.balanceDue, 100);
    expect(o.isPaid, isFalse);
  });

  test('addPayment réduit le solde et plafonne au reste dû', () {
    final c = _container();
    final ctrl = c.read(ordersProvider.notifier);
    final po = _seed(ctrl); // total 120 TTC (100 + 20%)

    ctrl.addPayment(po.id, 50, method: PaymentMethod.card);
    expect(ctrl.byId(po.id)!.amountPaid, closeTo(50, 1e-9));
    expect(ctrl.byId(po.id)!.balanceDue, closeTo(70, 1e-9));
    expect(ctrl.byId(po.id)!.isPaid, isFalse);

    // Trop-perçu → plafonné au solde restant (70).
    ctrl.addPayment(po.id, 999);
    final o = ctrl.byId(po.id)!;
    expect(o.amountPaid, closeTo(120, 1e-9));
    expect(o.balanceDue, closeTo(0, 1e-9));
    expect(o.isPaid, isTrue);
  });

  test('montant nul/négatif ignoré ; solde nul → aucun règlement', () {
    final c = _container();
    final ctrl = c.read(ordersProvider.notifier);
    final po = _seed(ctrl);
    ctrl.addPayment(po.id, 0);
    ctrl.addPayment(po.id, -10);
    expect(ctrl.byId(po.id)!.payments, isEmpty);
  });

  test('removePayment retire le règlement ; persistance au rechargement', () {
    final c = _container();
    final ctrl = c.read(ordersProvider.notifier);
    final po = _seed(ctrl);
    ctrl.addPayment(po.id, 30);
    final payId = ctrl.byId(po.id)!.payments.single.id;

    // Persisté dans le stockage.
    final reloaded = c
        .read(orderStoreProvider)
        .loadAll()
        .firstWhere((x) => x.id == po.id);
    expect(reloaded.amountPaid, closeTo(30, 1e-9));

    ctrl.removePayment(po.id, payId);
    expect(ctrl.byId(po.id)!.payments, isEmpty);
  });
}
