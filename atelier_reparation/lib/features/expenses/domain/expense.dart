import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Catégorie de dépense (charges de l'atelier).
enum ExpenseCategory {
  rent,
  utilities,
  supplies,
  marketing,
  transport,
  salaries,
  tax,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String label(AppLocalizations l) => switch (this) {
        ExpenseCategory.rent => l.expenseCatRent,
        ExpenseCategory.utilities => l.expenseCatUtilities,
        ExpenseCategory.supplies => l.expenseCatSupplies,
        ExpenseCategory.marketing => l.expenseCatMarketing,
        ExpenseCategory.transport => l.expenseCatTransport,
        ExpenseCategory.salaries => l.expenseCatSalaries,
        ExpenseCategory.tax => l.expenseCatTax,
        ExpenseCategory.other => l.expenseCatOther,
      };

  IconData get icon => switch (this) {
        ExpenseCategory.rent => Icons.home_outlined,
        ExpenseCategory.utilities => Icons.bolt_outlined,
        ExpenseCategory.supplies => Icons.inventory_2_outlined,
        ExpenseCategory.marketing => Icons.campaign_outlined,
        ExpenseCategory.transport => Icons.local_shipping_outlined,
        ExpenseCategory.salaries => Icons.groups_outlined,
        ExpenseCategory.tax => Icons.account_balance_outlined,
        ExpenseCategory.other => Icons.receipt_long_outlined,
      };

  Color color(AppleColors c) => switch (this) {
        ExpenseCategory.rent => c.indigo,
        ExpenseCategory.utilities => c.orange,
        ExpenseCategory.supplies => c.teal,
        ExpenseCategory.marketing => c.pink,
        ExpenseCategory.transport => c.blue,
        ExpenseCategory.salaries => c.green,
        ExpenseCategory.tax => c.red,
        ExpenseCategory.other => c.secondaryLabel,
      };
}

/// Dépense / charge : montant HT + TVA déductible, rattachée à une catégorie.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.date,
    required this.label,
    required this.category,
    required this.amountHt,
    this.vatRate = 0.20,
    this.note,
  });

  final String id;
  final DateTime date;
  final String label;
  final ExpenseCategory category;
  final double amountHt;
  final double vatRate;
  final String? note;

  double get vatAmount => amountHt * vatRate;
  double get total => amountHt + vatAmount;

  Expense copyWith({
    DateTime? date,
    String? label,
    ExpenseCategory? category,
    double? amountHt,
    double? vatRate,
    String? note,
    bool clearNote = false,
  }) =>
      Expense(
        id: id,
        date: date ?? this.date,
        label: label ?? this.label,
        category: category ?? this.category,
        amountHt: amountHt ?? this.amountHt,
        vatRate: vatRate ?? this.vatRate,
        note: clearNote ? null : (note ?? this.note),
      );
}
