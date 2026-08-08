// Dépenses (EX1) : modèle (TVA/total) + CRUD du contrôleur.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/expenses/application/expenses_controller.dart';
import 'package:atelier_reparation/features/expenses/domain/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Expense : TVA déductible et total', () {
    final e = Expense(
        id: 'e1',
        date: DateTime(2026, 4, 1),
        label: 'Loyer',
        category: ExpenseCategory.rent,
        amountHt: 100,
        vatRate: 0.20);
    expect(e.vatAmount, 20);
    expect(e.total, 120);
  });

  test('CRUD du contrôleur (tri par date desc)', () {
    final c = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(c.dispose);
    final ctrl = c.read(expensesProvider.notifier);

    expect(c.read(expensesProvider), isEmpty);
    ctrl.add(Expense(
        id: 'e1',
        date: DateTime(2026, 1, 1),
        label: 'Vieux',
        category: ExpenseCategory.other,
        amountHt: 10));
    ctrl.add(Expense(
        id: 'e2',
        date: DateTime(2026, 6, 1),
        label: 'Récent',
        category: ExpenseCategory.rent,
        amountHt: 300));

    final list = c.read(expensesProvider);
    expect(list.first.id, 'e2'); // plus récent en tête
    expect(ctrl.byId('e1')!.label, 'Vieux');

    ctrl.update(ctrl.byId('e2')!.copyWith(amountHt: 350));
    expect(ctrl.byId('e2')!.amountHt, 350);

    ctrl.remove('e1');
    expect(ctrl.byId('e1'), isNull);
    expect(c.read(expensesProvider).length, 1);
  });
}
