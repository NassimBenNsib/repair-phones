import 'package:flutter/foundation.dart';

/// Ligne de document (commande, devis, facture) : quantité × prix unitaire.
///
/// `productId`/`variantId` relient facultativement la ligne au catalogue
/// (pour l'incrément de stock à la réception).
@immutable
class LineItem {
  const LineItem({
    required this.id,
    required this.label,
    this.qty = 1,
    this.unitPrice = 0,
    this.taxRate = 0.20,
    this.productId,
    this.variantId,
  });

  final String id;
  final String label;
  final double qty;
  final double unitPrice;
  final double taxRate;
  final String? productId;
  final String? variantId;

  double get totalHT => qty * unitPrice;

  LineItem copyWith({double? qty, double? unitPrice}) => LineItem(
        id: id,
        label: label,
        qty: qty ?? this.qty,
        unitPrice: unitPrice ?? this.unitPrice,
        taxRate: taxRate,
        productId: productId,
        variantId: variantId,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
        'qty': qty,
        'unitPrice': unitPrice,
        'taxRate': taxRate,
        'productId': productId,
        'variantId': variantId,
      };

  factory LineItem.fromJson(Map<String, Object?> j) => LineItem(
        id: j['id'] as String,
        label: j['label'] as String? ?? '',
        qty: (j['qty'] as num?)?.toDouble() ?? 1,
        unitPrice: (j['unitPrice'] as num?)?.toDouble() ?? 0,
        taxRate: (j['taxRate'] as num?)?.toDouble() ?? 0.20,
        productId: j['productId'] as String?,
        variantId: j['variantId'] as String?,
      );
}
