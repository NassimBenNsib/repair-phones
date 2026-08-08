import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/taxonomy/taxonomy_controller.dart';
import '../../../core/taxonomy/taxonomy_node.dart';
import '../domain/product_category_node.dart';
import 'catalog_controller.dart';

/// Taxonomie du catalogue : instance du moteur générique (collection
/// `product_categories`), avec réassignation des produits pour la fusion.
class ProductCategoriesController extends TaxonomyController {
  @override
  String get collection => 'product_categories';

  @override
  List<TaxonomyNode> get seed => seedProductCategories;

  @override
  void reassignEntities(String fromId, String toId) =>
      ref.read(catalogProvider.notifier).reassignCategory(fromId, toId);
}

final productCategoriesProvider =
    NotifierProvider<TaxonomyController, List<TaxonomyNode>>(
        ProductCategoriesController.new);
