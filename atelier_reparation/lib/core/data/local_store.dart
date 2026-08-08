/// Couche de stockage local, agnostique du backend (SQLite, mémoire, …).
///
/// Les données sont manipulées comme des documents JSON par collection, ce qui
/// permet d'échanger l'implémentation (SQLite aujourd'hui, serveur/hybride plus
/// tard) sans toucher aux fonctionnalités. Voir `docs/plans/00-foundations.md`.
library;

/// Document versionné : corps JSON + horodatage et pierre tombale, briques
/// nécessaires à une synchronisation delta (voir `core/sync`).
class SyncDoc {
  const SyncDoc(this.id, this.json, this.updatedAt, this.deletedAt);

  final String id;
  final Map<String, Object?> json;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
}

/// Contrat de stockage : opérations sur des documents JSON par collection.
///
/// Synchrone (SQLite via le paquet `sqlite3` l'est) → les contrôleurs de
/// fonctionnalité restent de simples `Notifier<List<T>>`, sans `AsyncValue`.
///
/// La surface *sync* ([changesSince]/[applyRemote]/[updatedAtOf]) expose
/// l'horodatage et les tombstones pour un futur backend serveur/hybride, sans
/// changer le comportement local (SQLite reste la source vive).
abstract class LocalStore {
  List<Map<String, Object?>> all(String collection);
  void put(String collection, String id, Map<String, Object?> json);
  void delete(String collection, String id);

  /// Documents (tombstones compris) modifiés strictement après [since]
  /// (ou tous si `null`) — pour pousser/tirer un delta.
  List<SyncDoc> changesSince(String collection, DateTime? since);

  /// Applique un document distant tel quel (corps + horodatage + tombstone),
  /// sans réécrire `updatedAt` — utilisé par le moteur de synchronisation.
  void applyRemote(String collection, SyncDoc doc);

  /// `updatedAt` courant d'un document (tombstone inclus), ou `null` s'il
  /// n'existe pas — arbitrage « dernier écrit gagne ».
  DateTime? updatedAtOf(String collection, String id);
}

/// Implémentation en mémoire — défaut sur le Web, tests et démo.
///
/// Suit `updatedAt`/`deletedAt` par document (parité avec `SqliteStore`).
class InMemoryStore implements LocalStore {
  final Map<String, Map<String, SyncDoc>> _data = {};

  @override
  List<Map<String, Object?>> all(String collection) => [
        for (final d in (_data[collection] ?? const {}).values)
          if (!d.isDeleted) d.json,
      ];

  @override
  void put(String collection, String id, Map<String, Object?> json) {
    (_data[collection] ??= {})[id] = SyncDoc(id, json, DateTime.now(), null);
  }

  @override
  void delete(String collection, String id) {
    final existing = _data[collection]?[id];
    if (existing == null) return;
    final now = DateTime.now();
    _data[collection]![id] = SyncDoc(id, existing.json, now, now);
  }

  @override
  List<SyncDoc> changesSince(String collection, DateTime? since) => [
        for (final d in (_data[collection] ?? const {}).values)
          if (since == null || d.updatedAt.isAfter(since)) d,
      ];

  @override
  void applyRemote(String collection, SyncDoc doc) {
    (_data[collection] ??= {})[doc.id] = doc;
  }

  @override
  DateTime? updatedAtOf(String collection, String id) =>
      _data[collection]?[id]?.updatedAt;
}

/// Sérialisation d'une entité — unique et réutilisée par tous les backends.
abstract class EntityMapper<T> {
  String get collection;
  String idOf(T entity);
  Map<String, Object?> toJson(T entity);
  T fromJson(Map<String, Object?> json);
}

/// Vue typée d'une collection : lit/écrit des entités `T` via un [LocalStore].
class CollectionStore<T> {
  CollectionStore(this._store, this._mapper);

  final LocalStore _store;
  final EntityMapper<T> _mapper;

  List<T> loadAll() =>
      _store.all(_mapper.collection).map(_mapper.fromJson).toList();

  bool get isEmpty => _store.all(_mapper.collection).isEmpty;

  void upsert(T entity) =>
      _store.put(_mapper.collection, _mapper.idOf(entity), _mapper.toJson(entity));

  void remove(String id) => _store.delete(_mapper.collection, id);

  /// Sème les données de démo si la collection est vide (premier lancement).
  void seedIfEmpty(Iterable<T> seed) {
    if (isEmpty) {
      for (final e in seed) {
        upsert(e);
      }
    }
  }
}
