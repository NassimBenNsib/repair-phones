import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/taxonomy/taxonomy_controller.dart';
import '../../../core/taxonomy/taxonomy_node.dart';
import '../domain/product_facets.dart';
import 'catalog_controller.dart';

/// Taxonomie des **facettes** du catalogue (Marque, Qualité…), sur le moteur
/// générique (collection `product_facets`). La fusion réaffecte la valeur de
/// facette portée par les produits.
class ProductFacetsController extends TaxonomyController {
  @override
  String get collection => 'product_facets';

  @override
  List<TaxonomyNode> get seed => seedProductFacets;

  @override
  void reassignEntities(String fromId, String toId) =>
      ref.read(catalogProvider.notifier).reassignFacetValue(fromId, toId);
}

final productFacetsProvider =
    NotifierProvider<TaxonomyController, List<TaxonomyNode>>(
        ProductFacetsController.new);
