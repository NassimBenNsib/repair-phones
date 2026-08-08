// SS1 — relevé fournisseur : achats reçus, en commande, vieillissement des
// livraisons attendues (par date attendue), annulées exclues.

import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart'
    show Payment;
import 'package:atelier_reparation/features/orders/domain/purchase_order.dart';
import 'package:atelier_reparation/features/suppliers/application/supplier_statement.dart';
import 'package:flutter_test/flutter_test.dart';

PurchaseOrder _po({
  required String id,
  required String supplierId,
  required PoStatus status,
  required DateTime date,
  DateTime? expectedDate,
  DateTime? receivedAt,
  double unitPrice = 100,
  List<Payment> payments = const [],
}) =>
    PurchaseOrder(
      id: id,
      number: id,
      supplierId: supplierId,
      status: status,
      date: date,
      expectedDate: expectedDate,
      receivedAt: receivedAt,
      lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: unitPrice)],
      taxRate: 0, // TTC = HT pour des assertions simples
      payments: payments,
    );

void main() {
  test('agingBucket : bornes des tranches', () {
    expect(agingBucket(0), PoAgeBucket.notDue);
    expect(agingBucket(-5), PoAgeBucket.notDue);
    expect(agingBucket(1), PoAgeBucket.d1to30);
    expect(agingBucket(30), PoAgeBucket.d1to30);
    expect(agingBucket(31), PoAgeBucket.d31to60);
    expect(agingBucket(60), PoAgeBucket.d31to60);
    expect(agingBucket(61), PoAgeBucket.d60plus);
  });

  test('reçus, en commande, et vieillissement par date attendue', () {
    final now = DateTime(2026, 6, 1);
    final orders = [
      // Reçu : compte comme achat.
      _po(
          id: 'R1',
          supplierId: 's1',
          status: PoStatus.received,
          date: DateTime(2026, 1, 10),
          unitPrice: 300),
      // En commande, attendu il y a 45 j → tranche 31–60.
      _po(
          id: 'O1',
          supplierId: 's1',
          status: PoStatus.ordered,
          date: DateTime(2026, 4, 1),
          expectedDate: DateTime(2026, 4, 17),
          unitPrice: 200),
      // En commande, attendu dans le futur → non échu.
      _po(
          id: 'O2',
          supplierId: 's1',
          status: PoStatus.ordered,
          date: DateTime(2026, 5, 20),
          expectedDate: DateTime(2026, 6, 20),
          unitPrice: 50),
      // Annulée : ignorée.
      _po(
          id: 'X1',
          supplierId: 's1',
          status: PoStatus.cancelled,
          date: DateTime(2026, 5, 1),
          unitPrice: 999),
      // Autre fournisseur : ignoré.
      _po(
          id: 'Z1',
          supplierId: 's2',
          status: PoStatus.received,
          date: DateTime(2026, 5, 1),
          unitPrice: 999),
    ];

    final s = computeSupplierStatement('s1', orders, now: now);

    expect(s.receivedCount, 1);
    expect(s.purchasedTtc, closeTo(300, 1e-9));
    expect(s.onOrderCount, 2);
    expect(s.onOrderTtc, closeTo(250, 1e-9));

    expect(s.aging[PoAgeBucket.d31to60], closeTo(200, 1e-9));
    expect(s.aging[PoAgeBucket.notDue], closeTo(50, 1e-9));
    expect(s.aging[PoAgeBucket.d1to30], 0);
    expect(s.aging[PoAgeBucket.d60plus], 0);

    // En retard = tout le en-commande sauf le non échu.
    expect(s.overdueTtc, closeTo(200, 1e-9));

    // Annulées/autre fournisseur exclues de la liste.
    expect(s.orders.map((o) => o.id), ['O2', 'O1', 'R1']);
  });

  test('payables : reste dû sur commandes reçues, vieilli par réception', () {
    final now = DateTime(2026, 6, 1);
    final orders = [
      // Reçue il y a 40 j, réglée à moitié → impayé 50, tranche 31–60.
      _po(
        id: 'R1',
        supplierId: 's1',
        status: PoStatus.received,
        date: DateTime(2026, 4, 1),
        receivedAt: DateTime(2026, 4, 22),
        unitPrice: 100,
        payments: [Payment(id: 'p', date: DateTime(2026, 4, 25), amount: 50)],
      ),
      // Reçue récemment, soldée → aucun impayé.
      _po(
        id: 'R2',
        supplierId: 's1',
        status: PoStatus.received,
        date: DateTime(2026, 5, 20),
        receivedAt: DateTime(2026, 5, 25),
        unitPrice: 80,
        payments: [Payment(id: 'p2', date: DateTime(2026, 5, 26), amount: 80)],
      ),
    ];

    final s = computeSupplierStatement('s1', orders, now: now);

    expect(s.purchasedTtc, closeTo(180, 1e-9)); // 100 + 80
    expect(s.paidTtc, closeTo(130, 1e-9)); // 50 + 80
    expect(s.payableTtc, closeTo(50, 1e-9)); // seul R1 doit 50
    expect(s.payableAging[PoAgeBucket.d31to60], closeTo(50, 1e-9));
    expect(s.payableAging[PoAgeBucket.notDue], 0);
    expect(s.overduePayableTtc, closeTo(50, 1e-9));
  });

  test('fournisseur sans commande → vide', () {
    final s = computeSupplierStatement('nobody', const []);
    expect(s.isEmpty, isTrue);
    expect(s.purchasedTtc, 0);
    expect(s.onOrderTtc, 0);
  });
}
