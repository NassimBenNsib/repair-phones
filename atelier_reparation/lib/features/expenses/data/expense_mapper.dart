import '../../../core/data/local_store.dart';
import '../domain/expense.dart';

/// (Dé)sérialisation d'une [Expense].
class ExpenseMapper implements EntityMapper<Expense> {
  @override
  String get collection => 'expenses';

  @override
  String idOf(Expense e) => e.id;

  @override
  Map<String, Object?> toJson(Expense e) => {
        'id': e.id,
        'date': e.date.toIso8601String(),
        'label': e.label,
        'category': e.category.name,
        'amountHt': e.amountHt,
        'vatRate': e.vatRate,
        'note': e.note,
      };

  @override
  Expense fromJson(Map<String, Object?> j) => Expense(
        id: j['id'] as String,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        label: j['label'] as String? ?? '',
        category: ExpenseCategory.values.firstWhere(
            (c) => c.name == j['category'],
            orElse: () => ExpenseCategory.other),
        amountHt: (j['amountHt'] as num?)?.toDouble() ?? 0,
        vatRate: (j['vatRate'] as num?)?.toDouble() ?? 0.20,
        note: j['note'] as String?,
      );
}
