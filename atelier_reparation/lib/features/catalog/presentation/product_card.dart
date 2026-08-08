import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../application/product_categories_controller.dart';
import '../domain/product.dart';
import '../domain/product_category_node.dart';

/// Carte produit du catalogue : icône teintée par catégorie, fourchette de prix,
/// nombre de variantes et stock total.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    ref.watch(productCategoriesProvider);
    final node =
        ref.read(productCategoriesProvider.notifier).byId(product.categoryId);
    final tint = node?.color ?? colors.secondaryLabel;
    final catIcon = node?.icon ?? Icons.inventory_2_outlined;
    final catName = node?.name ?? '';
    final price = product.singlePrice
        ? AppFormats.money(product.minPrice, decimals: 0)
        : '${AppFormats.number(product.minPrice)} – ${AppFormats.money(product.maxPrice)}';

    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: ShapeDecoration(
                  color: tint.withValues(alpha: 0.16),
                  shape: AppleRadii.shape(AppleRadii.md),
                ),
                child: Icon(catIcon, color: tint, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTypography.headline
                            .copyWith(color: colors.label)),
                    const SizedBox(height: 2),
                    Text(
                        catName.isEmpty
                            ? product.brand
                            : '${product.brand} · $catName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(context.chevronForward, size: 20, color: colors.tertiaryLabel),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AppleBadge(label: l.variantCount(product.variants.length), color: tint),
              const SizedBox(width: 8),
              AppleBadge(
                label: l.stockUnits(product.totalStock),
                color: product.totalStock > 0 ? colors.green : colors.red,
              ),
              const Spacer(),
              Text(price,
                  style: AppleTypography.subheadline.copyWith(
                      color: colors.label, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
