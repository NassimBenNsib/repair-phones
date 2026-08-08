import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/smart_view_mapper.dart';
import '../domain/product.dart';
import '../domain/smart_view.dart';

final smartViewStoreProvider = Provider<CollectionStore<SmartView>>(
  (ref) =>
      CollectionStore<SmartView>(ref.watch(localStoreProvider), SmartViewMapper()),
);

/// Sélections intelligentes du catalogue (catégories dynamiques par règle).
class SmartViewsController extends Notifier<List<SmartView>> {
  CollectionStore<SmartView> get _store => ref.read(smartViewStoreProvider);

  @override
  List<SmartView> build() {
    _store.seedIfEmpty(seedSmartViews);
    return _store.loadAll()..sort((a, b) => a.order.compareTo(b.order));
  }

  SmartView? byId(String id) {
    for (final v in state) {
      if (v.id == id) return v;
    }
    return null;
  }

  void add(SmartView v) {
    _store.upsert(v);
    state = [...state, v]..sort((a, b) => a.order.compareTo(b.order));
  }

  void update(SmartView v) {
    _store.upsert(v);
    state = [for (final x in state) if (x.id == v.id) v else x]
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final v in state) if (v.id != id) v];
  }

  /// Produits satisfaisant la règle de la sélection [viewId].
  List<Product> productsFor(String viewId, List<Product> products) {
    final v = byId(viewId);
    if (v == null) return const [];
    return products.where((p) => smartMatches(p, v.rule)).toList();
  }
}

final smartViewsProvider =
    NotifierProvider<SmartViewsController, List<SmartView>>(
        SmartViewsController.new);
