# K — Champs personnalisés (custom fields, façon CRM)

## Contexte & pourquoi c'est simple ici

Le stockage est un **magasin de documents JSON** : une seule table
`documents(collection, id, json, updatedAt, deletedAt)` ([sqlite_store.dart]). Chaque entité est un blob
JSON. **Conséquence** : ajouter un champ ne demande **aucune migration SQL** ; il suffit de l'écrire dans
`toJson` et de le lire avec un défaut tolérant dans `fromJson` (déjà fait 5×). La **sync** transporte le
document entier → tout nouveau champ suit gratuitement. Le **filtrage** se fait en mémoire (`loadAll`).

**Deux natures de « champs en plus »** :
- **A. Champs typés (développeur)** : déjà trivial (modèle + `copyWith` + mapper tolérant). Rien à planifier.
- **B. Champs personnalisés (utilisateur/admin)** : l'admin **définit** de nouveaux champs à l'exécution
  (ex. « IMEI » sur produit, « Garantie étendue » sur réparation). **C'est l'objet de ce plan.**

## Image complète (cible)

Un **registre de définitions** (`CustomFieldDef`) décrit les champs personnalisés par **entité cible**
(produit, réparation, client, fournisseur…). Chaque entité porte une **carte `custom` `Map<String,Object?>`**
rangée dans son propre JSON (donc **zéro migration DB**). Des widgets **génériques** rendent ces champs en
**saisie** (formulaires) et en **lecture** (détails). Un **écran de gestion** (dans Réglages) permet de
créer/éditer/réordonner/archiver les définitions. Types : texte, nombre, date, booléen, liste (select).

```
X1 modèle+registre+carte custom (Produit) ─ X2 écran de gestion ─ X3 rendu générique (form+détail)
                                                                   └ X4 extension entités ─ X5 finitions
```

**Invariants** : additif/sûr (aucun impact compta/schéma) · **aucune migration DB** (défauts tolérants) ·
i18n FR/EN/AR/ES + RTL · `task verify` à chaque phase.

---

## X1 — Modèle + registre + carte `custom` (première entité : Produit)

**Todos**
- [ ] `core/custom_fields/custom_field_def.dart` : `enum CustomFieldType { text, number, date, boolean, select }` ;
      `enum CustomEntity { product, repair, client, supplier }` (clé stable en base) ;
      `class CustomFieldDef { id, entity, key, label, type, options (select), required, order, active, help? }`
      + `copyWith` + valeur par défaut.
- [ ] `core/custom_fields/custom_field_mapper.dart` : `EntityMapper<CustomFieldDef>` (collection
      `custom_field_defs`).
- [ ] `core/custom_fields/custom_fields_controller.dart` : `customFieldsProvider` (CRUD) +
      `defsFor(CustomEntity)` (actifs, triés) + validation d'unicité de `key` par entité.
- [ ] **Carte `custom` sur l'entité pilote** : `Product` gagne `Map<String,Object?> custom` (défaut `{}`),
      `copyWith`, mapper tolérant (`custom: (j['custom'] as Map?)?.cast() ?? {}`). **Aucune migration.**
- [ ] Helpers de (co)ercition : `coerce(value, type)` (parse/format sûr) pour lecture/écriture.
- [ ] Tests : mapper `CustomFieldDef` aller-retour ; `Product.custom` aller-retour + défaut `{}` sur ancien
      doc ; `defsFor` filtre/tri ; unicité de `key`.

**Lien** : socle des rendus (X3) et de l'extension multi-entités (X4).

## X2 — Écran de gestion des définitions

**Todos**
- [ ] `core/custom_fields/custom_fields_screen.dart` : liste par entité cible (onglets/segments) ; ajout/
      édition d'un champ (label, clé auto-slug, type, options si `select`, requis, ordre, actif/archivé) ;
      réordonnancement ; archivage (masqué des formulaires, valeurs conservées) ; garde-fou clé unique.
- [ ] Accès depuis **Réglages** (nouvelle entrée « Champs personnalisés »).
- [ ] i18n des libellés de gestion.
- [ ] Tests : création d'un champ (produit, type texte) ; archivage le masque ; clé dupliquée refusée.

**Lien** : produit les définitions consommées par X3.

## X3 — Rendu générique (saisie + lecture), branché sur Produit

**Todos**
- [ ] `core/custom_fields/custom_fields_form.dart` : `CustomFieldsForm(entity, values, onChanged)` — rend un
      champ par définition selon le type (TextField, numérique, date-picker, switch, sélecteur). Validation
      `required`. Émet une `Map<String,Object?>` mise à jour.
- [ ] `core/custom_fields/custom_fields_view.dart` : `CustomFieldsView(entity, values)` — lignes clé/valeur
      formatées (lecture seule) ; masque les champs vides.
- [ ] Brancher sur **Produit** : `CustomFieldsForm` dans le formulaire d'édition (section « Champs
      personnalisés » si des définitions existent) ; `CustomFieldsView` dans le détail produit.
- [ ] Tests : un champ texte défini apparaît dans le formulaire, sa saisie persiste dans `product.custom` ;
      s'affiche dans le détail ; `required` bloque l'enregistrement si vide.

**Lien** : boucle complète pour une entité → réplicable en X4.

## X4 — Extension aux autres entités

**Todos**
- [ ] Ajouter la carte `custom` (+ mapper tolérant) à `Repair`, `Client`, `Supplier`.
- [ ] Brancher `CustomFieldsForm`/`CustomFieldsView` dans leurs formulaires/détails (réparation : fiche
      d'admission + détail ; client ; fournisseur).
- [ ] Tests ciblés par entité (au moins réparation, la plus riche).

**Lien** : la même mécanique, dupliquée par entité (le rendu est déjà générique).

## X5 — Finitions

**Todos**
- [ ] Types complémentaires si besoin (multi-select) ; valeurs par défaut ; aide (`help`) sous le champ.
- [ ] Filtrage optionnel : exposer `custom` dans les recherches en mémoire (ex. filtrer produits par une
      valeur custom) — sans index SQL (déjà en mémoire).
- [ ] i18n/RTL complet ; états vides ; `task verify`.

---

## Fichiers

- **Nouveaux** : `core/custom_fields/{custom_field_def,custom_field_mapper,custom_fields_controller,
  custom_fields_screen,custom_fields_form,custom_fields_view}.dart` ; tests associés.
- **Modifiés** : `catalog/domain/product.dart` (+ mapper), puis `repairs/…`, `clients/…`, `suppliers/…`
  (carte `custom` + branchement form/détail) ; `settings` (entrée Réglages) ; 4 `l10n/app_*.arb`.
- **Aucune** modification du schéma SQL (`documents` reste générique) ni de la compta.

## Risques / atténuations

- **Explosion de champs / cohérence des clés** → `key` auto-sluggée + unicité par entité + archivage plutôt
  que suppression (valeurs conservées).
- **Typage faible (Map dynamique)** → coercition centralisée par type + validation `required` ; les valeurs
  restent JSON-sérialisables (texte/num/bool/ISO-date/option).
- **Pas de requêtes SQL sur les valeurs** → filtrage en mémoire (échelle atelier, données déjà chargées) ;
  suffisant, indexation SQL possible plus tard si le volume grandit.
- **Sync** → transportée gratuitement (documents JSON entiers), y compris `custom` et les définitions.

## Décision d'entrée

Entité **pilote = Produit** (contexte catalogue actuel), moteur **générique dès X1** pour brancher
réparation/client/fournisseur en X4 sans refonte. Ordre : **X1 → X2 → X3 → (X4) → X5**.
