import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../suppliers/application/suppliers_controller.dart';
import '../application/orders_controller.dart';
import '../domain/purchase_order.dart';
import 'order_detail.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  static const String routeName = 'orders';
  static const String routePath = '/orders';

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _query = '';
  PoStatus? _filter;
  String? _selectedId;

  List<PurchaseOrder> _filtered(List<PurchaseOrder> all) {
    final q = _query.trim().toLowerCase();
    return all.where((o) {
      final matchStatus = _filter == null || o.status == _filter;
      final matchQuery = q.isEmpty || o.number.toLowerCase().contains(q);
      return matchStatus && matchQuery;
    }).toList();
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final suppliers = ref.read(suppliersProvider);
    if (suppliers.isEmpty) return;
    final supplierId = await showAppleSelectionSheet<String>(
      context: context,
      title: l.orderSupplier,
      selected: '',
      options: [for (final s in suppliers) AppleSheetOption(s.id, s.name)],
    );
    if (supplierId == null) return;
    final po = ref.read(ordersProvider.notifier).create(supplierId);
    if (!mounted) return;
    if (context.mounted &&
        !ref
            .read(settingsControllerProvider.select((s) => s.detailLayout))
            .useTwoPane(MediaQuery.sizeOf(context).width)) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: po.id)));
    } else {
      setState(() => _selectedId = po.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailLayout =
        ref.watch(settingsControllerProvider.select((s) => s.detailLayout));
    return LayoutBuilder(
      builder: (context, c) => detailLayout.useTwoPane(c.maxWidth)
          ? _twoPane(context)
          : _singlePane(context),
    );
  }

  Widget _filterBar(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppleChip(
              label: l.repairsFilterAll,
              selected: _filter == null,
              onTap: () => setState(() => _filter = null)),
          for (final s in PoStatus.values)
            AppleChip(
                label: s.label(l),
                selected: _filter == s,
                onTap: () => setState(() => _filter = s)),
        ],
      ),
    );
  }

  Widget _singlePane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final results = _filtered(ref.watch(ordersProvider));
    return AppleScaffold(
      title: l.navOrders,
      actions: [
        IconButton(
            onPressed: _add,
            icon: Icon(Icons.add, color: context.accentColor),
            tooltip: l.orderNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
                hintText: l.orderSearch,
                onChanged: (v) => setState(() => _query = v)),
          ),
        ),
        SliverToBoxAdapter(child: _filterBar(l)),
        SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: results.isEmpty
                ? _Empty(l: l)
                : AppleListSection(
                    children: [
                      for (final o in results)
                        _OrderRow(
                          order: o,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailScreen(orderId: o.id)),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _twoPane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final all = ref.watch(ordersProvider);
    final results = _filtered(all);
    final shown = all.any((o) => o.id == _selectedId) ? _selectedId : null;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.navOrders,
                    style: AppleTypography.title1.copyWith(color: colors.label)),
              ),
              IconButton(
                  onPressed: _add,
                  icon: Icon(Icons.add, color: context.accentColor),
                  tooltip: l.orderNew),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: AppleSearchField(
              hintText: l.orderSearch,
              onChanged: (v) => setState(() => _query = v)),
        ),
        _filterBar(l),
        Expanded(
          child: results.isEmpty
              ? _Empty(l: l)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    AppleListSection(
                      children: [
                        for (final o in results)
                          _OrderRow(
                            order: o,
                            selected: o.id == shown,
                            onTap: () => setState(() => _selectedId = o.id),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );

    return ColoredBox(
      color: colors.groupedBackground,
      child: SafeArea(
        child: shown == null
            ? list
            : Row(
                children: [
                  SizedBox(width: 380, child: list),
                  VerticalDivider(
                      width: 0.5, thickness: 0.5, color: colors.separator),
                  Expanded(
                    child: OrderDetailView(
                      key: ValueKey(shown),
                      orderId: shown,
                      onClose: () => setState(() => _selectedId = null),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OrderRow extends ConsumerWidget {
  const _OrderRow(
      {required this.order, required this.onTap, this.selected = false});

  final PurchaseOrder order;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    String? supplier;
    for (final s in ref.watch(suppliersProvider)) {
      if (s.id == order.supplierId) {
        supplier = s.name;
        break;
      }
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? context.accentColor.withValues(alpha: 0.10)
            : Colors.transparent,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.fill,
          highlightColor: colors.fill,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.number,
                          style:
                              AppleTypography.body.copyWith(color: colors.label)),
                      Text(supplier ?? l.notProvided,
                          style: AppleTypography.footnote
                              .copyWith(color: colors.secondaryLabel)),
                    ],
                  ),
                ),
                AppleBadge(
                    label: order.status.label(l),
                    color: order.status.color(colors)),
                const SizedBox(width: 8),
                Text(AppFormats.money(order.totals.total, decimals: 0),
                    style: AppleTypography.subheadline.copyWith(
                        color: colors.label, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
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
          Icon(Icons.shopping_cart_outlined,
              size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.orderEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          const SizedBox(height: 4),
          Text(l.orderEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
        ],
      ),
    );
  }
}
