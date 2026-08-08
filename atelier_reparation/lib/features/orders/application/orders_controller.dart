import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/numbering.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../invoices/domain/invoice.dart' show Payment, PaymentMethod;
import '../data/order_mapper.dart';
import '../domain/purchase_order.dart';

final orderStoreProvider = Provider<CollectionStore<PurchaseOrder>>(
  (ref) =>
      CollectionStore<PurchaseOrder>(ref.watch(localStoreProvider), OrderMapper()),
);

/// Commandes fournisseurs, adossées au stockage local.
class OrdersController extends Notifier<List<PurchaseOrder>> {
  CollectionStore<PurchaseOrder> get _store => ref.read(orderStoreProvider);
  int _seq = 0;

  @override
  List<PurchaseOrder> build() => _store.loadAll();

  String _id() => 'po-${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  /// Crée une commande brouillon avec un numéro attribué.
  PurchaseOrder create(String supplierId) {
    final number =
        ref.read(numberingProvider).next('CMD', DateTime.now().year);
    final po = PurchaseOrder(
      id: _id(),
      number: number,
      supplierId: supplierId,
      date: DateTime.now(),
    );
    _store.upsert(po);
    state = [po, ...state];
    return po;
  }

  void update(PurchaseOrder o) {
    _store.upsert(o);
    state = [for (final x in state) if (x.id == o.id) o else x];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final x in state) if (x.id != id) x];
  }

  PurchaseOrder? byId(String id) {
    for (final o in state) {
      if (o.id == id) return o;
    }
    return null;
  }

  void addLine(String orderId, LineItem line) {
    final o = byId(orderId);
    if (o != null) update(o.copyWith(lines: [...o.lines, line]));
  }

  void updateLine(String orderId, LineItem line) {
    final o = byId(orderId);
    if (o == null) return;
    update(o.copyWith(
        lines: [for (final l in o.lines) if (l.id == line.id) line else l]));
  }

  void removeLine(String orderId, String lineId) {
    final o = byId(orderId);
    if (o == null) return;
    update(o.copyWith(lines: [for (final l in o.lines) if (l.id != lineId) l]));
  }

  /// Enregistre un règlement fournisseur (comptabilité fournisseur / AP).
  /// Le montant est borné au reste dû pour éviter les trop-perçus.
  void addPayment(String orderId, double amount,
      {PaymentMethod method = PaymentMethod.cash, DateTime? date}) {
    final o = byId(orderId);
    if (o == null || amount <= 0) return;
    final capped = amount.clamp(0, o.balanceDue).toDouble();
    if (capped <= 0) return;
    final now = date ?? DateTime.now();
    final payment = Payment(
      id: 'pay-${now.microsecondsSinceEpoch}_${_seq++}',
      date: now,
      amount: capped,
      method: method,
    );
    update(o.copyWith(payments: [...o.payments, payment]));
  }

  void removePayment(String orderId, String paymentId) {
    final o = byId(orderId);
    if (o == null) return;
    update(o.copyWith(
        payments: [for (final p in o.payments) if (p.id != paymentId) p]));
  }

  /// Réceptionne la commande → incrémente le stock des variantes liées.
  void receive(String orderId) {
    final o = byId(orderId);
    if (o == null || o.status == PoStatus.received) return;
    final catalog = ref.read(catalogProvider.notifier);
    for (final l in o.lines) {
      if (l.variantId != null) {
        catalog.adjustVariantStock(l.variantId!, l.qty.round());
      }
    }
    update(o.copyWith(status: PoStatus.received, receivedAt: DateTime.now()));
  }
}

final ordersProvider =
    NotifierProvider<OrdersController, List<PurchaseOrder>>(OrdersController.new);
