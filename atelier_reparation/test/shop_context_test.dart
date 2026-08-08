import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/assistant/application/shop_context.dart';
import 'package:atelier_reparation/features/catalog/domain/product.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:flutter_test/flutter_test.dart';

Repair _repair(RepairStatus status, {DateTime? dueAt}) => Repair(
      reference: '#R-1',
      device: 'iPhone',
      kind: DeviceKind.phone,
      client: 'Sofia',
      status: status,
      priority: RepairPriority.normal,
      progress: 0,
      updatedLabel: '',
      hoursAgo: 1,
      dueAt: dueAt,
    );

void main() {
  final now = DateTime(2026, 7, 17, 10);

  test('summarises in-progress repairs, revenue, unpaid and low stock', () {
    final repairs = [
      _repair(RepairStatus.inProgress),
      _repair(RepairStatus.awaitingParts),
      _repair(RepairStatus.inProgress, dueAt: DateTime(2026, 7, 17, 16)),
    ];
    final invoices = [
      Invoice(
        id: 'i1',
        number: 'FACT-2026-0001',
        clientId: 'c1',
        clientName: 'Sofia',
        status: InvoiceStatus.issued,
        date: now,
        issueDate: now,
        lines: const [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)],
        taxRate: 0.20,
      ),
    ];
    final products = [
      Product(
        id: 'p1',
        name: 'Écran',
        brand: 'Apple',
        categoryId: 'part',
        options: const [],
        variants: const [
          ProductVariant(
              id: 'v1', sku: 'SKU1', attributes: {}, price: 50, stock: 2),
        ],
      ),
    ];

    final ctx = buildShopContext(
        repairs: repairs, invoices: invoices, products: products, now: now);

    expect(ctx, contains('Réparations en cours: 2'));
    expect(ctx, contains('En attente de pièces: 1'));
    expect(ctx, contains('Échéances aujourd\'hui: 1'));
    expect(ctx, contains('120,00 €')); // TTC = 100 + 20% TVA (décimale FR)
    expect(ctx, contains('stock bas'));
    expect(ctx, contains('Écran'));
  });
}
