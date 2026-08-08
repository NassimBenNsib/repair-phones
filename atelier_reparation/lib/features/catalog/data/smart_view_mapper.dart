import '../../../core/data/local_store.dart';
import '../domain/smart_view.dart';

/// (Dé)sérialisation d'une [SmartView] (règle imbriquée) pour le stockage local.
class SmartViewMapper implements EntityMapper<SmartView> {
  @override
  String get collection => 'product_smart_views';

  @override
  String idOf(SmartView v) => v.id;

  @override
  Map<String, Object?> toJson(SmartView v) => {
        'id': v.id,
        'name': v.name,
        'iconKey': v.iconKey,
        'colorHex': v.colorHex,
        'order': v.order,
        'active': v.active,
        'rule': v.rule.toJson(),
      };

  @override
  SmartView fromJson(Map<String, Object?> j) => SmartView(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        iconKey: j['iconKey'] as String? ?? 'other',
        colorHex: (j['colorHex'] as num?)?.toInt() ?? 0xFF0A84FF,
        order: (j['order'] as num?)?.toInt() ?? 0,
        active: j['active'] as bool? ?? true,
        rule: SmartRule.fromJson(
            (j['rule'] as Map?)?.cast<String, Object?>() ?? const {}),
      );
}
