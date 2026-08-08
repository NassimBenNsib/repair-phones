# B — Clients (compléter l'existant)

**But** : porter le module Clients existant au niveau « production » (DB, B2B, édition, historique).
**Dépendances** : 00. **Utilisé par** : Devis (F), Factures (G), Réparations.
**Existant** : `domain/client.dart`, `clients_controller` (mémoire), `clients_screen` (liste + 2 panneaux),
`client_detail_screen` (vue + `ContactInfoCard`), `client_picker_sheet`, `showAddClientSheet`.

---

## B1 — Modèle + DB (migration)

Étendre `Client` et migrer vers Drift.
```
enum ClientType { individual, company }

class Client {
  String id;              // NOUVEAU (aujourd'hui identifié par name)
  ClientType type;        // NOUVEAU
  String name;            // contact / particulier
  String? companyName;    // NOUVEAU (B2B)
  String? vatNumber;      // NOUVEAU (B2B)
  String phone;
  String? email;
  String? address;
  String? city;           // NOUVEAU
  String? notes;          // NOUVEAU
  DateTime createdAt;
  String get displayName => companyName ?? name;
  Client copyWith(...);
}
```
Table Drift `clients`. **Migration** : `clientsProvider` → `AsyncNotifier` Drift ; conserver l'API.

## B2 — Édition inline (détail)

Le détail client est aujourd'hui **lecture seule**. Ajouter le mode **Modifier/Enregistrer** (patron
`repair_detail`) :
- champs : `name`, `companyName`, `vatNumber`, `phone`, `email`, `address`, `city`, `notes` ;
- `AppleSegmentedControl<ClientType>` ; bloc **Société** visible si `company`.
- Conserver `showAddClientSheet` (création rapide) ; harmoniser avec le mode création du détail.

## B3 — Liens & statistiques

- **Relier les réparations par `clientId`** (FK) au lieu du nom (aujourd'hui `repair.client` = String).
  Ajouter `clientId` sur `Repair` ; migration douce (résolution par nom → id au seed).
- Détail client, nouveaux blocs :
  - **Statistiques** : nb réparations, total facturé (via Factures G), solde dû.
  - **Historique réparations** : liste des réparations du client (statut + montant), tap → détail
    réparation (`RepairDetailScreen`).
  - *(après G)* **Factures / impayés**.

## B4 — i18n + vérif

- **i18n** : `clientTypeIndividual/Company`, `clientCompanyName`, `clientVat`, `clientCity`,
  `clientSectionCompany`, `clientSectionHistory`, `clientSectionStats`, `clientRepairsCount`(pluriel),
  `clientTotalBilled`. (`clientSectionContact`, `fieldPhone/Email/Address`, `clientsNew` existent.)
- Vérif : édition + persistance, historique lié par id, deux-panneaux, RTL, thèmes, `analyze/test/build`.

## Cas limites
- Client B2B sans `companyName` → retomber sur `name`.
- Suppression d'un client lié à des réparations/factures → **interdite** (ou soft-delete).
- Fusion de doublons (nom identique) → hors scope, noter comme amélioration future.
