import '../../../core/data/local_store.dart';
import '../domain/integration.dart';

/// (Dé)sérialisation d'une [Integration] pour le stockage local.
class IntegrationMapper implements EntityMapper<Integration> {
  @override
  String get collection => 'integrations';

  @override
  String idOf(Integration i) => i.id;

  @override
  Map<String, Object?> toJson(Integration i) => {
        'id': i.id,
        'enabled': i.enabled,
        'config': i.config,
      };

  @override
  Integration fromJson(Map<String, Object?> j) {
    final kind = IntegrationKind.values.firstWhere(
      (k) => k.name == j['id'],
      orElse: () => IntegrationKind.flouci,
    );
    final rawConfig = j['config'];
    final config = <String, String>{};
    if (rawConfig is Map) {
      rawConfig.forEach((k, v) => config['$k'] = '$v');
    }
    return Integration(
      kind: kind,
      enabled: j['enabled'] as bool? ?? false,
      config: config,
    );
  }
}
