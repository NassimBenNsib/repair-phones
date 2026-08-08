import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/core/domain/totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // gross = 2×50 + 1×20 = 120
  final lines = [
    const LineItem(id: 'a', label: 'A', qty: 2, unitPrice: 50, taxRate: 0.20),
    const LineItem(id: 'b', label: 'B', qty: 1, unitPrice: 20, taxRate: 0.10),
  ];

  group('Totals.compute', () {
    test('global tax rate, no discount', () {
      final t = Totals.compute(lines, globalTaxRate: 0.20);
      expect(t.subtotal, 120);
      expect(t.taxAmount, closeTo(24, 1e-9));
      expect(t.total, closeTo(144, 1e-9));
    });

    test('discount reduces subtotal before tax', () {
      final t = Totals.compute(lines, discount: 20, globalTaxRate: 0.20);
      expect(t.subtotal, 100);
      expect(t.taxAmount, closeTo(20, 1e-9));
      expect(t.total, closeTo(120, 1e-9));
    });

    test('per-line tax when globalTaxRate is null', () {
      // 100×0.20 + 20×0.10 = 20 + 2 = 22
      final t = Totals.compute(lines);
      expect(t.subtotal, 120);
      expect(t.taxAmount, closeTo(22, 1e-9));
      expect(t.total, closeTo(142, 1e-9));
    });

    test('discount larger than gross clamps subtotal to 0', () {
      final t = Totals.compute(lines, discount: 500, globalTaxRate: 0.20);
      expect(t.subtotal, 0);
      expect(t.taxAmount, 0);
      expect(t.total, 0);
    });
  });
}
