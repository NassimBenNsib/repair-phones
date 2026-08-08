# Plans de modules — Atelier Réparation

Plans détaillés et autonomes pour les modules métier. Chaque document est exécutable
indépendamment une fois les **fondations (00)** en place.

## Ordre de construction

1. [00 — Fondations](00-foundations.md) *(prérequis : Drift, kit domaine, numérotation, scaffolds, PDF, auth core)*
2. [A — Fournisseurs](A-fournisseurs.md)
3. [B — Clients](B-clients.md) *(complète l'existant)*
4. [C — Employés](C-employes.md)
5. [D — Users & Auth](D-users-auth.md)
6. [E — Commandes](E-commandes.md)
7. [F — Devis](F-devis.md)
8. [G — Factures](G-factures.md)

## Conventions partagées (tous les modules)

- **Architecture** : `domain/` (modèles immuables + `copyWith`), `data/` (table Drift + repository),
  `application/` (Riverpod `AsyncNotifier`), `presentation/` (écrans).
- **Persistance** : couche **flexible et interchangeable** — mémoire / local (Drift) / serveur /
  hybride, choisie par configuration **par collection** (voir 00). Chaque fonctionnalité parle à
  `EntityStore<T>` via un `AsyncNotifier<List<T>>` ; les écrans ne savent pas *où* les données vivent.
  Les listes gèrent `AsyncValue` (chargement / erreur / données).
- **Écran liste** : `EntityListScaffold` adaptatif (maître/détail selon `detailLayout.useTwoPane`,
  recherche, filtres, `＋`). Réutilise le patron de
  `repairs_screen.dart` / `clients_screen.dart`.
- **Écran détail** : `EntityDetailScaffold` avec bascule **Consulter / Modifier / Enregistrer /
  Annuler**, brouillon `copyWith`, menu `⋯`. Réutilise le patron de `repair_detail.dart`.
- **Composants réutilisés** : `AppleTextField`, `AppleSegmentedControl`, `AppleSheet`,
  `AppleListSection/Row`, `AppleBadge`, `AppleButton`, `AppleChip`, `AppleMenuButton`,
  `ContactInfoCard`, `EntityPickerSheet` (00).
- **i18n** : ajouter les clés aux 4 ARB (`app_fr/en/ar/es.arb`) puis `flutter gen-l10n`. Layout
  direction-aware (`EdgeInsetsDirectional`, `context.chevronForward/backIcon`).
- **Navigation** : passer `placeholder:true → false` dans
  `core/navigation/app_sections.dart` + ajouter la route dans `core/router/app_router.dart`.
- **Vérification par module** : `flutter analyze` (0) → `flutter test` → `flutter build web --release`,
  + test manuel CRUD/liens + **persistance après redémarrage**.

## État actuel (rappel)

Déjà réels : Dashboard, Réparations (riche), Clients (liste + détail + actions), Catalogue
(produits + variantes), Prestations (modèles). Stores **en mémoire** (à migrer vers Drift en 00).
Pas d'auth, pas de persistance hors préférences.

## Légende des champs

`?` = nullable · `FK` = clé étrangère · `enum` = énumération dédiée · `€` = montant (double, 2 déc.)
