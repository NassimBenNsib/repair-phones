import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/taxonomy/taxonomy_controller.dart';
import '../../../core/taxonomy/taxonomy_node.dart';
import '../domain/service_category_node.dart';
import 'service_catalog_controller.dart';

/// Taxonomie des prestations : instance du moteur générique (collection
/// `service_categories`), avec réassignation des prestations pour la fusion.
class CategoriesController extends TaxonomyController {
  @override
  String get collection => 'service_categories';

  @override
  List<TaxonomyNode> get seed => seedServiceCategories;

  @override
  void reassignEntities(String fromId, String toId) =>
      ref.read(serviceCatalogProvider.notifier).reassignCategory(fromId, toId);
}

final categoriesProvider =
    NotifierProvider<TaxonomyController, List<TaxonomyNode>>(
        CategoriesController.new);
