import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/expense_mapper.dart';
import '../domain/expense.dart';

final expenseStoreProvider = Provider<CollectionStore<Expense>>(
  (ref) => CollectionStore<Expense>(ref.watch(localStoreProvider), ExpenseMapper()),
);

/// Dépenses / charges, adossées au stockage local.
class ExpensesController extends Notifier<List<Expense>> {
  CollectionStore<Expense> get _store => ref.read(expenseStoreProvider);

  @override
  List<Expense> build() =>
      _store.loadAll()..sort((a, b) => b.date.compareTo(a.date));

  Expense? byId(String id) {
    for (final e in state) {
      if (e.id == id) return e;
    }
    return null;
  }

  void add(Expense e) {
    _store.upsert(e);
    state = [e, ...state]..sort((a, b) => b.date.compareTo(a.date));
  }

  void update(Expense e) {
    _store.upsert(e);
    state = [for (final x in state) if (x.id == e.id) e else x]
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final e in state) if (e.id != id) e];
  }
}

final expensesProvider =
    NotifierProvider<ExpensesController, List<Expense>>(ExpensesController.new);
