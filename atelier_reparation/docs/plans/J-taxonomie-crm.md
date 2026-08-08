# J — Taxonomie CRM-grade (moteur générique partagé)

## Image complète

Aujourd'hui **deux** taxonomies quasi identiques coexistent (prestations : `ServiceCategoryNode` +
`CategoriesController` ; catalogue : `ProductCategoryNode` + `ProductCategoriesController`), **limitées à
2 niveaux**, sans **code**, sans **description**, sans **déplacement/fusion**, sans **archivage**.

**Cible** : un **moteur de taxonomie générique** unique (`core/taxonomy/`) — profondeur **illimitée**,
attributs CRM (nom, **code unique**, description, icône, couleur, ordre, actif/archivé), **déplacement**
(reparent, anti-cycle), **fusion**, **rollup à toute profondeur**, chemin complet — réutilisé **à la fois**
par le catalogue **et** les prestations, avec un **écran de gestion arborescent** et un **sélecteur
hiérarchique** partagés.

**Décisions actées** : moteur **partagé** (les deux features) · profondeur **illimitée** · construit
**maintenant** (avant S5 du plan Fournisseurs).

**Invariants** : migration **sans perte** (mêmes collections `service_categories` / `product_categories`,
mêmes champs + nouveaux champs optionnels avec défauts) · aucune casse des `categoriesProvider` /
`productCategoriesProvider` existants (API conservée) · i18n FR/EN/AR/ES + RTL · `task verify` à chaque phase.

```
C1 cœur générique + adoption CATALOGUE ─ C2 adoption PRESTATIONS ─ C3 écran+sélecteur génériques ─ C4 fusion/archive/polish
```

---

## C1 — Cœur générique + adoption catalogue

**But** : créer le moteur générique et y basculer les catégories **produits** (sans changer l'API publique).

**Todos**
- [ ] `core/taxonomy/taxonomy_node.dart` : `TaxonomyNode {id, name, parentId?, iconKey, colorHex, order,
      code?, description?, active=true}` + `copyWith` (dont `parentId/clearParent`). **Pas** de résolution
      d'icône dans le cœur (l'`iconKey` reste une chaîne ; la map d'icônes est fournie par le domaine).
- [ ] `core/taxonomy/taxonomy_mapper.dart` : `TaxonomyMapper` (collection configurable) — lit/écrit tous
      les champs ; `code/description` nullables, `active` défaut `true` (compat ascendante).
- [ ] `core/taxonomy/taxonomy_controller.dart` : `TaxonomyController` (Notifier<List<TaxonomyNode>>) avec
      `byId, nameOf, path, pathNodes, topLevel, childrenOf, descendantIds (récursif), add, update, remove,
      move(id,newParentId) + garde anti-cycle, merge(fromId,intoId,{onReassign}), isCodeUnique`.
- [ ] Basculer le catalogue : `ProductCategoryNode`→alias/emploi de `TaxonomyNode` ; `productCategoriesProvider`
      = instance du contrôleur générique (collection `product_categories`, seed, map `kProductCategoryIcons`).
      **Conserver** l'API appelée par l'UI catalogue (`byId/path/topLevel/childrenOf/nameOf`).
- [ ] `descendantIds` remplace le rollup 2-niveaux dans `catalog_screen` (filtre) et
      `product_categories_screen` (compteurs) → **rollup à toute profondeur**.
- [ ] Tests : `taxonomy_core_test` — `move` + anti-cycle (déplacer sous son propre descendant refusé),
      `descendantIds` sur 3 niveaux, `merge` (produits réassignés + enfants reparentés + nœud supprimé),
      `isCodeUnique`, `pathNodes`.

**Lien** : socle de C2 (prestations) et C3 (UI générique).

## C2 — Adoption prestations

**But** : brancher les prestations sur le **même** moteur, sans régression.

**Todos**
- [ ] `serviceCategoryStoreProvider`/`categoriesProvider` → instances du contrôleur générique (collection
      `service_categories`, seed existant, map `kServiceCategoryIcons`). API `categoriesProvider` conservée.
- [ ] `ServiceCategoryNode` → `TaxonomyNode` (ré-export/alias) ; `service_catalog_controller.reassignCategory`
      inchangé (utilisé comme `onReassign` pour `merge`).
- [ ] Vérifier `services_screen` + `categories_screen` inchangés à l'écran (rollup passe en `descendantIds`).
- [ ] Tests : les suites prestations existantes restent vertes ; ajout d'un test sous-sous-catégorie (3 niveaux).

**Lien** : les deux domaines partagent désormais le cœur → C3 peut offrir **un** écran/sélecteur pour les deux.

## C3 — Écran de gestion + sélecteur génériques (récursifs, profondeur illimitée)

**But** : une gestion arborescente et une sélection hiérarchique uniques, paramétrées par domaine.

**Todos**
- [ ] `core/taxonomy/taxonomy_tree_screen.dart` : arbre **récursif** (indentation par profondeur,
      **expand/collapse**), add/edit/**move**/**merge**/delete, compteurs via une fonction `count(ids)`
      injectée, map d'icônes + palette injectées. Paramètres : provider, titre, icônes, couleurs, count,
      onReassign.
- [ ] `core/taxonomy/taxonomy_picker.dart` : sélecteur **hiérarchique** (fil d'Ariane / drill-down à N
      niveaux) remplaçant les sélecteurs « deux étapes ».
- [ ] Formulaire de nœud enrichi : **code** (+ validation unicité), **description**, interrupteur **actif**,
      **sélecteur de parent** (déplacement), ordre.
- [ ] Brancher catalogue **et** prestations sur ces widgets ; retirer `product_categories_screen`,
      `categories_screen`, `_CategoryTwoStep`, `ProductCategoryTwoStep` (remplacés).
- [ ] Tests : rendu arbre 3 niveaux + création sous-sous-catégorie + déplacement via sélecteur de parent ;
      sélecteur hiérarchique choisit un nœud profond.

**Lien** : livre l'expérience CRM (profondeur, code, description, move) pour les deux domaines d'un coup.

## C4 — Fusion, archivage, finitions

**But** : compléter les opérations CRM et durcir.

**Todos**
- [ ] **Fusion** de deux catégories (UI) : réassigne les entités + reparente les enfants + supprime.
- [ ] **Archivage** (`active=false`) : masqué des sélecteurs/filtres mais conservé (alternative douce à la
      suppression). Filtre « archivées » dans l'écran de gestion.
- [ ] Validation **code unique** à l'écran ; garde-fous suppression/déplacement.
- [ ] i18n nouveaux libellés (`taxonomyCode`, `taxonomyDescription`, `taxonomyActive`, `taxonomyArchived`,
      `taxonomyMove`, `taxonomyMerge`, `taxonomyParent`) × 4 ARBs ; RTL.
- [ ] `task verify` complet.

**Lien** : referme le moteur CRM ; réutilisable ensuite pour toute autre taxonomie (clients, appareils…).

---

## Fichiers

- **Nouveaux** : `core/taxonomy/{taxonomy_node,taxonomy_mapper,taxonomy_controller,taxonomy_tree_screen,
  taxonomy_picker}.dart` ; tests `taxonomy_core_test`, MAJ des tests catégories.
- **Modifiés** : `catalog/{domain/product_category_node,data/product_category_mapper,application/
  product_categories_controller,presentation/*}.dart`, `prestations/{domain/service_category_node,data/
  service_category_mapper,application/categories_controller,presentation/*}.dart`, les 4 `l10n/app_*.arb`.
- **Inchangé** : `Product.categoryId` / `ServiceTemplate.categoryId` (référencent toujours un id de nœud).

## Risques / atténuations

- **Re-touche la feature prestations livrée** → API `categoriesProvider` **conservée** ; migration de données
  compatible (mêmes collections/champs + nouveaux champs à défauts) ; suites prestations existantes = filet.
- **Profondeur illimitée** → garde **anti-cycle** sur `move`, profondeur d'affichage gérée par récursion +
  expand/collapse ; `descendantIds` mémo-friendly (une passe).
- **Gros refactor** → séquencé C1(catalogue)→C2(prestations)→C3(UI)→C4 ; chaque phase `task verify` verte,
  aucune bascule UI avant que le cœur soit prouvé par les tests.
- **Duplication supprimée** → un seul moteur ; extension future (clients/appareils) quasi gratuite.

## Ordre

**C1 → C2 → C3 → C4**, une phase à la fois. Puis reprise du plan Fournisseurs à **S5**.
