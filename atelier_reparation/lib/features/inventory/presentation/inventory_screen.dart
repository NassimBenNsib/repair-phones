import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/domain/line_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/presentation/product_detail_screen.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/presentation/order_detail.dart';
import '../../suppliers/application/suppliers_controller.dart';

/// Seuil d'alerte de stock bas (au-delà de la rupture).
const int kLowStockThreshold = 3;

/// Niveau de stock d'une variante.
enum StockLevel { out, low, ok }

extension _StockLevelX on StockLevel {
  String label(AppLocalizations l) => switch (this) {
        StockLevel.out => l.inventoryOut,
        StockLevel.low => l.inventoryLow,
        StockLevel.ok => l.inventoryOk,
      };

  Color color(AppleColors c) => switch (this) {
        StockLevel.out => c.red,
        StockLevel.low => c.orange,
        StockLevel.ok => c.green,
      };
}

StockLevel _levelOf(int stock) => stock <= 0
    ? StockLevel.out
    : stock <= kLowStockThreshold
        ? StockLevel.low
        : StockLevel.ok;

/// Ligne d'inventaire : une variante avec son produit parent.
typedef _Item = ({Product product, ProductVariant variant});

/// Inventaire : niveaux de stock de toutes les variantes, avec alertes de
/// rupture / stock bas et ajustement rapide.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  static const String routeName = 'inventory';
  static const String routePath = '/inventory';

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  StockLevel? _filter;

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  /// Réapprovisionne : crée une commande fournisseur pré-remplie avec la ligne
  /// (produit + variante), en choisissant le fournisseur parmi ceux liés.
  Future<void> _reorder(_Item item) async {
    final l = AppLocalizations.of(context);
    final linked = item.product.supplierIds;
    String? supplierId;
    if (linked.isEmpty) {
      _snack(l.inventoryNoSupplier);
      return;
    } else if (linked.length == 1) {
      supplierId = linked.first;
    } else {
      final byId = {for (final s in ref.read(suppliersProvider)) s.id: s};
      supplierId = await showAppleSelectionSheet<String>(
        context: context,
        title: l.navSuppliers,
        selected: '',
        options: [
          for (final id in linked) AppleSheetOption(id, byId[id]?.name ?? id),
        ],
      );
      if (supplierId == null) return;
    }
    final v = item.variant;
    final qty = kLowStockThreshold + 1 - v.stock;
    // Prix d'achat du fournisseur choisi si connu, sinon prix de vente.
    double unit = v.price;
    for (final s in item.product.sourcing) {
      if (s.supplierId == supplierId && s.purchasePrice != null) {
        unit = s.purchasePrice!;
        break;
      }
    }
    final orders = ref.read(ordersProvider.notifier);
    final po = orders.create(supplierId);
    orders.addLine(
      po.id,
      LineItem(
        id: const Uuid().v4(),
        label: v.attributes.isEmpty
            ? item.product.name
            : '${item.product.name} — ${v.label}',
        qty: (qty < 1 ? 1 : qty).toDouble(),
        unitPrice: unit,
        productId: item.product.id,
        variantId: v.id,
      ),
    );
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: po.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    final products = ref.watch(catalogProvider);
    final items = <_Item>[
      for (final p in products)
        for (final v in p.variants) (product: p, variant: v),
    ]..sort((a, b) => a.variant.stock.compareTo(b.variant.stock));

    final alerts =
        items.where((i) => _levelOf(i.variant.stock) != StockLevel.ok).length;
    final shown = _filter == null
        ? items
        : items.where((i) => _levelOf(i.variant.stock) == _filter).toList();

    return AppleScaffold(
      title: l.navInventory,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: alerts > 0 ? colors.orange : colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.inventoryAlerts,
                        style: AppleTypography.body
                            .copyWith(color: colors.secondaryLabel)),
                  ),
                  Text('$alerts',
                      style: AppleTypography.title3.copyWith(
                          color: alerts > 0 ? colors.orange : colors.label,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppleChip(
                    label: l.repairsFilterAll,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null)),
                for (final s in [StockLevel.out, StockLevel.low, StockLevel.ok])
                  AppleChip(
                      label: s.label(l),
                      selected: _filter == s,
                      onTap: () => setState(() => _filter = s)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: shown.isEmpty
                ? _Empty(l: l)
                : AppleListSection(
                    children: [
                      for (final item in shown)
                        _StockRow(
                          item: item,
                          colors: colors,
                          onDelta: (d) => ref
                              .read(catalogProvider.notifier)
                              .adjustVariantStock(item.variant.id, d),
                          onReorder:
                              _levelOf(item.variant.stock) == StockLevel.ok
                                  ? null
                                  : () => _reorder(item),
                          onOpen: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                      productId: item.product.id))),
                        ),
                    ],
                  ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({
    required this.item,
    required this.colors,
    required this.onDelta,
    required this.onOpen,
    this.onReorder,
  });

  final _Item item;
  final AppleColors colors;
  final ValueChanged<int> onDelta;
  final VoidCallback onOpen;
  final VoidCallback? onReorder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = item.variant;
    final level = _levelOf(v.stock);
    final title = v.attributes.isEmpty
        ? item.product.name
        : '${item.product.name} — ${v.label}';

    return Padding(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppleTypography.body.copyWith(color: colors.label)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      AppleBadge(label: level.label(l), color: level.color(colors)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text('SKU ${v.sku}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppleTypography.footnote
                                .copyWith(color: colors.secondaryLabel)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (onReorder != null)
            Tooltip(
              message: l.inventoryReorder,
              child: GestureDetector(
                onTap: onReorder,
                child: Container(
                  margin: const EdgeInsetsDirectional.only(end: 6),
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: context.accentColor.withValues(alpha: 0.14),
                    shape: AppleRadii.shape(AppleRadii.sm),
                  ),
                  child: Icon(Icons.add_shopping_cart,
                      size: 16, color: context.accentColor),
                ),
              ),
            ),
          _stepBtn(Icons.remove, () => onDelta(-1)),
          SizedBox(
            width: 32,
            child: Text('${v.stock}',
                textAlign: TextAlign.center,
                style: AppleTypography.headline.copyWith(
                    color: level == StockLevel.ok
                        ? colors.label
                        : level.color(colors))),
          ),
          _stepBtn(Icons.add, () => onDelta(1)),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
              color: colors.fill, shape: AppleRadii.shape(AppleRadii.sm)),
          child: Icon(icon, size: 16, color: colors.label),
        ),
      );
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
          Icon(Icons.inventory_2_outlined,
              size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.inventoryEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          const SizedBox(height: 4),
          Text(l.inventoryEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
        ],
      ),
    );
  }
}
