import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/client_mapper.dart';
import '../domain/client.dart';

/// Vue typée de la collection « clients » sur le stockage local.
final clientStoreProvider = Provider<CollectionStore<Client>>(
  (ref) => CollectionStore<Client>(ref.watch(localStoreProvider), ClientMapper()),
);

/// Contrôleur des clients, adossé au stockage local (SQLite / mémoire).
///
/// Reste un `Notifier<List<Client>>` synchrone : le stockage local l'est, donc
/// les écrans ne changent pas (pas d'`AsyncValue`).
class ClientsController extends Notifier<List<Client>> {
  CollectionStore<Client> get _store => ref.read(clientStoreProvider);

  @override
  List<Client> build() {
    _store.seedIfEmpty(sampleClients);
    return _store.loadAll();
  }

  void add(Client client) {
    _store.upsert(client);
    state = [client, ...state];
  }

  void update(Client client) {
    _store.upsert(client);
    state = [
      for (final c in state) if (c.id == client.id) client else c,
    ];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final c in state) if (c.id != id) c];
  }

  Client? byName(String name) {
    for (final c in state) {
      if (c.name == name) return c;
    }
    return null;
  }
}

final clientsProvider =
    NotifierProvider<ClientsController, List<Client>>(ClientsController.new);
