# D — Users & Auth (complet : login + PIN + rôles)

**But** : comptes de connexion, rôles/permissions, authentification (email/mot de passe + PIN comptoir),
verrouillage de l'app et des actions selon les droits.
**Dépendances** : 00 (auth core), C (Employés — lien compte↔personne). **Section nav** : `users`.

---

## D1 — Domaine + DB

```
class Permission (enum) { manageUsers, manageEmployees, manageCatalog, manageSuppliers,
  createRepair, createQuote, createInvoice, recordPayment, receiveOrder, viewReports, changeSettings }

class Role { String id; String name; Set<Permission> permissions; bool system; }

class User {
  String id; String email; String passwordHash; String? pinHash;
  String roleId;        // FK roles
  String? employeeId;   // FK employees (0..1)
  bool active; DateTime createdAt;
}
```
Tables `roles`, `users` (permissions en CSV). **Seed** : rôles *Admin* (toutes), *Technicien*
(repairs/quotes/catalog en lecture), *Caisse* (invoice/payment) ; 1 utilisateur Admin (PIN affiché 1 fois).

## D2 — Flux d'authentification

- `presentation/login_screen.dart` — deux modes via segmented :
  - **Email + mot de passe** (managers) ;
  - **PIN comptoir** — pavé numérique custom (grille 3×4, points de saisie), sélection utilisateur puis
    PIN. Rapide pour changer d'opérateur.
- `AuthService.login/loginPin` (00) → `SessionController` met à jour l'utilisateur courant ; jeton
  persistant (`shared_preferences`).
- **Garde go_router** : `redirect` → `/login` si pas de session ; après login → dernière route.
- **Déconnexion** depuis le pied de la barre latérale (chip compte) → confirmer → `/login`.

## D3 — Gestion des utilisateurs (`users_screen.dart` + `user_detail.dart`)

Réservé **Admin** (permission `manageUsers`).
- Liste : email, rôle (badge), employé lié, actif/inactif ; recherche.
- Détail / création : `email`, mot de passe (création/reset), **PIN** (4–6 chiffres),
  `AppleSegmentedControl`/picker **Rôle**, **Employé lié** (picker employees), Actif.
- Actions : réinitialiser PIN/mot de passe, activer/désactiver, supprimer (sauf soi-même / dernier admin).
- **Rôles** : écran secondaire (liste + édition des permissions via cases à cocher) — ou figé aux 3 rôles
  seed en v1 (option simple).

## D4 — Verrouillage par permission

- `can(Permission)` (extension `WidgetRef`) — depuis le rôle de la session.
- **Nav** : masquer/ griser les sections selon droits (`app_sections.dart` + `app_shell.dart` :
  filtrer `appSections` par permission).
- **Actions** : masquer/désactiver boutons destructifs & sensibles (émettre facture, encaisser,
  réceptionner, supprimer) selon `can`.
- **Données sensibles** (ex. code de déverrouillage appareil) visibles seulement avec droit.

## D5 — i18n + vérif

- **i18n** : `navUsers`(existe), `authLoginTitle`, `authEmail`, `authPassword`, `authPin`,
  `authSignIn`, `authLogout`, `authWrongCredentials`, `userNew`, `userRole`, `userLinkedEmployee`,
  `userResetPin`, `userActive`, `roleAdmin/Technician/Cashier`, `permission*` (libellés).
- Vérif : login email + PIN, redirection garde, gating d'une section/action, reset PIN, persistance de
  session après redémarrage, RTL (pavé PIN), thèmes, `analyze/test/build`.

## Cas limites & sécurité
- **Ne jamais** stocker de mot de passe/PIN en clair (sha256 + sel ; PIN court ⇒ acceptable en local,
  documenter la limite).
- Empêcher la suppression/désactivation du **dernier Admin**.
- Verrouillage après N échecs de PIN (temporisation) — option.
- Session expirée / app relancée hors ligne → re-login local (base Drift disponible).
