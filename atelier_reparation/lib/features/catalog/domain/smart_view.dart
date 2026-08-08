import 'package:flutter/material.dart';

import 'product.dart';

/// Seuil de « stock bas » pour les sélections intelligentes (constante locale
/// pour éviter une dépendance vers l'inventaire).
const int kSmartLowStock = 3;

/// Règle d'une sélection intelligente : conditions combinées en **ET**. Chaque
/// champ nul = pas de contrainte. Compacte et évaluable en mémoire.
@immutable
class SmartRule {
  const SmartRule({
    this.stock, // 'out' | 'low'
    this.priceMax,
    this.priceMin,
    this.facetValueId,
    this.brand,
  });

  final String? stock;
  final double? priceMax;
  final double? priceMin;
  final String? facetValueId;
  final String? brand;

  bool get isEmpty =>
      stock == null &&
      priceMax == null &&
      priceMin == null &&
      facetValueId == null &&
      (brand == null || brand!.isEmpty);

  SmartRule copyWith({
    String? stock,
    bool clearStock = false,
    double? priceMax,
    bool clearPriceMax = false,
    double? priceMin,
    bool clearPriceMin = false,
    String? facetValueId,
    bool clearFacet = false,
    String? brand,
    bool clearBrand = false,
  }) =>
      SmartRule(
        stock: clearStock ? null : (stock ?? this.stock),
        priceMax: clearPriceMax ? null : (priceMax ?? this.priceMax),
        priceMin: clearPriceMin ? null : (priceMin ?? this.priceMin),
        facetValueId: clearFacet ? null : (facetValueId ?? this.facetValueId),
        brand: clearBrand ? null : (brand ?? this.brand),
      );

  Map<String, Object?> toJson() => {
        'stock': stock,
        'priceMax': priceMax,
        'priceMin': priceMin,
        'facetValueId': facetValueId,
        'brand': brand,
      };

  factory SmartRule.fromJson(Map<String, Object?> j) => SmartRule(
        stock: j['stock'] as String?,
        priceMax: (j['priceMax'] as num?)?.toDouble(),
        priceMin: (j['priceMin'] as num?)?.toDouble(),
        facetValueId: j['facetValueId'] as String?,
        brand: j['brand'] as String?,
      );
}

/// Évalue si un produit satisfait une règle (toutes les conditions présentes).
bool smartMatches(Product p, SmartRule r) {
  if (r.stock == 'out' && p.totalStock != 0) return false;
  if (r.stock == 'low' &&
      !(p.totalStock > 0 && p.totalStock <= kSmartLowStock)) {
    return false;
  }
  if (r.priceMax != null && p.minPrice > r.priceMax!) return false;
  if (r.priceMin != null && p.maxPrice < r.priceMin!) return false;
  if (r.facetValueId != null && !p.facets.values.contains(r.facetValueId)) {
    return false;
  }
  if (r.brand != null &&
      r.brand!.isNotEmpty &&
      !p.brand.toLowerCase().contains(r.brand!.toLowerCase())) {
    return false;
  }
  return true;
}

/// Sélection intelligente : une « catégorie » dynamique définie par une règle,
/// dont l'appartenance est **calculée**, jamais stockée sur les produits.
@immutable
class SmartView {
  const SmartView({
    required this.id,
    required this.name,
    this.iconKey = 'other',
    this.colorHex = 0xFF0A84FF,
    this.order = 0,
    this.active = true,
    required this.rule,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorHex;
  final int order;
  final bool active;
  final SmartRule rule;

  Color get color => Color(colorHex);

  SmartView copyWith({
    String? name,
    String? iconKey,
    int? colorHex,
    int? order,
    bool? active,
    SmartRule? rule,
  }) =>
      SmartView(
        id: id,
        name: name ?? this.name,
        iconKey: iconKey ?? this.iconKey,
        colorHex: colorHex ?? this.colorHex,
        order: order ?? this.order,
        active: active ?? this.active,
        rule: rule ?? this.rule,
      );
}

/// Sélections de démonstration.
const List<SmartView> seedSmartViews = [
  SmartView(
      id: 'sv-out',
      name: 'En rupture',
      iconKey: 'other',
      colorHex: 0xFFFF375F,
      order: 0,
      rule: SmartRule(stock: 'out')),
  SmartView(
      id: 'sv-cheap',
      name: 'Petit prix',
      iconKey: 'other',
      colorHex: 0xFF34C759,
      order: 1,
      rule: SmartRule(priceMax: 20)),
  SmartView(
      id: 'sv-lowstock',
      name: 'Stock bas',
      iconKey: 'other',
      colorHex: 0xFFFF9500,
      order: 2,
      rule: SmartRule(stock: 'low')),
];
