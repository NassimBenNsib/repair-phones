import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/integration_mapper.dart';
import '../domain/integration.dart';

final integrationStoreProvider = Provider<CollectionStore<Integration>>(
  (ref) =>
      CollectionStore<Integration>(ref.watch(localStoreProvider), IntegrationMapper()),
);

/// Configuration des intégrations tierces, persistée localement.
class IntegrationsController extends Notifier<List<Integration>> {
  CollectionStore<Integration> get _store => ref.read(integrationStoreProvider);

  @override
  List<Integration> build() => _store.loadAll();

  /// État d'une intégration (valeur par défaut si jamais configurée).
  Integration of(IntegrationKind kind) {
    for (final i in state) {
      if (i.kind == kind) return i;
    }
    return Integration(kind: kind);
  }

  void save(Integration i) {
    _store.upsert(i);
    final exists = state.any((x) => x.id == i.id);
    state = exists
        ? [for (final x in state) if (x.id == i.id) i else x]
        : [...state, i];
  }
}

final integrationsProvider =
    NotifierProvider<IntegrationsController, List<Integration>>(
        IntegrationsController.new);
