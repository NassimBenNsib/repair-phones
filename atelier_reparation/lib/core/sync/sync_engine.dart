import '../data/local_store.dart';

/// Bilan d'une passe de synchronisation.
class SyncResult {
  const SyncResult({required this.pulled, required this.pushed});
  final int pulled;
  final int pushed;
}

/// Moteur de synchronisation delta bidirectionnel entre un store local et un
/// store distant (tous deux [LocalStore]).
///
/// Politique : « dernier écrit gagne » par `updatedAt`, tombstones propagés.
/// Idempotent — appeler à répétition converge. Le provider distant concret
/// (Supabase/Firebase/REST) reste à implémenter ; voir [NoopRemoteStore].
class SyncEngine {
  SyncEngine({
    required this.local,
    required this.remote,
    required this.collections,
  });

  final LocalStore local;
  final LocalStore remote;
  final List<String> collections;

  /// Réconcilie chaque collection dans les deux sens. [since] borne le delta
  /// (`null` = passe complète).
  SyncResult sync({DateTime? since}) {
    var pulled = 0;
    var pushed = 0;
    for (final c in collections) {
      // Tirer : distant → local.
      for (final doc in remote.changesSince(c, since)) {
        final localAt = local.updatedAtOf(c, doc.id);
        if (localAt == null || doc.updatedAt.isAfter(localAt)) {
          local.applyRemote(c, doc);
          pulled++;
        }
      }
      // Pousser : local → distant.
      for (final doc in local.changesSince(c, since)) {
        final remoteAt = remote.updatedAtOf(c, doc.id);
        if (remoteAt == null || doc.updatedAt.isAfter(remoteAt)) {
          remote.applyRemote(c, doc);
          pushed++;
        }
      }
    }
    return SyncResult(pulled: pulled, pushed: pushed);
  }
}

/// Store distant inerte : aucun backend configuré (« serveur bientôt »).
/// Permet de câbler la coquille sans provider réel — SQLite reste la source vive.
class NoopRemoteStore implements LocalStore {
  const NoopRemoteStore();

  @override
  List<Map<String, Object?>> all(String collection) => const [];
  @override
  void put(String collection, String id, Map<String, Object?> json) {}
  @override
  void delete(String collection, String id) {}
  @override
  List<SyncDoc> changesSince(String collection, DateTime? since) => const [];
  @override
  void applyRemote(String collection, SyncDoc doc) {}
  @override
  DateTime? updatedAtOf(String collection, String id) => null;
}
