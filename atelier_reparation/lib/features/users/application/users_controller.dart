import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/user_mapper.dart';
import '../domain/app_user.dart';

final userStoreProvider = Provider<CollectionStore<AppUser>>(
  (ref) => CollectionStore<AppUser>(ref.watch(localStoreProvider), UserMapper()),
);

/// Comptes utilisateurs, adossés au stockage local.
class UsersController extends Notifier<List<AppUser>> {
  CollectionStore<AppUser> get _store => ref.read(userStoreProvider);

  @override
  List<AppUser> build() {
    _store.seedIfEmpty(seedUsers);
    return _store.loadAll();
  }

  void add(AppUser u) {
    _store.upsert(u);
    state = [u, ...state];
  }

  void update(AppUser u) {
    _store.upsert(u);
    state = [for (final x in state) if (x.id == u.id) u else x];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final x in state) if (x.id != id) x];
  }

  /// Horodate la dernière connexion (sans écrire au journal — non audité).
  void touchLastLogin(String id) {
    final now = DateTime.now();
    state = [
      for (final u in state)
        if (u.id == id) _persist(u.copyWith(lastLogin: now)) else u,
    ];
  }

  AppUser _persist(AppUser u) {
    _store.upsert(u);
    return u;
  }

  AppUser? byId(String id) {
    for (final u in state) {
      if (u.id == id) return u;
    }
    return null;
  }

  AppUser? byEmail(String email) {
    final e = email.trim().toLowerCase();
    for (final u in state) {
      if (u.email.toLowerCase() == e) return u;
    }
    return null;
  }
}

final usersProvider =
    NotifierProvider<UsersController, List<AppUser>>(UsersController.new);
