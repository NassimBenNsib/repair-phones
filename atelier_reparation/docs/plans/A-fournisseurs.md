# A — Fournisseurs (Suppliers)

**But** : gérer les fournisseurs de pièces (contacts, conditions, historique d'achats).
**Dépendances** : 00 (Drift, ContactInfoCard, scaffolds). **Utilisé par** : Commandes (E).
**Section nav** : `suppliers` (actuellement placeholder).

---

## A1 — Domaine + DB

`domain/supplier.dart`
```
enum SupplierType { company, individual }

class Supplier {
  String id;              // uuid
  SupplierType type;      // défaut company
  String name;            // raison sociale ou nom
  String? contactName;    // interlocuteur
  String phone;
  String? email;
  String? address;
  String? city;
  String? vatNumber;      // TVA intracom
  String? paymentTerms;   // ex. "30 jours net"
  String? notes;
  DateTime createdAt;
  // getters : initials, displayName
  Supplier copyWith(...);
}
```
Table Drift `suppliers` : colonnes 1:1 (type stocké en `name` d'enum). Index sur `name`.

## A2 — Repository + provider

`data/supplier_repository.dart` (implémente `CrudRepository<Supplier>`) +
`application/suppliers_controller.dart` → `suppliersProvider = AsyncNotifierProvider<...,List<Supplier>>`
(`watchAll`, `add`, `update`, `remove`). Recherche : `name / contactName / phone / vatNumber`.

## A3 — Écran liste (`presentation/suppliers_screen.dart`)

- `EntityListScaffold` adaptatif ; recherche ; `＋` → détail en **mode création**.
- Carte/row : avatar (initiales), `name`, `city`, badge type (Société/Particulier), sous-titre `phone`.
- États : chargement (`Skeleton`), vide (illustration + « Aucun fournisseur »).

## A4 — Détail (`presentation/supplier_detail.dart`)

Blocs (vue) / champs (édition, patron `repair_detail`) :
- **En-tête** : avatar + `name` + badge type.
- **Coordonnées** : `ContactInfoCard(name, phone, email, address)` (appel/WhatsApp/Telegram/mail/maps).
- **Société** : `vatNumber`, `paymentTerms` (affiché si type=company).
- **Notes**.
- **Commandes** *(après module E)* : liste des PO de ce fournisseur (statut + total), tap → détail PO.
- **Édition inline** : `AppleTextField` pour tous les champs + `AppleSegmentedControl<SupplierType>`.
- **⋯** : Supprimer (confirmation).

## A5 — Sélecteur + i18n

- `presentation/supplier_picker_sheet.dart` : `EntityPickerSheet<Supplier>` (recherche + « Nouveau
  fournisseur »). Consommé par Commandes.
- **i18n** (clés) : `navSuppliers`(existe), `supplierNew`, `supplierType`, `supplierTypeCompany`,
  `supplierTypeIndividual`, `supplierContactName`, `supplierTerms`, `supplierEmpty`, `supplierSearch`,
  `sectionCompany`(réutil.), `fieldPhone/Email/Address`(existent).

## A6 — Intégration & vérif

- `app_sections.dart` : `suppliers` `placeholder:false` ; route dans `app_router.dart`.
- Vérif : CRUD, recherche, persistance après redémarrage, RTL (arabe), thèmes, `analyze/test/build`.

## Cas limites
- Fournisseur référencé par une commande → **empêcher la suppression** (ou soft-delete `active=false`).
- Champs optionnels absents → afficher « Non renseigné ».
- TVA invalide → validation légère (format), non bloquante.
