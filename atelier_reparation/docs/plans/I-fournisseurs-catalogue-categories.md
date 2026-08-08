# I — Fournisseurs × Catalogue × Catégories

## Image complète (le « tout » que ces phases assemblent)

Aujourd'hui le **catalogue** (produits/pièces) et les **fournisseurs** vivent séparément : les catégories
produit sont un enum figé à 3 valeurs, le catalogue n'a **aucun filtre par catégorie**, un produit **ne
connaît pas son fournisseur**, et une fiche fournisseur n'affiche **ni ses produits ni ses commandes**.

**Cible** : un atelier peut (1) **organiser son catalogue** avec une vraie taxonomie catégories +
sous-catégories (comme les prestations), (2) savoir **quel fournisseur fournit quoi**, (3) ouvrir une fiche
fournisseur et **voir son catalogue + ses commandes + recommander**, (4) **filtrer les fournisseurs par ce
qu'ils fournissent**, le tout bouclant la chaîne **catégorie → produit → fournisseur → commande → stock**
(les commandes ajustent déjà le stock des variantes).

Chaque phase (Sx) est **livrable et vérifiable seule** (`task verify` vert), mais s'emboîte dans l'ordre
ci-dessous. Dépendances : S1→S2→S3 (bloc **Catalogue/Catégories**) ; S1→S4→S5 (bloc **Lien fournisseur**) ;
S6 dépend de S4/S5 ; S7 raffine S4.

```
S1 taxonomie ─┬─ S2 gestion+édition ─ S3 filtres/vues        (bloc A : Catalogue)
              └─ S4 lien produit↔fournisseur ─ S5 page fournisseur ─ S6 filtres+réappro+garde-fous
                                                                     └─ S7 sourcing par fournisseur (option)
```

**Décision d'architecture** : on **réplique** le moteur de taxonomie des prestations dans le catalogue
(nouveau `ProductCategoryNode`, collection `product_categories`) plutôt que de généraliser tout de suite un
noyau partagé — pour **ne pas déstabiliser** la feature prestations déjà livrée. Une extraction ultérieure
d'un `TaxonomyNode` générique reste possible (note en fin de doc). Réutilisation directe des patrons :
`ServiceCategoryNode`, `CategoriesController`, `CategoriesScreen`, sélecteur à deux niveaux, filtre
« rollup » `_catIds`.

**Invariants transverses** (toutes phases) : additif/sûr (aucune casse compta/commandes) ; migration de
données **sans perte** (id de nœud = ancien nom d'enum, lecture `categoryId ?? category ?? 'part'`) ;
i18n FR/EN/AR/ES + RTL ; `task verify` à chaque phase.

---

## S1 — Catalogue : taxonomie catégories (fondations, data-driven)

**But** : remplacer l'enum `ProductCategory {part, accessory, service}` par une taxonomie éditable
(catégories + sous-catégories), migrée sans perte.

**Todos**
- [ ] `domain/product_category_node.dart` : `ProductCategoryNode {id, name, parentId?, iconKey, colorHex,
      order}` + `kProductCategoryIcons` (map const IconData) + `kProductCategoryColors` ; getters
      `isSub/icon/color` + `copyWith` (miroir de `service_category_node.dart`).
- [ ] `seedProductCategories` : 3 nœuds racine avec **id = ancien enum** (`part`/`accessory`/`service`,
      noms FR Pièce/Accessoire/Service) **+ quelques sous-catégories** de démo sous « Pièce » (Écrans,
      Batteries, Connecteurs) et « Accessoire » (Coques, Chargeurs) pour montrer la valeur des sous-cat.
- [ ] `data/product_category_mapper.dart` (`EntityMapper`, collection `product_categories`).
- [ ] `application/product_categories_controller.dart` : `productCategoriesProvider` +
      `byId/nameOf/path/topLevel/childrenOf/add/update/remove/reassignCategory` (miroir
      `categories_controller.dart`).
- [ ] **Migration `Product`** : `ProductCategory category` → `String categoryId` (défaut `'part'`) ;
      `copyWith` accepte `categoryId`. Supprimer l'enum `ProductCategory` (icône/couleur/label passent par
      le nœud).
- [ ] `product_mapper.dart` : écrit `categoryId` ; lit `categoryId ?? category ?? 'part'` (compat).
- [ ] Adapter les points d'appel contenus **au seul feature catalogue** : `catalog_controller.addProduct`,
      `product_card` (pastille via `byId(categoryId)?.icon/color/nameOf`), `product_detail_screen`,
      `product_form`, `catalog_screen`.
- [ ] Tests : `catalog_taxonomy_test` — mapper aller-retour (`categoryId`), migration (`category:'service'`
      → `categoryId`), seed + sous-cat + `path()` + `reassignCategory`.

**Fichiers** : +4 nouveaux (node/mapper/controller + test), ~5 modifiés (catalogue only).
**Lien** : socle des catégories réutilisé par S2 (gestion), S3 (filtres), S4-S6 (regroupement fournisseur).

## S2 — Catalogue : gestion des catégories + édition produit

**But** : gérer l'arbre de catégories et **rendre les produits éditables** (aujourd'hui seul l'ajout existe).

**Todos**
- [ ] `presentation/product_categories_screen.dart` (miroir `categories_screen.dart`) : arbre
      catégorie → sous-catégories, ajout/édition/suppression, **réassignation à la suppression** (jamais
      d'orphelin), compteurs avec rollup. Accessible via une icône « catégories » dans l'app bar du catalogue.
- [ ] `Product.copyWith` étendu (name/brand/categoryId/options) ; `catalogController.updateProduct(...)`.
- [ ] `product_form.dart` → création **et** édition ; catégorie choisie par **sélecteur à deux niveaux**
      (miroir `_CategoryTwoStep`) au lieu du `AppleSegmentedControl` figé.
- [ ] `product_detail_screen` : bouton « Modifier » ouvrant le formulaire pré-rempli.
- [ ] i18n : libellés gestion catégories (réutiliser au maximum ceux des prestations : `categoryNew`,
      `categoryMoveServices`→équivalent produit, etc.).
- [ ] Tests : `product_categories_screen_test` (arbre + création), édition produit (nom/marque/catégorie).

**Lien** : l'édition produit est le préalable pour **assigner un fournisseur** (S4) dans le même formulaire.

## S3 — Catalogue : filtres hiérarchiques + parité des vues

**But** : rendre le catalogue navigable par catégorie et cohérent avec Clients/Fournisseurs.

**Todos**
- [ ] Barre de segments **drill-down** (chips catégories racine + chips sous-catégories quand une racine est
      active) avec **rollup** `_catIds` (miroir `services_screen`).
- [ ] Bascule **liste / grille / tableau** (réutiliser `directory_views` + réglage partagé
      `clientsListStyle`) — parité avec les autres répertoires.
- [ ] Pastille catégorie (icône/couleur du nœud) sur les cartes/lignes produit.
- [ ] Tests : `catalog_screen_test` — rendu + recherche + filtre catégorie + drill-down rollup + absence de
      débordement en grille/tableau (420/1200 px).

**Lien** : ferme le bloc **A (Catalogue/Catégories)**. Le regroupement par catégorie servira tel quel dans la
fiche fournisseur (S5).

## S4 — Lien produit ↔ fournisseur (cœur du « catalogue … of them »)

**But** : un produit sait qui le fournit ; base du réappro et des vues fournisseur.

**Todos**
- [ ] `Product` : `List<String> supplierIds` (une pièce a souvent **plusieurs sources**), défaut `[]` ;
      `copyWith` + mapper + migration (défaut vide).
- [ ] `product_form`/`product_detail` : **multi-sélection de fournisseurs** via une feuille (réutiliser la
      liste `suppliersProvider` ; picker multi-select façon `showAppleSheet`).
- [ ] `product_detail_screen` : section « Fournisseurs » (chips) → tap ouvre la fiche fournisseur.
- [ ] `catalogController` : helper `productsForSupplier(id)` (filtre `supplierIds.contains(id)`).
- [ ] Tests : mapper (supplierIds aller-retour + migration), `productsForSupplier`.

**Lien** : consommé par S5 (liste produits d'un fournisseur) et S6 (catégories fournies, réappro).

## S5 — Fiche fournisseur : Catalogue + Commandes

**But** : la page fournisseur devient un hub — ce qu'il fournit et l'historique d'achats.

**Todos**
- [ ] Section **« Produits fournis »** : `productsForSupplier(id)` **regroupés par catégorie** (rollup S1),
      avec compteur ; tap → détail produit.
- [ ] Section **« Commandes »** : `PurchaseOrder` du fournisseur (via `ordersProvider`), statut + total +
      date ; CTA **« Nouvelle commande »** pré-remplie avec ce fournisseur.
- [ ] **Repli dérivé (D, zéro schéma)** : produits déjà commandés à ce fournisseur (via `LineItem.productId`
      des PO) mais **non liés** → action rapide « Lier au fournisseur » (écrit `supplierIds`).
- [ ] Tests : `supplier_detail_test` — produits fournis groupés, commandes listées, action « lier ».

**Lien** : referme le bloc **B**. La « Nouvelle commande » rejoint le flux commandes existant (qui ajuste le
stock à la réception → boucle complète).

## S6 — Fournisseurs : catégories fournies, filtre, réappro, garde-fous

**But** : trouver un fournisseur par ce qu'il fournit, et boucler stock → commande.

**Todos**
- [ ] **Catégories fournies** (approche **dérivée**, sans nouveau champ) : calculées depuis les catégories
      des produits liés ; chips sur la ligne/fiche fournisseur.
- [ ] **Filtre** « catégorie fournie » sur `suppliers_screen` (à côté du segment type).
- [ ] **Réappro bouclé** : depuis une ligne **stock bas** de l'inventaire → « Commander » → choix du
      fournisseur parmi `product.supplierIds` → brouillon de PO pré-rempli avec la ligne.
- [ ] **Garde-fous** : suppression d'un fournisseur référencé (produits/PO) → avertissement ; suppression
      d'une catégorie produit → réassignation (déjà en S2).
- [ ] i18n/RTL/états vides + `task verify`.
- [ ] Tests : filtre catégorie fournie ; création PO depuis stock bas.

**Lien** : relie explicitement **A × B** (catégories ↔ fournisseurs ↔ commandes ↔ stock) — l'image complète.

## S7 — (Option) Sourcing par fournisseur

**But** : passer de « qui fournit » à « à quel prix / quelle référence / quel délai ».

**Todos**
- [ ] Remplacer `supplierIds` par `List<ProductSourcing>{supplierId, purchasePrice?, supplierRef?,
      leadTimeDays?, preferred}` (migration : ids → sourcing sans prix).
- [ ] Détail produit : tableau de sourcing, mise en avant du **meilleur prix / fournisseur préféré**.
- [ ] Création de PO : pré-remplit le **prix d'achat**. Ouvre le calcul **coût/marge** produit.
- [ ] Tests : migration + sélection meilleur prix.

**Lien** : raffine S4-S6 sans changer le reste ; peut être reporté sans bloquer l'image complète.

---

## Fichiers (vue d'ensemble)

- **Nouveaux** : `catalog/domain/product_category_node.dart`,
  `catalog/data/product_category_mapper.dart`, `catalog/application/product_categories_controller.dart`,
  `catalog/presentation/product_categories_screen.dart` ; tests associés.
- **Modifiés** : `catalog/domain/product.dart` (categoryId, supplierIds, copyWith),
  `catalog/data/product_mapper.dart`, `catalog/application/catalog_controller.dart`,
  `catalog/presentation/{catalog_screen,product_card,product_detail_screen,product_form,product_picker_sheet}.dart`,
  `suppliers/presentation/{suppliers_screen,supplier_detail}.dart`,
  `inventory/presentation/inventory_screen.dart` (bouton réappro), les 4 `l10n/app_*.arb`.
- **Aucune** modification du domaine commandes/compta ; on **lit** `ordersProvider` et on **crée** des PO via
  l'API existante.

## Risques / atténuations

- **Migration enum→taxonomie** → id de nœud = ancien nom d'enum + lecture tolérante `categoryId ?? category`
  (schéma éprouvé sur les prestations). Toutes les références `ProductCategory` sont **internes au catalogue**
  (vérifié) → rayon de casse minimal.
- **Suppression fournisseur/catégorie orpheline** → garde-fous (S6/S2) : avertir / réassigner, jamais
  d'orphelin silencieux.
- **Duplication du moteur de taxonomie** (prestations vs catalogue) → assumée pour la stabilité ; extraction
  d'un `TaxonomyNode` générique possible plus tard (refactor à froid, hors périmètre).
- **`supplierIds` multi-sources** → commencer simple (liste d'ids en S4), enrichir en sourcing détaillé
  seulement si besoin (S7) — pas de sur-ingénierie.

## Ordre & revue

**S1 → S2 → S3 → S4 → S5 → S6 → (S7)**, une phase à la fois, revue entre chaque. Blocs livrables : après **S3**
le catalogue est complet et catégorisé ; après **S5** le lien fournisseur est visible ; après **S6** la boucle
est fermée. S7 est un bonus activable plus tard.
