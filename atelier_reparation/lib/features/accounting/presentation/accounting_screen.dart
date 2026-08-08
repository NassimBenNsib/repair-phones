import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/settings/vat_basis.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chart.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/kpi_card.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../expenses/application/expenses_controller.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../invoices/application/credit_notes_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/domain/invoice.dart';
import '../../orders/application/orders_controller.dart';
import '../application/accounting_summary.dart';

/// Comptabilité : synthèse HT / TVA / TTC par mois pour un exercice, avec
/// TVA collectée et encaissements par moyen de paiement. Basé sur les factures
/// émises (par `issueDate`).
class AccountingScreen extends ConsumerStatefulWidget {
  const AccountingScreen({super.key});

  static const String routeName = 'accounting';
  static const String routePath = '/accounting';

  @override
  ConsumerState<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends ConsumerState<AccountingScreen> {
  late int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final locale = Localizations.localeOf(context).toString();

    final vatBasis = ref.watch(settingsControllerProvider).vatBasis;
    final summary = computeYearSummary(ref.watch(invoicesProvider), _year,
        purchases: ref.watch(ordersProvider),
        expenses: ref.watch(expensesProvider),
        creditNotes: ref.watch(creditNotesProvider),
        basis: vatBasis);
    final months = summary.months;
    final collected = summary.collected;
    final outstanding = summary.outstanding;
    final byMethod = summary.byMethod;
    final ht = summary.ht;
    final vat = summary.vat;
    final ttc = summary.ttc;
    final isEmpty = summary.isEmpty;

    return AppleScaffold(
      title: l.navAccounting,
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpensesScreen())),
          icon: Icon(Icons.receipt_long_outlined, color: context.accentColor),
          tooltip: l.expenses,
        ),
      ],
      slivers: [
        // Sélecteur d'exercice.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
            child: AppleCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () => setState(() => _year--),
                      icon: Icon(
                          context.isRtl
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                          color: context.accentColor)),
                  Text('$_year',
                      style: AppleTypography.title2.copyWith(
                          color: colors.label, fontWeight: FontWeight.w600)),
                  IconButton(
                      onPressed: _year >= DateTime.now().year
                          ? null
                          : () => setState(() => _year++),
                      icon: Icon(context.chevronForward,
                          color: _year >= DateTime.now().year
                              ? colors.tertiaryLabel
                              : context.accentColor)),
                ],
              ),
            ),
          ),
        ),

        // KPI de l'exercice.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: LayoutBuilder(builder: (context, c) {
              const spacing = 12.0;
              final w = (c.maxWidth - spacing * 2) / 3;
              Widget card(String label, double v, IconData ic, Color t) =>
                  SizedBox(
                      width: w,
                      child: KpiCard(
                          label: label,
                          value: v.round(),
                          unit: AppFormats.symbol,
                          icon: ic,
                          tint: t));
              return Wrap(spacing: spacing, runSpacing: spacing, children: [
                card(l.accountingHt, ht, Icons.receipt_long, colors.blue),
                card(l.accountingVatCollected, vat, Icons.account_balance,
                    colors.orange),
                card(l.accountingTtc, ttc, Icons.trending_up, colors.green),
              ]);
            }),
          ),
        ),

        // Encaissé / impayé de l'exercice.
        if (!isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: AppleCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _Metric(
                          label: l.reportsCollected,
                          value: collected,
                          color: colors.green),
                    ),
                    Container(
                        width: 0.5, height: 34, color: colors.separator),
                    Expanded(
                      child: _Metric(
                          label: l.statUnpaid,
                          value: outstanding,
                          color: colors.orange),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // TVA collectée / déductible / nette due + achats & marge.
        if (!isEmpty || summary.purchasesCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
              child: AppleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppleSegmentedControl<VatBasis>(
                        value: vatBasis,
                        onChanged: (b) => ref
                            .read(settingsControllerProvider.notifier)
                            .setVatBasis(b),
                        segments: {
                          VatBasis.accrual: l.vatBasisAccrual,
                          VatBasis.cash: l.vatBasisCash,
                        },
                      ),
                    ),
                    _VatRow(label: l.accountingVatCollected, value: summary.vat),
                    _VatRow(
                        label: l.accountingVatDeductible,
                        value: summary.deductibleVat,
                        color: colors.secondaryLabel),
                    Divider(color: colors.separator, height: 18),
                    _VatRow(
                        label: l.accountingVatNet,
                        value: summary.netVat,
                        bold: true,
                        color: summary.netVat >= 0
                            ? colors.label
                            : colors.green),
                    const SizedBox(height: 6),
                    _VatRow(
                        label: l.accountingPurchases,
                        value: summary.purchasesHt,
                        color: colors.secondaryLabel),
                    if (summary.expensesCount > 0)
                      _VatRow(
                          label: l.expenses,
                          value: summary.expensesHt,
                          color: colors.secondaryLabel),
                    if (summary.supplierPaid > 0.005 ||
                        summary.supplierPayable > 0.005) ...[
                      _VatRow(
                          label: l.accountingSupplierPaid,
                          value: summary.supplierPaid,
                          color: colors.secondaryLabel),
                      if (summary.supplierPayable > 0.005)
                        _VatRow(
                            label: l.accountingSupplierPayable,
                            value: summary.supplierPayable,
                            color: colors.orange),
                    ],
                    _VatRow(
                        label: l.accountingResult,
                        value: summary.netResult,
                        bold: true,
                        color: summary.netResult >= 0
                            ? colors.green
                            : colors.red),
                  ],
                ),
              ),
            ),
          ),

        if (isEmpty)
          SliverToBoxAdapter(child: _Empty(l: l))
        else ...[
          // Graphe TTC par mois.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
              child: AppleCard(
                child: AppleBarChart(
                  color: context.accentColor,
                  values: [for (final m in months) m.ttc],
                  labels: [
                    for (var i = 0; i < 12; i++)
                      DateFormat.MMM(locale)
                          .format(DateTime(_year, i + 1))
                          .substring(0, 1),
                  ],
                ),
              ),
            ),
          ),

          // Détail par mois (mois non vides).
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 4),
            sliver: SliverToBoxAdapter(
                child: SectionHeader(title: l.navAccounting)),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(
                children: [
                  for (var i = 0; i < 12; i++)
                    if (months[i].count > 0)
                      AppleListRow(
                        title: _cap(DateFormat.MMMM(locale)
                            .format(DateTime(_year, i + 1))),
                        subtitle:
                            '${l.accountingHt} ${AppFormats.money(months[i].ht)} · ${l.accountingVat} ${AppFormats.money(months[i].vat)}',
                        trailingText:
                            AppFormats.money(months[i].ttc, decimals: 0),
                      ),
                ],
              ),
            ),
          ),

          // Encaissements par moyen de paiement.
          if (byMethod.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 4),
              sliver: SliverToBoxAdapter(
                  child: SectionHeader(title: l.invoiceSectionPayments)),
            ),
            SliverPadding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: AppleListSection(
                  children: [
                    for (final m in PaymentMethod.values)
                      if ((byMethod[m] ?? 0) > 0)
                        AppleListRow(
                          leadingIcon: Icons.payments_outlined,
                          leadingTint: colors.green,
                          title: m.label(l),
                          trailingText:
                              AppFormats.money(byMethod[m]!, decimals: 0),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _VatRow extends StatelessWidget {
  const _VatRow(
      {required this.label,
      required this.value,
      this.bold = false,
      this.color});
  final String label;
  final double value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final style = (bold ? AppleTypography.headline : AppleTypography.body)
        .copyWith(color: color ?? colors.label);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: bold
                    ? style
                    : AppleTypography.body
                        .copyWith(color: colors.secondaryLabel))),
        Text(AppFormats.money(value, decimals: 2), style: style),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Column(
      children: [
        Text(AppFormats.money(value, decimals: 0),
            style: AppleTypography.title3
                .copyWith(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label,
            style: AppleTypography.footnote
                .copyWith(color: colors.secondaryLabel)),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.account_balance_outlined,
              size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.accountingEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
        ],
      ),
    );
  }
}
