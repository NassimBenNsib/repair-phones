import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/kpi_card.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/domain/invoice.dart';
import '../../quotes/application/quotes_controller.dart';
import '../../quotes/domain/quote.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/domain/repair.dart';

/// Rapports : synthèse financière et opérationnelle calculée en direct
/// (chiffre d'affaires, encaissements, impayés, répartitions par statut).
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const String routeName = 'reports';
  static const String routePath = '/reports';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    final invoices = ref.watch(invoicesProvider);
    final quotes = ref.watch(quotesProvider);
    final repairs = ref.watch(repairsProvider);
    final now = DateTime.now();

    final issued = invoices.where((i) => i.isIssued).toList();
    final revenue = issued.fold<double>(0, (s, i) => s + i.totals.total);
    final collected = issued.fold<double>(0, (s, i) => s + i.amountPaid);
    final outstanding = issued.fold<double>(0, (s, i) => s + i.balanceDue);

    final invoiceByStatus = <InvoiceStatus, int>{
      for (final s in InvoiceStatus.values)
        s: invoices.where((i) => i.effectiveStatus(now) == s).length,
    };
    final quoteByStatus = <QuoteStatus, int>{
      for (final s in QuoteStatus.values)
        s: quotes.where((q) => q.status == s).length,
    };
    final repairByStatus = <RepairStatus, int>{
      for (final s in RepairStatus.values)
        s: repairs.where((r) => r.status == s).length,
    };
    final accepted = quoteByStatus[QuoteStatus.accepted] ?? 0;
    final acceptanceRate =
        quotes.isEmpty ? 0 : (accepted * 100 / quotes.length).round();

    Widget money(String label, double v, IconData icon, Color tint) => KpiCard(
          label: label,
          value: v.round(),
          unit: AppFormats.symbol,
          icon: icon,
          tint: tint,
        );

    return AppleScaffold(
      title: l.navReports,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(title: l.reportsFinance),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
          sliver: SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, c) {
                final columns = (c.maxWidth ~/ 200).clamp(1, 3);
                const spacing = 12.0;
                final w =
                    (c.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                        width: w,
                        child: money(l.statRevenue, revenue,
                            Icons.trending_up, colors.green)),
                    SizedBox(
                        width: w,
                        child: money(l.reportsCollected, collected,
                            Icons.check_circle_outline, colors.blue)),
                    SizedBox(
                        width: w,
                        child: money(l.statUnpaid, outstanding,
                            Icons.error_outline, colors.orange)),
                  ],
                );
              },
            ),
          ),
        ),

        // Factures par statut.
        _header(l.navInvoices),
        _section([
          for (final s in InvoiceStatus.values)
            AppleListRow(
              title: s.label(l),
              leadingIcon: Icons.circle,
              leadingTint: s.color(colors),
              trailingText: '${invoiceByStatus[s] ?? 0}',
            ),
        ]),

        // Devis.
        _header(l.navQuotes),
        _section([
          AppleListRow(
            title: l.reportsAcceptanceRate,
            leadingIcon: Icons.percent,
            leadingTint: colors.green,
            trailingText: '$acceptanceRate %',
          ),
          for (final s in QuoteStatus.values)
            AppleListRow(
              title: s.label(l),
              leadingIcon: Icons.circle,
              leadingTint: s.color(colors),
              trailingText: '${quoteByStatus[s] ?? 0}',
            ),
        ]),

        // Réparations.
        _header(l.navRepairs),
        _section([
          for (final s in RepairStatus.values)
            AppleListRow(
              title: s.label(l),
              leadingIcon: Icons.circle,
              leadingTint: s.color(colors),
              trailingText: '${repairByStatus[s] ?? 0}',
            ),
        ]),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _header(String title) => SliverPadding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4),
        sliver: SliverToBoxAdapter(child: SectionHeader(title: title)),
      );

  Widget _section(List<Widget> children) => SliverPadding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: AppleListSection(children: children),
        ),
      );
}
