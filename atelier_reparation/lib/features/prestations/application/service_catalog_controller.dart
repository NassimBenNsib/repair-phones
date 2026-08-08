import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/service_mapper.dart';
import '../domain/service_template.dart';

final serviceStoreProvider = Provider<CollectionStore<ServiceTemplate>>(
  (ref) =>
      CollectionStore<ServiceTemplate>(ref.watch(localStoreProvider), ServiceMapper()),
);

/// Catalogue de prestations, adossé au stockage local.
class ServiceCatalogController extends Notifier<List<ServiceTemplate>> {
  int _seq = 0;
  CollectionStore<ServiceTemplate> get _store => ref.read(serviceStoreProvider);

  @override
  List<ServiceTemplate> build() {
    _store.seedIfEmpty(sampleServiceTemplates);
    return _store.loadAll();
  }

  /// Crée une prestation (id généré si absent) et l'enregistre.
  ServiceTemplate add({
    required String name,
    String description = '',
    required double price,
    String categoryId = 'other',
    int? durationMinutes,
    double? vatRate,
    double? cost,
  }) {
    final s = ServiceTemplate(
      id: 's-custom-${DateTime.now().microsecondsSinceEpoch}_${_seq++}',
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      durationMinutes: durationMinutes,
      vatRate: vatRate,
      cost: cost,
      createdAt: DateTime.now(),
    );
    _store.upsert(s);
    state = [s, ...state];
    return s;
  }

  void update(ServiceTemplate s) {
    _store.upsert(s);
    state = [for (final x in state) if (x.id == s.id) s else x];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final x in state) if (x.id != id) x];
  }

  /// Déplace toutes les prestations de [fromId] vers [toId]. Retourne le nombre
  /// de prestations déplacées.
  int reassignCategory(String fromId, String toId) {
    var moved = 0;
    state = [
      for (final s in state)
        if (s.categoryId == fromId)
          _persist(s.copyWith(categoryId: toId))
        else
          s,
    ];
    for (final s in state) {
      if (s.categoryId == toId) moved++;
    }
    return moved;
  }

  void toggleActive(String id) {
    state = [
      for (final x in state)
        if (x.id == id) _persist(x.copyWith(active: !x.active)) else x,
    ];
  }

  ServiceTemplate _persist(ServiceTemplate s) {
    _store.upsert(s);
    return s;
  }
}

final serviceCatalogProvider =
    NotifierProvider<ServiceCatalogController, List<ServiceTemplate>>(
        ServiceCatalogController.new);
