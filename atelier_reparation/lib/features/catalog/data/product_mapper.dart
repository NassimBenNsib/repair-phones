import '../../../core/data/local_store.dart';
import '../domain/product.dart';

/// (Dé)sérialisation d'un [Product] (avec options et variantes) pour le stockage.
class ProductMapper implements EntityMapper<Product> {
  @override
  String get collection => 'products';

  @override
  String idOf(Product p) => p.id;

  @override
  Map<String, Object?> toJson(Product p) => {
        'id': p.id,
        'name': p.name,
        'brand': p.brand,
        'categoryId': p.categoryId,
        'sourcing': [
          for (final s in p.sourcing)
            {
              'supplierId': s.supplierId,
              'purchasePrice': s.purchasePrice,
              'supplierRef': s.supplierRef,
              'leadTimeDays': s.leadTimeDays,
              'preferred': s.preferred,
            },
        ],
        'facets': p.facets,
        'options': [
          for (final o in p.options) {'name': o.name, 'values': o.values},
        ],
        'variants': [
          for (final v in p.variants)
            {
              'id': v.id,
              'sku': v.sku,
              'attributes': v.attributes,
              'price': v.price,
              'stock': v.stock,
            },
        ],
      };

  @override
  Product fromJson(Map<String, Object?> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        brand: j['brand'] as String? ?? '',
        // Migration : ancien champ enum `category` → `categoryId` (l'id de nœud
        // reprend l'ancien nom d'énumération), défaut `part`.
        categoryId: (j['categoryId'] ?? j['category'] ?? 'part') as String,
        // Migration : ancien `supplierIds` (liste d'ids) → approvisionnements
        // sans prix ; sinon lecture directe de `sourcing`.
        sourcing: j['sourcing'] != null
            ? [
                for (final s in (j['sourcing'] as List))
                  _sourcing(s as Map),
              ]
            : [
                for (final id in (j['supplierIds'] as List? ?? const []))
                  ProductSourcing(supplierId: id.toString()),
              ],
        facets: {
          for (final e in (j['facets'] as Map? ?? const {}).entries)
            e.key.toString(): e.value.toString(),
        },
        options: [
          for (final o in (j['options'] as List? ?? const []))
            ProductOption(
              name: (o as Map)['name'].toString(),
              values: [for (final x in (o['values'] as List? ?? const [])) x.toString()],
            ),
        ],
        variants: [
          for (final v in (j['variants'] as List? ?? const [])) _variant(v as Map),
        ],
      );

  ProductSourcing _sourcing(Map s) => ProductSourcing(
        supplierId: s['supplierId'].toString(),
        purchasePrice: (s['purchasePrice'] as num?)?.toDouble(),
        supplierRef: s['supplierRef'] as String?,
        leadTimeDays: (s['leadTimeDays'] as num?)?.toInt(),
        preferred: s['preferred'] as bool? ?? false,
      );

  ProductVariant _variant(Map v) => ProductVariant(
        id: v['id'].toString(),
        sku: v['sku'].toString(),
        attributes: {
          for (final e in (v['attributes'] as Map? ?? const {}).entries)
            e.key.toString(): e.value.toString(),
        },
        price: (v['price'] as num).toDouble(),
        stock: (v['stock'] as num).toInt(),
      );
}
