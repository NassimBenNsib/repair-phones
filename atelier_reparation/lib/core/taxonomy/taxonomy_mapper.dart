import '../data/local_store.dart';
import 'taxonomy_node.dart';

/// (Dé)sérialisation générique d'un [TaxonomyNode]. La collection est fournie
/// par le domaine (`product_categories`, `service_categories`, …).
class TaxonomyMapper implements EntityMapper<TaxonomyNode> {
  TaxonomyMapper(this.collection);

  @override
  final String collection;

  @override
  String idOf(TaxonomyNode n) => n.id;

  @override
  Map<String, Object?> toJson(TaxonomyNode n) => {
        'id': n.id,
        'name': n.name,
        'parentId': n.parentId,
        'iconKey': n.iconKey,
        'colorHex': n.colorHex,
        'order': n.order,
        'code': n.code,
        'description': n.description,
        'active': n.active,
      };

  @override
  TaxonomyNode fromJson(Map<String, Object?> j) => TaxonomyNode(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        parentId: j['parentId'] as String?,
        iconKey: j['iconKey'] as String? ?? 'other',
        colorHex: (j['colorHex'] as num?)?.toInt() ?? 0xFF8E8E93,
        order: (j['order'] as num?)?.toInt() ?? 0,
        code: j['code'] as String?,
        description: j['description'] as String?,
        active: j['active'] as bool? ?? true,
      );
}
