# Atelier — Gestion d'atelier de réparation

Application **mobile-first** (PWA) de gestion complète pour un atelier de
réparation électronique & smartphone. Prototype fonctionnel et navigable,
données de démonstration réalistes, **état applicatif en mémoire** (aucune
persistance `localStorage`/`sessionStorage`).

## Stack

- **Next.js 15** (App Router) + **React 19** + **TypeScript**
- **Tailwind CSS v4** — design tokens centralisés (clair + sombre)
- État global : **React Context + `useReducer`** (`src/lib/store.tsx`)
- **PWA** : `manifest.webmanifest` + service worker (`public/sw.js`)

## Démarrer

```bash
npm install
npm run dev      # http://localhost:3000
npm run build && npm start
```

## Parcours & modules

| Onglet | Écran | Points clés |
|--------|-------|-------------|
| **Accueil** | Tableau de bord | CA jour/semaine/mois, sparkline, tuiles (ouverts, prêts, retard, stock bas), alertes, « à traiter aujourd'hui » |
| **Tickets** | Liste / Détail / Création | Recherche (client, IMEI, n°), segmented par statut, **timeline de statut interactive**, checklist, photos, lignes pièces/MO, génération devis/facture, assistant de création en 4 étapes |
| **Stock** | Liste / Détail | États visuels (ok/bas/rupture), filtre alertes & catégories, mouvements, **réassort** & ajustement d'inventaire |
| **Clients** | Liste / Fiche | Historique complet, appareils, total dépensé, actions rapides |
| **Plus** | Hub | Accès Factures, Planning, Réglages, équipe |
| — | **Devis & Factures** | Aperçu document, TVA 20 %, statuts, **encaissement** multi-moyen + reste dû |
| — | **Planning** | Charge par technicien, vue semaine des réparations promises |
| — | **Réglages** | Thème (clair/sombre/auto), profil atelier, TVA, garantie, techniciens, fournisseurs |

## Interconnexion des modules (état cohérent)

- Passer un ticket **« En réparation »** → **décrémente le stock** des pièces
  consommées et crée un **mouvement** (idempotent par ticket+pièce).
- **Générer une facture** depuis un ticket → reporte les lignes, rattache le
  document, met à jour le dashboard.
- **Encaisser** un paiement → met à jour le reste dû et bascule le statut en
  « Payé » quand le solde est atteint.
- Créer un ticket → crée client/appareil si nouveaux, apparaît partout.

## Design system

`src/app/globals.css` centralise les tokens (couleurs sémantiques, rayons,
ombres, animations). Accent **indigo profond**, surfaces neutres iOS, support
**clair + sombre** (`prefers-color-scheme` + bascule manuelle). Composants
réutilisables dans `src/components/` : `Card`, `ListGroup/ListRow`, `Badge`,
`Segmented`, `Button`, `Sheet`/`ActionSheet`, `Toast`, `Stepper`,
`EmptyState`, `Skeleton`, `StatusTimeline`, `Avatar`, `Sparkline`, jeu
d'icônes en trait (`Icon`).

## Structure

```
src/
  app/            # routes (App Router) : dashboard, tickets, stock, clients, factures, planning, plus, reglages
  components/     # design system + composants métier
  lib/            # types, seed (données démo), store (reducer), format, stats
public/           # manifest, service worker, icônes SVG
```

> Données de démonstration : ~20 tickets multi-statuts, 12 clients, 20 pièces
> (dont ruptures/stock bas), devis/factures variés, 4 techniciens, 3
> fournisseurs. Montants en € HT/TTC, TVA 20 %.
