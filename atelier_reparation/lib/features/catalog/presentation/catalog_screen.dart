import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/layout_prefs.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/taxonomy/taxonomy_controller.dart';
import '../../../core/taxonomy/taxonomy_tree_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/directory_views.dart';
import '../../../shared/widgets/apple/list_empty_state.dart';
import '../application/catalog_controller.dart';
import '../application/product_categories_controller.dart';
import '../application/product_facets_controller.dart';
import '../application/smart_views_controller.dart';
import '../domain/smart_view.dart';
import '../domain/product.dart';
import '../domain/product_category_node.dart';
import 'product_categories_screen.dart';
import 'product_detail_screen.dart';
import 'product_form.dart';
import 'smart_views_screen.dart';

/// Catalogue : recherche, filtre par catégorie (taxonomie, drill-down + rollup),
/// et affichage liste / grille / tableau (réglage partagé).
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  static const String routeName = 'catalog';
  static const String routePath = '/catalog';

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _query = '';
  String? _categoryId;
  final Map<String, String> _facetFilter = {}; // dimensionId → valeurId
  String? _smartId; // sélection intelligente active

  ClientsListStyle get _style =>
      ref.watch(settingsControllerProvider.select((s) => s.clientsListStyle));

  Widget _toggle() => DirectoryViewToggle(
        style: _style,
        onChanged: (v) =>
            ref.read(settingsControllerProvider.notifier).setClientsListStyle(v),
      );

  /// Ids couverts par le filtre : un nœud inclut **tous** ses descendants
  /// (rollup à profondeur illimitée).
  Set<String>? _catIds(TaxonomyController catCtrl) {
    if (_categoryId == null) return null;
    return {_categoryId!, ...catCtrl.descendantIds(_categoryId!)};
  }

  List<Product> _filter(List<Product> list, Set<String>? catIds) {
    final q = _query.trim().toLowerCase();
    final view =
        _smartId == null ? null : ref.read(smartViewsProvider.notifier).byId(_smartId!);
    return list.where((p) {
      final matchQ = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
      final matchCat = catIds == null || catIds.contains(p.categoryId);
      // Facettes : chaque dimension filtrée doit correspondre.
      final matchFacets =
          _facetFilter.entries.every((e) => p.facets[e.key] == e.value);
      // Sélection intelligente : règle satisfaite.
      final matchSmart = view == null || smartMatches(p, view.rule);
      return matchQ && matchCat && matchFacets && matchSmart;
    }).toList();
  }

  Widget _segmentBar(List<ProductCategoryNode> cats) {
    final l = AppLocalizations.of(context);
    final byId = {for (final c in cats) c.id: c};
    final top = cats.where((c) => c.parentId == null && c.active).toList();
    final selNode = _categoryId == null ? null : byId[_categoryId];
    final activeTop = selNode?.parentId ?? selNode?.id;
    final subs = activeTop == null
        ? const <ProductCategoryNode>[]
        : cats.where((c) => c.parentId == activeTop && c.active).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          AppleChip(
              label: l.repairsFilterAll,
              selected: _categoryId == null,
              onTap: () => setState(() => _categoryId = null)),
          for (final c in top)
            AppleChip(
                label: c.name,
                selected: activeTop == c.id,
                selectedColor: c.color,
                onTap: () => setState(
                    () => _categoryId = activeTop == c.id ? null : c.id)),
        ]),
      ),
      // Drill-down : sous-catégories de la catégorie active.
      if (subs.isNotEmpty)
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            AppleChip(
                label: l.repairsFilterAll,
                selected: _categoryId == activeTop,
                onTap: () => setState(() => _categoryId = activeTop)),
            for (final s in subs)
              AppleChip(
                  label: s.name,
                  selected: _categoryId == s.id,
                  selectedColor: s.color,
                  onTap: () => setState(() => _categoryId = s.id)),
          ]),
        ),
    ]);
  }

  String _priceText(Product p) => p.singlePrice
      ? AppFormats.money(p.minPrice, decimals: 0)
      : '${AppFormats.number(p.minPrice)} – ${AppFormats.money(p.maxPrice)}';

  List<DirColumn<Product>> _columns(
          AppLocalizations l, TaxonomyController cats) =>
      [
        DirColumn(
            label: l.productName,
            width: 200,
            leading: true,
            value: (p) => p.name,
            sortKey: (p) => p.name.toLowerCase()),
        DirColumn(
            label: l.productBrand,
            width: 120,
            value: (p) => p.brand,
            sortKey: (p) => p.brand.toLowerCase()),
        DirColumn(
            label: l.productCategory,
            width: 160,
            value: (p) => cats.path(p.categoryId),
            sortKey: (p) => cats.nameOf(p.categoryId).toLowerCase()),
        DirColumn(
            label: l.priceLabel,
            width: 120,
            value: _priceText,
            sortKey: (p) => p.minPrice),
        DirColumn(
            label: l.variantsLabel,
            width: 90,
            value: (p) => '${p.variants.length}',
            sortKey: (p) => p.variants.length),
        DirColumn(
            label: l.stockLabel,
            width: 90,
            value: (p) => '${p.totalStock}',
            sortKey: (p) => p.totalStock,
            color: (p, c) => p.totalStock > 0 ? c.green : c.red),
      ];

  /// Chips des sélections intelligentes (catégories dynamiques par règle).
  Widget _smartBar() {
    final colors = context.appleColors;
    final views = ref.watch(smartViewsProvider).where((v) => v.active).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    if (views.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${l.smartViews} :',
              style: AppleTypography.footnote
                  .copyWith(color: colors.secondaryLabel)),
          for (final v in views)
            AppleChip(
              label: v.name,
              selected: _smartId == v.id,
              selectedColor: v.color,
              onTap: () => setState(
                  () => _smartId = _smartId == v.id ? null : v.id),
            ),
        ],
      ),
    );
  }

  /// Chips de filtre par facette (une ligne par dimension).
  Widget _facetBar() {
    final colors = context.appleColors;
    final facets = ref.watch(productFacetsProvider);
    final dims = facets.where((n) => n.parentId == null && n.active).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    if (dims.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in dims)
          if (facets.any((n) => n.parentId == d.id && n.active))
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${d.name} :',
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                  for (final v
                      in facets.where((n) => n.parentId == d.id && n.active))
                    AppleChip(
                      label: v.name,
                      selected: _facetFilter[d.id] == v.id,
                      selectedColor: v.color,
                      onTap: () => setState(() => _facetFilter[d.id] == v.id
                          ? _facetFilter.remove(d.id)
                          : _facetFilter[d.id] = v.id),
                    ),
                ],
              ),
            ),
      ],
    );
  }

  /// Menu de gestion : catégories, facettes, sélections intelligentes.
  Future<void> _openManage() async {
    final l = AppLocalizations.of(context);
    final choice = await showAppleSelectionSheet<String>(
      context: context,
      title: l.catalogManage,
      selected: '',
      options: [
        AppleSheetOption('cat', l.navCategories,
            leading: const Icon(Icons.category_outlined)),
        AppleSheetOption('facets', l.productFacets,
            leading: const Icon(Icons.tune)),
        AppleSheetOption('smart', l.smartViews,
            leading: const Icon(Icons.bolt_outlined)),
      ],
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case 'cat':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ProductCategoriesScreen()));
      case 'facets':
        _openFacetsManager();
      case 'smart':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SmartViewsScreen()));
    }
  }

  void _openFacetsManager() {
    final l = AppLocalizations.of(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TaxonomyTreeScreen(
        config: TaxonomyConfig(
          title: l.productFacets,
          provider: productFacetsProvider,
          icons: kProductCategoryIcons,
          colors: kProductCategoryColors,
          countOf: (ref, ids) => ref
              .read(catalogProvider)
              .where((p) => p.facets.values.any(ids.contains))
              .length,
        ),
      ),
    ));
  }

  void _open(Product p) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProductDetailScreen(productId: p.id)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(catalogProvider);
    final cats = ref.watch(productCategoriesProvider);
    final catCtrl = ref.read(productCategoriesProvider.notifier);
    final byId = {for (final c in cats) c.id: c};
    final results = _filter(all, _catIds(catCtrl));
    final style = _style;

    return AppleScaffold(
      title: l.navCatalog,
      actions: [
        _toggle(),
        IconButton(
          onPressed: _openManage,
          icon: Icon(Icons.tune, color: context.accentColor),
          tooltip: l.catalogManage,
        ),
        IconButton(
          onPressed: _addProduct,
          icon: Icon(Icons.add, color: context.accentColor),
          tooltip: l.productNew,
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.catalogSearch,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _segmentBar(cats)),
        SliverToBoxAdapter(child: _smartBar()),
        SliverToBoxAdapter(child: _facetBar()),
        if (results.isEmpty)
          SliverToBoxAdapter(
            child: ListEmptyState(
              icon: all.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
              title: all.isEmpty ? l.catalogEmpty : l.listNoResults,
              subtitle: all.isEmpty
                  ? l.catalogEmptySubtitle
                  : l.listNoResultsSubtitle,
              actionLabel: all.isEmpty ? l.productNew : null,
              onAction: all.isEmpty ? _addProduct : null,
            ),
          )
        else if (style == ClientsListStyle.grid)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 132,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = results[i];
                  final node = byId[p.categoryId];
                  return DirectoryCard(
                    name: p.name,
                    title: p.name,
                    subtitle: node == null
                        ? p.brand
                        : '${p.brand} · ${node.name}',
                    badge: _priceText(p),
                    badgeColor: node?.color ?? context.appleColors.secondaryLabel,
                    onTap: () => _open(p),
                  );
                },
                childCount: results.length,
              ),
            ),
          )
        else if (style == ClientsListStyle.table)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: DirectoryTable<Product>(
                items: results,
                columns: _columns(l, catCtrl),
                avatarName: (p) => p.name,
                onTap: _open,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(
                children: [
                  for (final p in results)
                    _ProductRow(
                      product: p,
                      node: byId[p.categoryId],
                      price: _priceText(p),
                      onTap: () => _open(p),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addProduct() async {
    final data = await showAddProductSheet(context);
    if (data == null) return;
    ref.read(catalogProvider.notifier).addProduct(
          name: data.name,
          brand: data.brand,
          categoryId: data.categoryId,
          price: data.price,
          stock: data.stock,
        );
  }
}

/// Ligne compacte de produit (mode liste) : pastille catégorie, nom, marque et
/// prix + stock.
class _ProductRow extends StatelessWidget {
  const _ProductRow(
      {required this.product,
      required this.node,
      required this.price,
      required this.onTap});

  final Product product;
  final ProductCategoryNode? node;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final tint = node?.color ?? colors.secondaryLabel;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: ShapeDecoration(
                color: tint.withValues(alpha: 0.16),
                shape: AppleRadii.shape(AppleRadii.sm),
              ),
              child: Icon(node?.icon ?? Icons.inventory_2_outlined,
                  size: 18, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.body.copyWith(color: colors.label)),
                  Text(
                      node == null
                          ? product.brand
                          : '${product.brand} · ${node!.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(price,
                style: AppleTypography.subheadline.copyWith(
                    color: colors.label, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(context.chevronForward, size: 20, color: colors.tertiaryLabel),
          ]),
        ),
      ),
    );
  }
}
