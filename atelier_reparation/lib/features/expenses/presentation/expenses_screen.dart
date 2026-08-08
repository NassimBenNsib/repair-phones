import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../application/expenses_controller.dart';
import '../domain/expense.dart';

/// Journal des dépenses / charges de l'atelier.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  static const String routeName = 'expenses';
  static const String routePath = '/expenses';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final items = ref.watch(expensesProvider);
    final totalTtc = items.fold<double>(0, (s, e) => s + e.total);

    return AppleScaffold(
      title: l.expenses,
      actions: [
        IconButton(
          onPressed: () => _openForm(context, ref),
          icon: Icon(Icons.add, color: context.accentColor),
          tooltip: l.expenseNew,
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              child: Row(children: [
                Icon(Icons.receipt_long, color: colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l.expenses,
                      style: AppleTypography.body
                          .copyWith(color: colors.secondaryLabel)),
                ),
                Text(AppFormats.money(totalTtc, decimals: 2),
                    style: AppleTypography.title3.copyWith(
                        color: colors.label, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(l.expensesEmpty,
                    style: AppleTypography.headline
                        .copyWith(color: colors.secondaryLabel)),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(children: [
                for (final e in items)
                  _ExpenseRow(
                      expense: e, onTap: () => _openForm(context, ref, e)),
              ]),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref,
          [Expense? initial]) =>
      showAppleSheet<void>(
        context: context,
        title: initial == null
            ? AppLocalizations.of(context).expenseNew
            : initial.label,
        builder: (_) => _ExpenseForm(initial: initial),
      );
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense, required this.onTap});
  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final tint = expense.category.color(colors);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: ShapeDecoration(
                color: tint.withValues(alpha: 0.16),
                shape: AppleRadii.shape(AppleRadii.sm),
              ),
              child: Icon(expense.category.icon, size: 18, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppleTypography.body.copyWith(color: colors.label)),
                  Text(
                      '${expense.category.label(l)} · ${AppFormats.date(expense.date)}',
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(AppFormats.money(expense.total, decimals: 0),
                style: AppleTypography.subheadline.copyWith(
                    color: colors.label, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

/// Formulaire de dépense : libellé, catégorie, montant HT, TVA.
class _ExpenseForm extends ConsumerStatefulWidget {
  const _ExpenseForm({this.initial});
  final Expense? initial;

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  late final _label = TextEditingController(text: widget.initial?.label ?? '');
  late final _amount = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.amountHt.toStringAsFixed(0));
  late final _vat = TextEditingController(
      text: ((widget.initial?.vatRate ?? 0.20) * 100).toStringAsFixed(0));
  late ExpenseCategory _category = widget.initial?.category ?? ExpenseCategory.rent;

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_label, _amount, _vat]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) => c.text.trim().isEmpty
      ? null
      : double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool get _valid =>
      _label.text.trim().isNotEmpty && (_num(_amount) ?? -1) >= 0;

  void _save() {
    final ctrl = ref.read(expensesProvider.notifier);
    final vat = (_num(_vat) ?? 20) / 100;
    final amount = _num(_amount) ?? 0;
    final init = widget.initial;
    if (init == null) {
      ctrl.add(Expense(
        id: const Uuid().v4(),
        date: DateTime.now(),
        label: _label.text.trim(),
        category: _category,
        amountHt: amount,
        vatRate: vat,
      ));
    } else {
      ctrl.update(init.copyWith(
          label: _label.text.trim(),
          category: _category,
          amountHt: amount,
          vatRate: vat));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleTextField(controller: _label, label: l.expenseLabel),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l.productCategory,
                style: AppleTypography.footnote
                    .copyWith(color: colors.secondaryLabel)),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in ExpenseCategory.values)
              AppleChip(
                label: c.label(l),
                selected: _category == c,
                selectedColor: c.color(colors),
                onTap: () => setState(() => _category = c),
              ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: AppleTextField(
                  controller: _amount,
                  label: l.expenseAmountHt,
                  suffix: AppFormats.symbol,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppleTextField(
                  controller: _vat,
                  label: l.accountingVat,
                  suffix: '%',
                  keyboardType: TextInputType.number),
            ),
          ]),
          if (_num(_amount) != null) ...[
            const SizedBox(height: 10),
            Text(
                '${l.accountingTtc} : ${AppFormats.money((_num(_amount)!) * (1 + (_num(_vat) ?? 20) / 100))}',
                style: AppleTypography.footnote
                    .copyWith(color: colors.secondaryLabel)),
          ],
          const SizedBox(height: 16),
          AppleButton(
            label: l.commonSave,
            icon: Icons.check,
            expand: true,
            onPressed: _valid ? _save : null,
          ),
          if (widget.initial != null) ...[
            const SizedBox(height: 8),
            AppleButton(
              label: l.actionDelete,
              icon: Icons.delete_outline,
              style: AppleButtonStyle.destructive,
              expand: true,
              onPressed: () {
                ref.read(expensesProvider.notifier).remove(widget.initial!.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
