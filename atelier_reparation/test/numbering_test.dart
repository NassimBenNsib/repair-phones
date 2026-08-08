import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/domain/numbering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberingService.next (gap-free legal numbering)', () {
    late NumberingService numbering;

    setUp(() => numbering = NumberingService(InMemoryStore()));

    test('produces a gap-free padded sequence', () {
      expect(numbering.next('FACT', 2026), 'FACT-2026-0001');
      expect(numbering.next('FACT', 2026), 'FACT-2026-0002');
      expect(numbering.next('FACT', 2026), 'FACT-2026-0003');
    });

    test('resets per year', () {
      numbering.next('FACT', 2026); // 0001
      numbering.next('FACT', 2026); // 0002
      expect(numbering.next('FACT', 2027), 'FACT-2027-0001');
    });

    test('sequences are independent per prefix', () {
      numbering.next('FACT', 2026); // FACT 0001
      expect(numbering.next('DEVIS', 2026), 'DEVIS-2026-0001');
      expect(numbering.next('FACT', 2026), 'FACT-2026-0002');
    });

    test('persists the counter across service instances (same store)', () {
      final store = InMemoryStore();
      NumberingService(store).next('FACT', 2026); // 0001
      // A fresh service over the same store continues, not restarts.
      expect(NumberingService(store).next('FACT', 2026), 'FACT-2026-0002');
    });
  });
}
