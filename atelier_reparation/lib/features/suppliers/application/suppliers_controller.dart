import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/supplier_mapper.dart';
import '../domain/supplier.dart';

final supplierStoreProvider = Provider<CollectionStore<Supplier>>(
  (ref) =>
      CollectionStore<Supplier>(ref.watch(localStoreProvider), SupplierMapper()),
);

/// Fournisseurs, adossés au stockage local (SQLite / mémoire).
class SuppliersController extends Notifier<List<Supplier>> {
  CollectionStore<Supplier> get _store => ref.read(supplierStoreProvider);

  @override
  List<Supplier> build() {
    _store.seedIfEmpty(sampleSuppliers);
    return _store.loadAll();
  }

  void add(Supplier s) {
    _store.upsert(s);
    state = [s, ...state];
  }

  void update(Supplier s) {
    _store.upsert(s);
    state = [for (final e in state) if (e.id == s.id) s else e];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final e in state) if (e.id != id) e];
  }
}

final suppliersProvider =
    NotifierProvider<SuppliersController, List<Supplier>>(SuppliersController.new);
