import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../clients/application/clients_controller.dart';
import '../../dashboard/application/dashboard_metrics.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/presentation/invoices_screen.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../planning/presentation/planning_screen.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/domain/repair.dart';
import '../../repairs/presentation/repair_detail.dart';
import '../../repairs/presentation/repairs_screen.dart';
import '../../suppliers/presentation/suppliers_screen.dart';
import '../application/notification_log_controller.dart';
import '../domain/message_template.dart';
import 'notify_sheet.dart';

IconData _channelIcon(MessageChannel c) => switch (c) {
      MessageChannel.sms => Icons.sms_outlined,
      MessageChannel.whatsapp => Icons.chat_outlined,
      MessageChannel.email => Icons.mail_outline,
    };

/// Boîte de réception des notifications : éléments à traiter (dérivés des
/// indicateurs du tableau de bord) + activité de communication récente.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const String routeName = 'notifications';
  static const String routePath = '/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final m = computeDashboard(
      now: now,
      period: DashboardPeriod.week,
      invoices: ref.watch(invoicesProvider),
      repairs: ref.watch(repairsProvider),
      products: ref.watch(catalogProvider),
      clients: ref.watch(clientsProvider),
      orders: ref.watch(ordersProvider),
    );
    final a = m.alerts;
    final log = ref.watch(notificationLogProvider);

    // Rangées « à traiter » agrégées (catégorie → écran).
    void go(String route) {
      Navigator.of(context).maybePop();
      context.go(route);
    }

    final tiles = <Widget>[
      if (a.overdueInvoices > 0)
        AppleListRow(
          leadingIcon: Icons.receipt_long,
          leadingTint: colors.red,
          title: l.alertOverdueInvoices,
          trailingText: '${a.overdueInvoices}',
          showChevron: true,
          onTap: () => go(InvoicesScreen.routePath),
        ),
      if (a.dueToday > 0)
        AppleListRow(
          leadingIcon: Icons.event,
          leadingTint: colors.orange,
          title: l.alertDueToday,
          trailingText: '${a.dueToday}',
          showChevron: true,
          onTap: () => go(PlanningScreen.routePath),
        ),
      if (a.awaitingParts > 0)
        AppleListRow(
          leadingIcon: Icons.inventory_2,
          leadingTint: colors.orange,
          title: l.alertAwaitingParts,
          trailingText: '${a.awaitingParts}',
          showChevron: true,
          onTap: () => go(RepairsScreen.routePath),
        ),
      if (a.unassignedRepairs > 0)
        AppleListRow(
          leadingIcon: Icons.person_off_outlined,
          leadingTint: colors.orange,
          title: l.alertUnassigned,
          trailingText: '${a.unassignedRepairs}',
          showChevron: true,
          onTap: () => go(RepairsScreen.routePath),
        ),
      if (a.overdueDeliveries > 0)
        AppleListRow(
          leadingIcon: Icons.local_shipping_outlined,
          leadingTint: colors.red,
          title: l.alertOverdueDeliveries,
          trailingText: '${a.overdueDeliveries}',
          showChevron: true,
          onTap: () => go(OrdersScreen.routePath),
        ),
      if (a.overduePayables > 0)
        AppleListRow(
          leadingIcon: Icons.account_balance_wallet,
          leadingTint: colors.red,
          title: l.alertOverduePayables,
          trailingText: '${a.overduePayables}',
          showChevron: true,
          onTap: () => go(SuppliersScreen.routePath),
        ),
      if (a.lowStock > 0)
        AppleListRow(
          leadingIcon: Icons.warning_amber_rounded,
          leadingTint: colors.red,
          title: l.alertLowStock,
          trailingText: '${a.lowStock}',
          showChevron: true,
          onTap: () => go(InventoryScreen.routePath),
        ),
    ];

    final priority = [
      for (final r in m.priorityRepairs)
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
    ];

    final hasAttention = tiles.isNotEmpty || priority.isNotEmpty;

    return AppleScaffold(
      title: l.notificationsTitle,
      slivers: [
        if (!hasAttention && log.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                children: [
                  Icon(Icons.notifications_none,
                      size: 56, color: colors.tertiaryLabel),
                  const SizedBox(height: 12),
                  Text(l.dashboardAllClear,
                      style: AppleTypography.headline
                          .copyWith(color: colors.label)),
                ],
              ),
            ),
          ),
        if (hasAttention) ...[
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(
                child: SectionHeader(title: l.dashboardNeedsAttention)),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
                child: AppleListSection(children: [...tiles, ...priority])),
          ),
        ],
        if (log.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4),
            sliver: SliverToBoxAdapter(
                child: SectionHeader(title: l.notificationsRecent)),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(children: [
                for (final e in log.take(8))
                  AppleListRow(
                    leadingIcon: _channelIcon(e.channel),
                    leadingTint: colors.blue,
                    title: e.to,
                    subtitle: e.repairRef == null
                        ? channelLabel(l, e.channel)
                        : '${channelLabel(l, e.channel)} · ${e.repairRef}',
                    trailingText: AppFormats.date(e.at),
                  ),
              ]),
            ),
          ),
        ],
      ],
    );
  }
}
