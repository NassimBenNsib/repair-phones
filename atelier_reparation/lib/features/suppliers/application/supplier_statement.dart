import 'package:flutter/foundation.dart';

import '../../orders/domain/purchase_order.dart';

/// Tranche d'ancienneté d'une commande en attente de réception, calculée sur la
/// date attendue (ou la date de commande à défaut).
enum PoAgeBucket { notDue, d1to30, d31to60, d60plus }

/// Synthèse d'achats par fournisseur : montants reçus, en commande, et
/// vieillissement des livraisons en attente. Pure et testable.
///
/// Deux vieillissements distincts :
/// - [aging] : **livraisons attendues** (commandes passées non encore reçues),
///   par date attendue — un suivi de la performance de livraison.
/// - [payableAging] : **impayés fournisseur** (commandes reçues avec un reste
///   dû), par date de réception — la comptabilité fournisseur (AP).
@immutable
class SupplierStatement {
  const SupplierStatement({
    required this.orders,
    required this.purchasedHt,
    required this.purchasedTtc,
    required this.receivedCount,
    required this.onOrderTtc,
    required this.onOrderCount,
    required this.aging,
    required this.paidTtc,
    required this.payableTtc,
    required this.payableAging,
    required this.lastOrder,
  });

  final List<PurchaseOrder> orders; // hors annulées, récentes d'abord
  final double purchasedHt; // commandes reçues (HT)
  final double purchasedTtc; // commandes reçues (TTC)
  final int receivedCount;
  final double onOrderTtc; // commandes passées non reçues (TTC)
  final int onOrderCount;
  final Map<PoAgeBucket, double> aging; // TTC en attente par tranche
  final double paidTtc; // total réglé au fournisseur
  final double payableTtc; // reste dû sur les commandes reçues
  final Map<PoAgeBucket, double> payableAging; // impayés par tranche (réception)
  final DateTime? lastOrder;

  bool get isEmpty => orders.isEmpty;

  /// Total en retard (toutes tranches sauf « non échu »).
  double get overdueTtc =>
      onOrderTtc - (aging[PoAgeBucket.notDue] ?? 0);

  /// Impayés en retard (toutes tranches sauf « non échu »).
  double get overduePayableTtc =>
      payableTtc - (payableAging[PoAgeBucket.notDue] ?? 0);
}

PoAgeBucket agingBucket(int daysLate) {
  if (daysLate <= 0) return PoAgeBucket.notDue;
  if (daysLate <= 30) return PoAgeBucket.d1to30;
  if (daysLate <= 60) return PoAgeBucket.d31to60;
  return PoAgeBucket.d60plus;
}

/// Calcule la synthèse d'achats d'un fournisseur à partir des commandes.
SupplierStatement computeSupplierStatement(
  String supplierId,
  List<PurchaseOrder> allOrders, {
  DateTime? now,
}) {
  final ts = now ?? DateTime.now();
  final orders = allOrders
      .where((o) => o.supplierId == supplierId && o.status != PoStatus.cancelled)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  var purchasedHt = 0.0;
  var purchasedTtc = 0.0;
  var receivedCount = 0;
  var onOrderTtc = 0.0;
  var onOrderCount = 0;
  var paidTtc = 0.0;
  var payableTtc = 0.0;
  final aging = <PoAgeBucket, double>{
    for (final b in PoAgeBucket.values) b: 0.0,
  };
  final payableAging = <PoAgeBucket, double>{
    for (final b in PoAgeBucket.values) b: 0.0,
  };
  DateTime? lastOrder;

  for (final o in orders) {
    lastOrder = lastOrder == null || o.date.isAfter(lastOrder)
        ? o.date
        : lastOrder;
    final t = o.totals;
    paidTtc += o.amountPaid;
    if (o.status == PoStatus.received) {
      purchasedHt += t.subtotal;
      purchasedTtc += t.total;
      receivedCount++;
      // Impayé fournisseur : reste dû, vieilli par date de réception.
      if (o.balanceDue > 0.005) {
        payableTtc += o.balanceDue;
        final ref = o.receivedAt ?? o.date;
        final bucket = agingBucket(ts.difference(ref).inDays);
        payableAging[bucket] = (payableAging[bucket] ?? 0) + o.balanceDue;
      }
    } else if (o.status == PoStatus.ordered) {
      onOrderTtc += t.total;
      onOrderCount++;
      final ref = o.expectedDate ?? o.date;
      final daysLate = ts.difference(ref).inDays;
      final bucket = agingBucket(daysLate);
      aging[bucket] = (aging[bucket] ?? 0) + t.total;
    }
  }

  return SupplierStatement(
    orders: orders,
    purchasedHt: purchasedHt,
    purchasedTtc: purchasedTtc,
    receivedCount: receivedCount,
    onOrderTtc: onOrderTtc,
    onOrderCount: onOrderCount,
    aging: aging,
    paidTtc: paidTtc,
    payableTtc: payableTtc,
    payableAging: payableAging,
    lastOrder: lastOrder,
  );
}
