import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';

/// Configuration de l'assistant : clé API Anthropic (fournie par l'utilisateur)
/// et modèle. Stockée localement ; la clé n'est jamais journalisée.
class AssistantConfig {
  const AssistantConfig({
    this.apiKey = '',
    this.model = 'claude-haiku-4-5-20251001',
  });

  final String apiKey;
  final String model;

  bool get hasKey => apiKey.isNotEmpty;

  AssistantConfig copyWith({String? apiKey, String? model}) => AssistantConfig(
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
      );

  Map<String, Object?> toJson() =>
      {'id': 'default', 'apiKey': apiKey, 'model': model};

  factory AssistantConfig.fromJson(Map<String, Object?> j) => AssistantConfig(
        apiKey: j['apiKey'] as String? ?? '',
        model: j['model'] as String? ?? 'claude-haiku-4-5-20251001',
      );
}

class _AssistantMapper implements EntityMapper<AssistantConfig> {
  @override
  String get collection => 'assistant';
  @override
  String idOf(AssistantConfig c) => 'default';
  @override
  Map<String, Object?> toJson(AssistantConfig c) => c.toJson();
  @override
  AssistantConfig fromJson(Map<String, Object?> j) =>
      AssistantConfig.fromJson(j);
}

final _assistantStoreProvider = Provider<CollectionStore<AssistantConfig>>(
  (ref) => CollectionStore<AssistantConfig>(
      ref.watch(localStoreProvider), _AssistantMapper()),
);

class AssistantConfigController extends Notifier<AssistantConfig> {
  CollectionStore<AssistantConfig> get _store =>
      ref.read(_assistantStoreProvider);

  @override
  AssistantConfig build() {
    final all = _store.loadAll();
    return all.isEmpty ? const AssistantConfig() : all.first;
  }

  void save(AssistantConfig config) {
    _store.upsert(config);
    state = config;
  }
}

final assistantConfigProvider =
    NotifierProvider<AssistantConfigController, AssistantConfig>(
        AssistantConfigController.new);
