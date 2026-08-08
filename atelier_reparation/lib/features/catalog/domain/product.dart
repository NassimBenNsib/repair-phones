import 'package:flutter/foundation.dart';

/// Type d'option d'un produit (ex. « Couleur » → [Noir, Blanc]).
///
/// Les variantes sont les combinaisons de valeurs de ces options.
@immutable
class ProductOption {
  const ProductOption({required this.name, required this.values});
  final String name;
  final List<String> values;
}

/// Déclinaison concrète d'un produit : une combinaison d'attributs avec son
/// propre SKU, prix et stock.
@immutable
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.sku,
    required this.attributes,
    required this.price,
    required this.stock,
  });

  final String id;
  final String sku;

  /// Valeurs choisies par option, ex. `{Couleur: Noir, Qualité: OEM}`.
  final Map<String, String> attributes;
  final double price;
  final int stock;

  /// Libellé lisible ex. « Noir · OEM ».
  String get label =>
      attributes.values.isEmpty ? sku : attributes.values.join(' · ');

  ProductVariant copyWith({double? price, int? stock}) => ProductVariant(
        id: id,
        sku: sku,
        attributes: attributes,
        price: price ?? this.price,
        stock: stock ?? this.stock,
      );
}

/// Approvisionnement d'un produit chez un fournisseur : prix d'achat, référence
/// fournisseur, délai, et marqueur « préféré ».
@immutable
class ProductSourcing {
  const ProductSourcing({
    required this.supplierId,
    this.purchasePrice,
    this.supplierRef,
    this.leadTimeDays,
    this.preferred = false,
  });

  final String supplierId;
  final double? purchasePrice;
  final String? supplierRef;
  final int? leadTimeDays;
  final bool preferred;

  ProductSourcing copyWith({
    double? purchasePrice,
    bool clearPrice = false,
    String? supplierRef,
    bool clearRef = false,
    int? leadTimeDays,
    bool clearLead = false,
    bool? preferred,
  }) =>
      ProductSourcing(
        supplierId: supplierId,
        purchasePrice: clearPrice ? null : (purchasePrice ?? this.purchasePrice),
        supplierRef: clearRef ? null : (supplierRef ?? this.supplierRef),
        leadTimeDays: clearLead ? null : (leadTimeDays ?? this.leadTimeDays),
        preferred: preferred ?? this.preferred,
      );
}

/// Produit du catalogue : un modèle qui regroupe une ou plusieurs [variants].
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.options,
    required this.variants,
    this.sourcing = const [],
    this.facets = const {},
  });

  final String id;
  final String name;
  final String brand;

  /// Référence vers un [ProductCategoryNode] (ex-énumération `part/accessory/…`).
  final String categoryId;
  final List<ProductOption> options;
  final List<ProductVariant> variants;

  /// Approvisionnements (fournisseurs + prix d'achat/réf/délai). Une pièce a
  /// souvent plusieurs sources.
  final List<ProductSourcing> sourcing;

  /// Facettes multi-axes : `{dimensionId: valeurId}` (voir `product_facets`).
  final Map<String, String> facets;

  /// Ids des fournisseurs (dérivé des approvisionnements).
  List<String> get supplierIds => [for (final s in sourcing) s.supplierId];

  /// Approvisionnement préféré (marqué), sinon le premier, sinon `null`.
  ProductSourcing? get preferredSourcing {
    if (sourcing.isEmpty) return null;
    for (final s in sourcing) {
      if (s.preferred) return s;
    }
    return sourcing.first;
  }

  double get minPrice => variants.isEmpty
      ? 0
      : variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  double get maxPrice => variants.isEmpty
      ? 0
      : variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  int get totalStock => variants.fold(0, (s, v) => s + v.stock);
  bool get singlePrice => minPrice == maxPrice;

  Product copyWith({
    String? name,
    String? brand,
    String? categoryId,
    List<ProductOption>? options,
    List<ProductVariant>? variants,
    List<ProductSourcing>? sourcing,
    Map<String, String>? facets,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        categoryId: categoryId ?? this.categoryId,
        options: options ?? this.options,
        variants: variants ?? this.variants,
        sourcing: sourcing ?? this.sourcing,
        facets: facets ?? this.facets,
      );
}

/// Catalogue de démonstration.
final List<Product> sampleProducts = [
  Product(
    id: 'p1',
    name: 'Écran iPhone 13',
    brand: 'Apple',
    categoryId: 'part-screen',
    facets: const {'brand': 'brand-apple', 'quality': 'quality-oem'},
    sourcing: const [
      ProductSourcing(
          supplierId: 'seed-mobileparts', purchasePrice: 60, preferred: true),
      ProductSourcing(supplierId: 'seed-ifixfr', purchasePrice: 72),
    ],
    options: const [
      ProductOption(name: 'Qualité', values: ['OEM', 'Compatible']),
      ProductOption(name: 'Couleur', values: ['Noir', 'Blanc']),
    ],
    variants: const [
      ProductVariant(
          id: 'p1v1',
          sku: 'SCR-13-OEM-BLK',
          attributes: {'Qualité': 'OEM', 'Couleur': 'Noir'},
          price: 149,
          stock: 6),
      ProductVariant(
          id: 'p1v2',
          sku: 'SCR-13-CMP-BLK',
          attributes: {'Qualité': 'Compatible', 'Couleur': 'Noir'},
          price: 89,
          stock: 12),
      ProductVariant(
          id: 'p1v3',
          sku: 'SCR-13-OEM-WHT',
          attributes: {'Qualité': 'OEM', 'Couleur': 'Blanc'},
          price: 149,
          stock: 2),
    ],
  ),
  Product(
    id: 'p2',
    name: 'Batterie MacBook Air',
    brand: 'Apple',
    categoryId: 'part-battery',
    facets: const {'brand': 'brand-apple'},
    sourcing: const [
      ProductSourcing(supplierId: 'seed-ifixfr', purchasePrice: 90),
    ],
    options: const [
      ProductOption(name: 'Modèle', values: ['A2179', 'A2337 (M1)']),
    ],
    variants: const [
      ProductVariant(
          id: 'p2v1',
          sku: 'BAT-A2179',
          attributes: {'Modèle': 'A2179'},
          price: 129,
          stock: 4),
      ProductVariant(
          id: 'p2v2',
          sku: 'BAT-A2337',
          attributes: {'Modèle': 'A2337 (M1)'},
          price: 139,
          stock: 0),
    ],
  ),
  Product(
    id: 'p3',
    name: 'Coque renforcée',
    brand: 'Spigen',
    categoryId: 'accessory-case',
    sourcing: const [
      ProductSourcing(supplierId: 'seed-accessoires', purchasePrice: 8),
    ],
    options: const [
      ProductOption(name: 'Modèle', values: ['iPhone 13', 'iPhone 14']),
      ProductOption(name: 'Couleur', values: ['Noir', 'Transparent']),
    ],
    variants: const [
      ProductVariant(
          id: 'p3v1',
          sku: 'CASE-13-BLK',
          attributes: {'Modèle': 'iPhone 13', 'Couleur': 'Noir'},
          price: 19,
          stock: 25),
      ProductVariant(
          id: 'p3v2',
          sku: 'CASE-13-CLR',
          attributes: {'Modèle': 'iPhone 13', 'Couleur': 'Transparent'},
          price: 19,
          stock: 18),
    ],
  ),
  Product(
    id: 'p4',
    name: 'Diagnostic complet',
    brand: 'Atelier',
    categoryId: 'service',
    options: const [],
    variants: const [
      ProductVariant(
          id: 'p4v1',
          sku: 'SRV-DIAG',
          attributes: {},
          price: 25,
          stock: 999),
    ],
  ),
];
