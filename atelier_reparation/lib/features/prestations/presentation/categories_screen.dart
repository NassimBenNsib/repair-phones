import 'package:flutter/material.dart';

import '../../../core/taxonomy/taxonomy_tree_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../application/categories_controller.dart';
import '../application/service_catalog_controller.dart';
import '../domain/service_category_node.dart';

/// Gestion des catégories de prestations : écran de taxonomie générique paramétré
/// pour les prestations.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const String routeName = 'service-categories';
  static const String routePath = '/service-categories';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TaxonomyTreeScreen(
      config: TaxonomyConfig(
        title: l.navCategories,
        provider: categoriesProvider,
        icons: kServiceCategoryIcons,
        colors: kCategoryColors,
        countOf: (ref, ids) => ref
            .read(serviceCatalogProvider)
            .where((s) => ids.contains(s.categoryId))
            .length,
      ),
    );
  }
}
