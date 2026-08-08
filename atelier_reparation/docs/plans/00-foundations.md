# 00 — Fondations (couche de données flexible + socle partagé)

**But** : un socle où **le lieu de stockage est interchangeable** — mémoire, base locale (Drift/SQLite),
serveur distant (REST/Supabase), ou **hybride offline-first** — choisi par configuration, **par
collection**, sans changer le code des fonctionnalités. Plus : kit domaine, numérotation, scaffolds UI,
PDF, auth.

**Dépendances** : aucune. **Bloque** : tous les modules.

---

## 1. Principe : abstraction « EntityStore »

Chaque fonctionnalité parle à une **interface unique** ; l'implémentation (mémoire / local / serveur /
hybride) est injectée au démarrage. Les providers Riverpod gardent le **même nom** partout — donc les
écrans ne savent jamais *où* les données vivent.

```
UI (écrans)
  └─ Provider Riverpod  clientsProvider : AsyncNotifier<List<Client>>
       └─ EntityStore<Client>            ← contrat unique
            ├─ InMemoryStore<Client>     (dev, tests, démo)
            ├─ DriftStore<Client>        (local, hors-ligne)
            ├─ RemoteStore<Client>       (serveur)
            └─ HybridStore<Client>       (local = source de vérité + sync serveur)
```

Le choix se fait via `StorageConfig` (global + **surcharge par collection**), persisté et modifiable
(build, `.env`, ou écran Paramètres avancés).

---

## 2. Contrats cœur (`lib/core/data/`)

```dart
/// Métadonnées communes à toute entité persistée (id client + synchro).
abstract class Entity {
  String get id;            // UUID généré CLIENT (marche hors-ligne et serveur)
  DateTime get updatedAt;   // horodatage de dernière modif (résolution de conflit)
  DateTime? get deletedAt;  // tombstone → suppression logique (sync-safe)
}

/// Sérialisation UNIQUE réutilisée par tous les backends.
abstract class EntityMapper<T> {
  String get collection;                 // table Drift / endpoint REST / clé mémoire
  Map<String, Object?> toJson(T e);
  T fromJson(Map<String, Object?> j);
}

/// Filtre/tri portable (traduit en SQL, query REST, ou prédicat mémoire).
class Query { final Map<String,Object?> equals; final String? search;
              final String? orderBy; final bool desc; final int? limit; }

/// LE contrat. Même API quel que soit le stockage.
abstract class EntityStore<T extends Entity> {
  Stream<List<T>> watchAll();          // flux réactif (UI live)
  Future<List<T>> query(Query q);
  Future<T?> getById(String id);
  Future<void> save(T e);              // upsert (met à jour updatedAt)
  Future<void> delete(String id);      // soft delete (deletedAt = now)
}
```

**Règles transverses** : IDs = **UUID client** (jamais d'auto-increment), suppression = **tombstone**,
tout écrit `updatedAt`. Ces trois choix rendent mémoire ↔ local ↔ serveur compatibles.

---

## 3. Implémentations interchangeables

### 3.1 `InMemoryStore<T>` — défaut dev / tests / démo
Map `{id → T}` + `StreamController.broadcast`. Zéro dépendance, éphémère. Seed initial.

### 3.2 `DriftStore<T>` — local, hors-ligne (Drift/SQLite)
Deux stratégies, au choix **par collection** (flexibilité) :
- **Document générique** (défaut, souple) : une table `documents { id, collection, json, updatedAt,
  deletedAt }` — n'importe quelle entité y tient sans schéma dédié. `query` filtre en Dart/JSON1.
- **Table typée** (perf/requêtes) : colonnes dédiées + index, pour les entités très requêtées
  (factures, réparations). Le `EntityMapper` reste le même (JSON ↔ colonnes).

`main()` ouvre la base (`path_provider`), injectée par override.

### 3.3 `RemoteStore<T>` — serveur (REST ou Supabase)
Adapte `collection` → endpoint (`/clients`) ou table Supabase. `save/delete` = POST/PATCH/DELETE,
`watchAll` = polling *ou* temps réel (websocket/Supabase realtime). En-tête d'auth depuis la session
(0.13). Même `EntityMapper` JSON.

### 3.4 `HybridStore<T>` — offline-first + synchro (recommandé en prod)
Enveloppe un **local (source de vérité)** + un **remote**. Lecture = flux local. Écriture = local
immédiat **+ mise en file** (outbox) pour pousser au serveur. Un **moteur de sync** (§4) réconcilie.

---

## 4. Moteur de synchronisation (mode hybride)

- **Outbox** : table `sync_outbox { id, collection, op(save|delete), payload, tries }` — opérations en
  attente.
- **Pull** : `GET /collection?since=<lastPulledAt>` → applique les changements distants localement.
- **Push** : vide l'outbox quand la connectivité revient (`connectivity_plus`).
- **Conflits** : *last-write-wins* par `updatedAt` (défaut) ; option versionnée (`rev`) pour refus
  explicite. Tombstones propagés.
- **État** : `syncStatus` par entité (synced / pending / error) → indicateur discret dans l'UI.
- **Reprise** : backoff exponentiel, journal d'échecs. Marche à froid après redémarrage (outbox
  persistée).

---

## 5. Configuration & sélection

```dart
enum StorageMode { memory, local, server, hybrid }

class StorageConfig {
  StorageMode defaultMode;                       // global
  Map<String, StorageMode> perCollection;        // surcharge : {'invoices': hybrid, 'settings': local}
  String? serverBaseUrl; String? apiKey;
}
```
- Persisté (via le dépôt de préférences existant) ; défaut = `memory` (dev) → `local` → `hybrid`.
- **Fabrique** : `EntityStore<T> storeFor<T>(mapper)` lit la config et instancie la bonne implémentation
  (avec fallback : si serveur injoignable et non-hybride → dégrade en local + avertit).
- **Écran « Stockage » (Paramètres avancés)** : choisir le mode, l'URL serveur, tester la connexion,
  déclencher une synchro, voir l'état.
- **Bootstrap** (`main.dart`) : construit la config + les stores et les injecte par **overrides**
  Riverpod (comme `settingsRepositoryProvider` aujourd'hui).

---

## 6. Intégration d'une fonctionnalité (inchangée côté écran)

Pour chaque entité : un `EntityMapper` + un provider qui délègue au store configuré.
```dart
final clientMapper = ClientMapper();                        // toJson/fromJson
final clientStoreProvider = Provider((ref) =>
    ref.watch(storeFactoryProvider).storeFor<Client>(clientMapper));

class ClientsController extends AsyncNotifier<List<Client>> {
  EntityStore<Client> get _s => ref.read(clientStoreProvider);
  @override Future<List<Client>> build() { /* écoute _s.watchAll() */ }
  Future<void> add(Client c) => _s.save(c);
  Future<void> update(Client c) => _s.save(c);
  Future<void> remove(String id) => _s.delete(id);
}
```
→ **Migrer les 3 stores existants** (repairs/clients/catalog) vers ce patron `AsyncNotifier` +
`EntityStore`. Les écrans liste passent à `AsyncValue` (chargement/erreur/données).

---

## 7. Reste du socle (dépend de la couche données ci-dessus)

- **7.1 Kit domaine** (`lib/core/domain/`) : `Money` (arrondi/format `intl`), `LineItem`,
  `Totals.compute`, `PartyRef`. Portable, indépendant du backend.
- **7.2 Numérotation** (`numbering.dart`) : séquence `PREFIX-YYYY-####` gap-free/immuable (factures).
  **Backend-aware** : en mémoire/local → séquence locale ; en serveur/hybride → **numéro autoritatif du
  serveur** à l'émission (évite les collisions multi-postes).
- **7.3 Scaffolds UI** (`shared/widgets/entity/`) : `EntityListScaffold`, `EntityDetailScaffold`,
  `EntityPickerSheet<T>` — extraits de repairs/clients.
- **7.4 PDF/print** : `pdf` + `printing`, `DocumentPdf` (Inter embarquée), alimenté par le profil
  entreprise.
- **7.5 Auth core** : lui aussi **multi-mode** — PIN/local (hors-ligne) *ou* auth serveur
  (token) selon `StorageMode`. `Role`/`User`/`Permission`, `SessionController`, garde go_router,
  `can()`. En hybride : login serveur avec repli local si hors-ligne.

---

## Dépendances (packages)
`drift`, `sqlite3_flutter_libs`, `path_provider` (local) · `http` ou `supabase_flutter` (serveur) ·
`connectivity_plus` (sync) · `uuid` (ids) · `crypto` (auth) · `pdf`, `printing` (docs) ·
dev : `drift_dev`, `build_runner`.

## Ordre de mise en place
1. Contrats (§2) + `InMemoryStore` + fabrique/config → **migrer les 3 stores existants** (rien ne change
   visuellement, mais l'architecture est en place).
2. `DriftStore` (local) → basculer `defaultMode=local`, vérifier la **persistance après redémarrage**.
3. `RemoteStore` + `HybridStore` + moteur de sync (quand un serveur existe).
4. Kit domaine, numérotation, scaffolds, PDF, auth.

## Risques
- **Abstraction trop générique** → prévoir l'échappatoire « table typée » (§3.2) pour les requêtes
  lourdes.
- **Sync/conflits** : le point le plus délicat — commencer *local-only*, activer l'hybride plus tard.
- **Numéros légaux multi-postes** : autorité serveur en hybride, sinon préfixe par poste.
- **Cohérence des mappers** : un `EntityMapper` par entité, testé (round-trip toJson/fromJson).
- Migrer les stores existants sans casser l'UI (garder les noms de providers).

## Vérification
Tests unitaires : round-trip mappers, `InMemoryStore`, séquence de numérotation, résolution de conflit
(last-write-wins), fabrique (mode → bonne impl). Manuel : `defaultMode=memory` (démo), puis `local`
(**créer → redémarrer → persiste**), basculer une collection en `server` si dispo. `analyze/test/build`.
