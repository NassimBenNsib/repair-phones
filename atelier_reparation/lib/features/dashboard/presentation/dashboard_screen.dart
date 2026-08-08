import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/permissions.dart';
import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chart.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/kpi_card.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../../shared/widgets/staggered.dart';
import '../../auth/application/session_controller.dart';
import '../../clients/application/clients_controller.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/presentation/invoices_screen.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../planning/presentation/planning_screen.dart';
import '../../quotes/presentation/quotes_screen.dart';
import '../../suppliers/presentation/suppliers_screen.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/domain/repair.dart';
import '../../repairs/presentation/repair_detail.dart';
import '../../repairs/presentation/repairs_screen.dart';
import '../../staff/application/employees_controller.dart';
import '../application/dashboard_metrics.dart';

/// Tableau de bord : accueil personnalisé, indicateurs animés avec tendances,
/// graphiques (CA + statuts), alertes à traiter et actions rapides.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = 'dashboard';
  static const String routePath = '/';

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardPeriod _period = DashboardPeriod.week;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();

    ref.watch(sessionControllerProvider);
    final canReports =
        ref.read(sessionControllerProvider.notifier).can(Permission.viewReports);

    final repairs = ref.watch(repairsProvider);
    final m = computeDashboard(
      now: now,
      period: _period,
      invoices: ref.watch(invoicesProvider),
      repairs: repairs,
      products: ref.watch(catalogProvider),
      clients: ref.watch(clientsProvider),
      orders: ref.watch(ordersProvider),
    );
    final recent = [...repairs]..sort((a, b) => a.hoursAgo.compareTo(b.hoursAgo));

    var i = 0;
    Widget box(Widget child, {EdgeInsetsGeometry? padding}) =>
        SliverToBoxAdapter(
          child: Padding(
            padding:
                padding ?? const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: staggerIn(context, i++, child),
          ),
        );

    return AppleScaffold(
      title: l.dashboardTitle,
      actions: [
        _NotificationsBell(count: m.attentionCount),
      ],
      slivers: [
        box(_Greeting(name: _greetName(), now: now, metrics: m, locale: locale),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8)),

        box(
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppleSegmentedControl<DashboardPeriod>(
              value: _period,
              onChanged: (p) => setState(() => _period = p),
              segments: {
                DashboardPeriod.week: l.periodWeek,
                DashboardPeriod.month: l.periodMonth,
                DashboardPeriod.year: l.periodYear,
              },
            ),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
        ),

        box(SectionHeader(title: l.dashboardOverview),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4)),
        box(_KpiGrid(l: l, colors: colors, metrics: m, finance: canReports)),

        box(SectionHeader(title: l.dashboardActivity),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4)),
        box(_Charts(
            l: l, colors: colors, metrics: m, finance: canReports, locale: locale)),

        box(SectionHeader(title: l.dashboardNeedsAttention),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4)),
        box(_NeedsAttention(l: l, colors: colors, metrics: m)),

        if (m.priorityRepairs.isNotEmpty) ...[
          box(
            SectionHeader(
              title: l.dashboardPriorities,
              actionLabel: l.commonSeeAll,
              onAction: () => context.go(RepairsScreen.routePath),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4),
          ),
          box(_PriorityList(
              l: l, colors: colors, now: now, repairs: m.priorityRepairs)),
        ],

        if (_quickActions(l).isNotEmpty) ...[
          box(SectionHeader(title: l.dashboardQuickActions),
              padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4)),
          box(Row(
            children: [
              for (final a in _quickActions(l)) ...[
                Expanded(
                  child: AppleButton(
                    label: a.$1,
                    icon: Icons.add,
                    style: AppleButtonStyle.tinted,
                    expand: true,
                    onPressed: () => context.go(a.$2),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ]..removeLast(),
          )),
        ],

        box(
          SectionHeader(
            title: l.dashboardRecentRepairs,
            actionLabel: l.commonSeeAll,
            onAction: () => context.go(RepairsScreen.routePath),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4),
        ),
        box(AppleListSection(
          children: recent.isEmpty
              ? [
                  AppleListRow(
                    leadingIcon: Icons.inbox_outlined,
                    leadingTint: context.accentColor,
                    title: l.dashboardNoRepairs,
                    subtitle: l.dashboardNoRepairsSubtitle,
                  ),
                ]
              : [
                  for (final r in recent.take(4))
                    AppleListRow(
                      leadingIcon: r.kind.icon,
                      leadingTint: r.status.color(colors),
                      title: r.device,
                      subtitle: r.client,
                      trailingText: r.status.label(l),
                      showChevron: true,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              RepairDetailScreen(reference: r.reference))),
                    ),
                ],
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  /// Prénom de l'utilisateur connecté (employé lié, sinon partie locale e-mail).
  String _greetName() {
    final user = ref.read(sessionControllerProvider.notifier).currentUser;
    if (user == null) return '';
    if (user.employeeId != null) {
      for (final e in ref.read(employeesProvider)) {
        if (e.id == user.employeeId) return e.name.split(' ').first;
      }
    }
    final at = user.email.indexOf('@');
    return at > 0 ? user.email.substring(0, at) : user.email;
  }

  /// Actions rapides autorisées par les permissions de l'utilisateur.
  List<(String, String)> _quickActions(AppLocalizations l) {
    final ctrl = ref.read(sessionControllerProvider.notifier);
    return [
      if (ctrl.can(Permission.createRepair))
        (l.quickNewRepair, RepairsScreen.routePath),
      if (ctrl.can(Permission.createQuote))
        (l.quickNewQuote, QuotesScreen.routePath),
      if (ctrl.can(Permission.createInvoice))
        (l.quickNewInvoice, InvoicesScreen.routePath),
    ];
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

class _Greeting extends StatelessWidget {
  const _Greeting(
      {required this.name,
      required this.now,
      required this.metrics,
      required this.locale});

  final String name;
  final DateTime now;
  final DashboardMetrics metrics;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final hello = now.hour < 12
        ? l.greetingMorning
        : now.hour < 18
            ? l.greetingAfternoon
            : l.greetingEvening;
    final greeting = name.isEmpty ? hello : '$hello, $name';

    // Ligne d'état : alertes non nulles, sinon « tout est à jour ».
    final a = metrics.alerts;
    final parts = <String>[
      if (a.dueToday > 0) '${a.dueToday} ${l.alertDueToday.toLowerCase()}',
      if (a.overdueInvoices > 0)
        '${a.overdueInvoices} ${l.alertOverdueInvoices.toLowerCase()}',
      if (a.lowStock > 0) '${a.lowStock} ${l.alertLowStock.toLowerCase()}',
    ];
    final status = parts.isEmpty ? l.dashboardAllClear : parts.take(2).join(' · ');

    return AppleCard(
      elevated: true,
      child: Row(
        children: [
          AppleAvatar(name: name.isEmpty ? '?' : name, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style:
                        AppleTypography.title3.copyWith(color: colors.label)),
                const SizedBox(height: 2),
                Text(toBeginningOfSentenceCase(
                        DateFormat.MMMMEEEEd(locale).format(now)) ??
                    '',
                    style: AppleTypography.footnote
                        .copyWith(color: colors.tertiaryLabel)),
                const SizedBox(height: 6),
                Text(status,
                    style: AppleTypography.subheadline.copyWith(
                        color: parts.isEmpty ? colors.green : colors.orange,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid(
      {required this.l,
      required this.colors,
      required this.metrics,
      required this.finance});

  final AppLocalizations l;
  final AppleColors colors;
  final DashboardMetrics metrics;
  final bool finance;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    // Badge compact : la flèche du KpiCard indique déjà le sens.
    final trendLabel = '${m.trendPct.abs().round()}%';
    final cards = <Widget>[
      if (finance)
        KpiCard(
          label: l.dashboardRevenueTrend,
          value: m.revenue.round(),
          unit: AppFormats.symbol,
          icon: Icons.trending_up,
          tint: colors.green,
          trendLabel: trendLabel,
          trendUp: m.trendUp,
          spark: m.seriesValues,
        ),
      if (finance)
        KpiCard(
          label: l.statUnpaid,
          value: m.outstanding.round(),
          unit: AppFormats.symbol,
          icon: Icons.error_outline,
          tint: colors.orange,
        ),
      KpiCard(
        label: l.dashboardActiveRepairs,
        value: m.inProgress,
        icon: Icons.build,
        tint: colors.blue,
      ),
      KpiCard(
        label: finance ? l.alertDueToday : l.statAwaitingParts,
        value: finance
            ? m.alerts.dueToday
            : (m.statusMix[RepairStatus.awaitingParts] ?? 0),
        icon: finance ? Icons.event : Icons.inventory_2,
        tint: colors.indigo,
      ),
      if (!finance)
        KpiCard(
          label: l.dashboardCompleted,
          value: m.completedInWindow,
          icon: Icons.check_circle,
          tint: colors.green,
        ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final columns = (c.maxWidth ~/ 200).clamp(2, 4);
        const spacing = 12.0;
        final w = (c.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final card in cards) SizedBox(width: w, child: card)],
        );
      },
    );
  }
}

class _Charts extends StatelessWidget {
  const _Charts(
      {required this.l,
      required this.colors,
      required this.metrics,
      required this.finance,
      required this.locale});

  final AppLocalizations l;
  final AppleColors colors;
  final DashboardMetrics metrics;
  final bool finance;
  final String locale;

  String _label(DateTime d) => switch (metrics.period) {
        DashboardPeriod.week => DateFormat.E(locale).format(d),
        DashboardPeriod.month => DateFormat.d(locale).format(d),
        DashboardPeriod.year =>
          DateFormat.MMM(locale).format(d).substring(0, 1),
      };

  Widget _revenueCard(BuildContext context) => AppleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.dashboardRevenueTrend,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
            const SizedBox(height: 12),
            AppleLineChart(
              color: context.accentColor,
              values: metrics.seriesValues,
              labels: [for (final p in metrics.series) _label(p.date)],
            ),
          ],
        ),
      );

  Widget _statusCard(BuildContext context) {
    final total =
        metrics.statusMix.values.fold<int>(0, (s, v) => s + v);
    return AppleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.dashboardStatusMix,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
          const SizedBox(height: 12),
          AppleDonutChart(
            centerValue: '$total',
            centerLabel: l.navRepairs,
            segments: [
              for (final st in RepairStatus.values)
                (
                  label: st.label(l),
                  value: (metrics.statusMix[st] ?? 0).toDouble(),
                  color: st.color(colors),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 640;
        if (!finance) return _statusCard(context);
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _revenueCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _statusCard(context)),
            ],
          );
        }
        return Column(
          children: [
            _revenueCard(context),
            const SizedBox(height: 12),
            _statusCard(context),
          ],
        );
      },
    );
  }
}

class _NeedsAttention extends StatelessWidget {
  const _NeedsAttention(
      {required this.l, required this.colors, required this.metrics});

  final AppLocalizations l;
  final AppleColors colors;
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final a = metrics.alerts;
    final tiles = <(String, int, IconData, Color, String)>[
      if (a.overdueInvoices > 0)
        (l.alertOverdueInvoices, a.overdueInvoices, Icons.receipt_long,
            colors.red, InvoicesScreen.routePath),
      if (a.dueToday > 0)
        (l.alertDueToday, a.dueToday, Icons.event, colors.orange,
            PlanningScreen.routePath),
      if (a.awaitingParts > 0)
        (l.alertAwaitingParts, a.awaitingParts, Icons.inventory_2,
            colors.orange, RepairsScreen.routePath),
      if (a.unassignedRepairs > 0)
        (l.alertUnassigned, a.unassignedRepairs, Icons.person_off_outlined,
            colors.orange, RepairsScreen.routePath),
      if (a.overdueDeliveries > 0)
        (l.alertOverdueDeliveries, a.overdueDeliveries,
            Icons.local_shipping_outlined, colors.red, OrdersScreen.routePath),
      if (a.overduePayables > 0)
        (l.alertOverduePayables, a.overduePayables, Icons.account_balance_wallet,
            colors.red, SuppliersScreen.routePath),
      if (a.lowStock > 0)
        (l.alertLowStock, a.lowStock, Icons.warning_amber_rounded, colors.red,
            InventoryScreen.routePath),
    ];

    if (tiles.isEmpty) {
      return AppleCard(
        child: Row(
          children: [
            Icon(Icons.check_circle, color: colors.green),
            const SizedBox(width: 12),
            Text(l.dashboardAllClear,
                style: AppleTypography.body.copyWith(color: colors.label)),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, cc) {
      final columns = (cc.maxWidth ~/ 220).clamp(1, 4);
      const spacing = 12.0;
      final w = (cc.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final t in tiles)
            SizedBox(
              width: w,
              child: AppleCard(
                onTap: () => context.go(t.$5),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                          color: t.$4.withValues(alpha: 0.16),
                          shape: AppleRadii.shape(AppleRadii.md)),
                      child: Icon(t.$3, color: t.$4, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${t.$2}',
                              style: AppleTypography.title3
                                  .copyWith(color: colors.label)),
                          Text(t.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppleTypography.footnote
                                  .copyWith(color: colors.secondaryLabel)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Liste de priorités : réparations actives en retard, cliquables.
class _PriorityList extends StatelessWidget {
  const _PriorityList(
      {required this.l,
      required this.colors,
      required this.now,
      required this.repairs});

  final AppLocalizations l;
  final AppleColors colors;
  final DateTime now;
  final List<Repair> repairs;

  @override
  Widget build(BuildContext context) {
    final today = DateTime(now.year, now.month, now.day);
    return AppleListSection(children: [
      for (final r in repairs.take(5))
        AppleListRow(
          leadingIcon: r.kind.icon,
          leadingTint: colors.red,
          title: r.device,
          subtitle: r.client,
          trailingText: l.dashboardOverdueBy(today.difference(r.dueAt!).inDays),
          showChevron: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RepairDetailScreen(reference: r.reference))),
        ),
    ]);
  }
}

/// Cloche de notifications avec pastille de compteur « à traiter ».
class _NotificationsBell extends StatelessWidget {
  const _NotificationsBell({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const NotificationsScreen())),
          icon: Icon(Icons.notifications_none, color: context.accentColor),
          tooltip: l.dashboardNotifications,
        ),
        if (count > 0)
          PositionedDirectional(
            top: 8,
            end: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                  color: colors.red,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: AppleTypography.caption2.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
