import '../../../core/taxonomy/taxonomy_node.dart';

/// Facettes du catalogue (classification multi-axes, indépendante de l'arbre des
/// catégories) : chaque **racine** est une dimension (Marque, Qualité…) et ses
/// **enfants** sont les valeurs autorisées.
///
/// Un produit stocke `facets : Map<dimensionId, valeurId>`.
const List<TaxonomyNode> seedProductFacets = [
  // Dimension « Marque ».
  TaxonomyNode(id: 'brand', name: 'Marque', iconKey: 'tools', order: 0),
  TaxonomyNode(id: 'brand-apple', name: 'Apple', parentId: 'brand'),
  TaxonomyNode(id: 'brand-samsung', name: 'Samsung', parentId: 'brand'),
  TaxonomyNode(id: 'brand-xiaomi', name: 'Xiaomi', parentId: 'brand'),
  // Dimension « Qualité ».
  TaxonomyNode(id: 'quality', name: 'Qualité', iconKey: 'tools', order: 1),
  TaxonomyNode(id: 'quality-oem', name: 'OEM', parentId: 'quality'),
  TaxonomyNode(id: 'quality-compat', name: 'Compatible', parentId: 'quality'),
];
