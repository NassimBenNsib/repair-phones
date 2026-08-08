import 'package:flutter/material.dart';

import '../../../core/taxonomy/taxonomy_tree_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../application/catalog_controller.dart';
import '../application/product_categories_controller.dart';
import '../domain/product_category_node.dart';

/// Gestion des catégories du catalogue : écran de taxonomie générique paramétré
/// pour les produits.
class ProductCategoriesScreen extends StatelessWidget {
  const ProductCategoriesScreen({super.key});

  static const String routeName = 'product-categories';
  static const String routePath = '/product-categories';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TaxonomyTreeScreen(
      config: TaxonomyConfig(
        title: l.navCategories,
        provider: productCategoriesProvider,
        icons: kProductCategoryIcons,
        colors: kProductCategoryColors,
        countOf: (ref, ids) => ref
            .read(catalogProvider)
            .where((p) => ids.contains(p.categoryId))
            .length,
      ),
    );
  }
}
