import '../../../core/data/local_store.dart';
import '../domain/service_template.dart';

/// (Dé)sérialisation d'un [ServiceTemplate] pour le stockage local.
class ServiceMapper implements EntityMapper<ServiceTemplate> {
  @override
  String get collection => 'services';

  @override
  String idOf(ServiceTemplate s) => s.id;

  @override
  Map<String, Object?> toJson(ServiceTemplate s) => {
        'id': s.id,
        'name': s.name,
        'description': s.description,
        'price': s.price,
        'categoryId': s.categoryId,
        'durationMinutes': s.durationMinutes,
        'vatRate': s.vatRate,
        'cost': s.cost,
        'active': s.active,
        'createdAt': s.createdAt?.toIso8601String(),
      };

  @override
  ServiceTemplate fromJson(Map<String, Object?> j) => ServiceTemplate(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        price: (j['price'] as num).toDouble(),
        // Migration : ancien champ `category` (énum) → `categoryId`.
        categoryId:
            (j['categoryId'] ?? j['category'] ?? 'other') as String,
        durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
        vatRate: (j['vatRate'] as num?)?.toDouble(),
        cost: (j['cost'] as num?)?.toDouble(),
        active: (j['active'] as bool?) ?? true,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
      );
}
