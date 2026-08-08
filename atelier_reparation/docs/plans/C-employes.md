# C — Employés (Staff)

**But** : fiches du personnel (poste, commission, affectations), reliables à un compte utilisateur.
**Dépendances** : 00. **Utilisé par** : Users/Auth (D, lien compte), Réparations (technicien assigné),
Factures (commission — futur). **Section nav** : `staff` (placeholder).

> Rappel de conception : **Employé ≠ compte**. L'employé est la *personne* (assignable, commissionnée)
> ; le compte (module D) est l'*identité de connexion*. Lien 1 ↔ 0..1.

---

## C1 — Domaine + DB

```
class Employee {
  String id;
  String name;
  String? jobTitle;        // poste (Technicien, Accueil…)
  String phone;
  String? email;
  DateTime? hireDate;      // embauche
  double commissionRate;   // 0..1, défaut 0
  bool active;             // défaut true
  String? userId;          // FK vers users (module D), nullable
  DateTime createdAt;
  Employee copyWith(...);
}
```
Table Drift `employees`.

## C2 — Repository + provider

`employeeRepository` + `employeesProvider = AsyncNotifier<List<Employee>>`. Recherche : `name / jobTitle
/ phone`. Filtre : actifs / tous.

## C3 — Écran liste (`employees_screen.dart`)

- `EntityListScaffold` adaptatif ; recherche ; filtre **Actifs** ; `＋`.
- Row : avatar, `name`, `jobTitle`, badge inactif si `!active`, sous-titre `phone`.

## C4 — Détail (`employee_detail.dart`)

- **En-tête** : avatar + `name` + `jobTitle` + badge actif/inactif.
- **Coordonnées** : `ContactInfoCard`.
- **Emploi** : `jobTitle`, `hireDate` (date picker en édition), `commissionRate` (%).
- **Réparations assignées** : liste des réparations où `assignedTech == name/id` (statut), tap → détail.
- **Compte lié** : si `userId` → afficher rôle + « Gérer » ; sinon bouton **Créer un compte** (ouvre le
  détail User en création pré-rempli, module D) ou **Lier un compte** (picker users).
- **Édition inline** ; **⋯** : Activer/Désactiver, Supprimer (si non lié/aucune assignation).

## C5 — i18n + vérif

- **i18n** : `navStaff`(existe), `staffNew`, `staffJobTitle`, `staffHireDate`, `staffCommission`,
  `staffActive`, `staffInactive`, `staffAssignedRepairs`, `staffLinkedAccount`, `staffCreateAccount`,
  `staffLinkAccount`, `staffEmpty`, `staffSearch`.
- `app_sections.dart` : `staff` réel ; route. Vérif CRUD + lien + persistance + RTL + thèmes + build.

## Cas limites
- Commission hors [0,1] → clamp + validation.
- Désactiver un employé assigné à des réparations en cours → autorisé mais **avertir**.
- Suppression d'un employé lié à un compte → délier d'abord (ou interdire).
