import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../suppliers/application/suppliers_controller.dart';
import '../../suppliers/presentation/supplier_detail.dart';
import '../application/catalog_controller.dart';
import '../application/product_categories_controller.dart';
import '../application/product_facets_controller.dart';
import '../domain/product.dart';
import '../domain/product_category_node.dart';
import 'product_form.dart';

/// Détail d'un produit : en-tête, options, liste des variantes et ajout.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    // Lecture réactive : l'écran se met à jour quand une variante est ajoutée.
    final products = ref.watch(catalogProvider);
    Product? product;
    for (final p in products) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: colors.groupedBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(context.backIcon, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(child: Text(l.catalogEmpty)),
      );
    }

    ref.watch(productCategoriesProvider);
    final node =
        ref.read(productCategoriesProvider.notifier).byId(product.categoryId);
    final tint = node?.color ?? colors.secondaryLabel;
    final catIcon = node?.icon ?? Icons.inventory_2_outlined;
    final catName = node?.name ?? '';
    final suppliersById = {
      for (final s in ref.watch(suppliersProvider)) s.id: s
    };

    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(context.backIcon, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.actionEdit,
            onPressed: () => _edit(context, ref, product!),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // En-tête.
          AppleCard(
            elevated: true,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: tint.withValues(alpha: 0.16),
                    shape: AppleRadii.shape(AppleRadii.lg),
                  ),
                  child: Icon(catIcon, color: tint, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: AppleTypography.title3
                              .copyWith(color: colors.label)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          AppleBadge(label: catName, color: tint),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(product.brand,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppleTypography.subheadline
                                    .copyWith(color: colors.secondaryLabel)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fournisseurs (approvisionnements : prix d'achat + préféré).
          if (product.sourcing.isNotEmpty) ...[
            SectionHeader(
                title: l.navSuppliers,
                padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
            AppleListSection(children: [
              for (final s in product.sourcing)
                if (suppliersById[s.supplierId] != null)
                  _SourcingRow(
                    name: suppliersById[s.supplierId]!.name,
                    sourcing: s,
                    isBest: _bestPrice(product) != null &&
                        s.purchasePrice == _bestPrice(product),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SupplierDetailScreen(
                            supplier: suppliersById[s.supplierId]!))),
                  ),
            ]),
          ],

          // Facettes (classification multi-axes).
          if (product.facets.isNotEmpty) ...[
            SectionHeader(
                title: l.productFacets,
                padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
            Builder(builder: (context) {
              final fctrl = ref.read(productFacetsProvider.notifier);
              ref.watch(productFacetsProvider);
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final valueId in product!.facets.values)
                    if (fctrl.byId(valueId) != null)
                      AppleBadge(
                          label: fctrl.byId(valueId)!.name,
                          color: fctrl.byId(valueId)!.color),
                ],
              );
            }),
          ],

          // Options (types de déclinaison).
          if (product.options.isNotEmpty) ...[
            for (final option in product.options) ...[
              SectionHeader(
                  title: option.name,
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in option.values)
                    AppleBadge(label: v, color: colors.secondaryLabel),
                ],
              ),
            ],
          ],

          // Variantes.
          SectionHeader(
            title: l.productVariants,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8),
          ),
          AppleListSection(
            children: [
              for (final v in product.variants)
                AppleListRow(
                  leadingIcon: Icons.sell_outlined,
                  leadingTint: tint,
                  title: v.label,
                  subtitle: '${l.skuLabel} ${v.sku} · ${l.stockLabel}: ${v.stock}',
                  trailingText: AppFormats.money(v.price, decimals: 0),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppleButton(
            label: l.variantNew,
            icon: Icons.add,
            style: AppleButtonStyle.tinted,
            expand: true,
            onPressed: () => _addVariant(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _addVariant(BuildContext context, WidgetRef ref) async {
    final data = await showAddVariantSheet(context);
    if (data == null) return;
    ref.read(catalogProvider.notifier).addVariant(
          productId,
          label: data.label,
          price: data.price,
          stock: data.stock,
        );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Product product) async {
    final data = await showEditProductSheet(context, product);
    if (data == null) return;
    ref.read(catalogProvider.notifier).updateProduct(
          product.id,
          name: data.name,
          brand: data.brand,
          categoryId: data.categoryId,
          sourcing: data.sourcing,
          facets: data.facets,
        );
  }
}

/// Meilleur (plus bas) prix d'achat parmi les approvisionnements, ou `null`.
double? _bestPrice(Product p) {
  double? best;
  for (final s in p.sourcing) {
    final v = s.purchasePrice;
    if (v == null) continue;
    if (best == null || v < best) best = v;
  }
  return best;
}

/// Ligne d'approvisionnement : fournisseur, prix d'achat, préféré, meilleur prix.
class _SourcingRow extends StatelessWidget {
  const _SourcingRow({
    required this.name,
    required this.sourcing,
    required this.isBest,
    required this.onTap,
  });

  final String name;
  final ProductSourcing sourcing;
  final bool isBest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(children: [
            if (sourcing.preferred)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: Icon(Icons.star, size: 16, color: context.accentColor),
              ),
            Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppleTypography.body.copyWith(color: colors.label)),
            ),
            if (isBest) ...[
              AppleBadge(label: l.sourcingBestPrice, color: colors.green),
              const SizedBox(width: 8),
            ],
            Text(
                sourcing.purchasePrice == null
                    ? '—'
                    : AppFormats.money(sourcing.purchasePrice!, decimals: 0),
                style: AppleTypography.subheadline.copyWith(
                    color: colors.label, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(context.chevronForward, size: 20, color: colors.tertiaryLabel),
          ]),
        ),
      ),
    );
  }
}
