# G — Factures (Invoices) — complet

**But** : facturer le client, numérotation **légale**, suivi des **paiements**, PDF, relances.
**Dépendances** : 00 (LineItem/Totals, numérotation légale, PDF), B (Clients), F (Devis → Facture),
Réparations (facturer une fiche). **Section nav** : `invoices`. **Alimente** : Dashboard/Rapports.

---

## G1 — Domaine + DB

```
enum InvoiceStatus { draft, issued, partial, paid, overdue, cancelled }
enum PaymentMethod { cash, card, transfer, check }

class Payment { String id; String invoiceId; DateTime date; double amount; PaymentMethod method; }

class Invoice {
  String id; String? number;        // légal, assigné à l'ÉMISSION (immuable, sans trou)
  String clientId;                  // FK
  String? quoteId; String? repairId;
  InvoiceStatus status;             // défaut draft
  DateTime? issueDate; DateTime? dueDate;
  List<LineItem> lines;
  double discount; double taxRate; double deposit; // acompte
  Totals get totals; double get paid; double get balanceDue; // total - deposit - paid
}
```
Tables `invoices`, `invoice_lines`, `payments`.

## G2 — Repository + numérotation légale

`invoicesProvider = AsyncNotifier<List<Invoice>>`. **Numéro assigné uniquement à `Émettre`** via
`NumberingService.next('FACT')` — **séquentiel, sans trou, immuable**. Brouillon = sans numéro,
modifiable ; émise = verrouillée (seuls paiements/annulation possibles). **Test unitaire** de la séquence.

## G3 — Liste (`invoices_screen.dart`)

- Adaptatif ; recherche (numéro / client) ; **filtres** : statut, **impayées**, **en retard** ;
  tri (récent / montant / échéance) ; `＋` (**vierge** / **depuis devis** / **depuis réparation**).
- Row : `number` (ou « Brouillon »), client, badge statut (rouge impayé / orange partiel / vert payé),
  échéance (rouge si en retard), **total TTC** + **solde**.

## G4 — Détail (`invoice_detail.dart`)

- **En-tête** : `number`/Brouillon, badge statut, client (picker), `issueDate`, `dueDate`.
- **Lignes** : éditeur (prestations + pièces) — **édition possible seulement en brouillon**.
- **Récapitulatif financier** : `Totals` + **acompte** + **solde dû** (mis en évidence) + badge paiement.
- **Paiements** : liste (date, montant, méthode) + action **Enregistrer un paiement**
  (sheet : montant, méthode, date) → recalcule statut `partial`/`paid`.
- **Notes**.

## G5 — Actions & workflow

- **Émettre** : `draft → issued`, assigne `number` + `issueDate` (+ `dueDate` par défaut = +30 j),
  verrouille les lignes.
- **Exporter / Imprimer PDF** (`DocumentPdf`).
- **Enregistrer un paiement** → maj statut (solde 0 ⇒ `paid`, partiel ⇒ `partial`).
- **En retard** : `dueDate` dépassée & solde > 0 ⇒ `overdue` (calcul à l'affichage).
- **Annuler / Avoir** : facture émise non payée → `cancelled` (jamais supprimée) ; avoir = facture
  négative liée (v2).

## G6 — Liens, rollups, i18n, vérif

- Devis→Facture (F), Réparation→Facture (bouton dans le détail réparation « Générer la facture »),
  **A/R client** (bloc dans le détail client) ; **Dashboard/Rapports** : CA encaissé, impayés, en retard.
- **i18n** : `navInvoices`(existe), `invoiceNew`, `invoiceNumber`, `invoiceStatus*` (6),
  `invoiceIssue`, `invoiceDueDate`, `invoiceDeposit`, `invoiceBalance`, `invoiceRecordPayment`,
  `paymentMethodCash/Card/Transfer/Check`, `invoiceFromQuote`, `invoiceFromRepair`, `invoiceCancel`,
  `invoiceOverdue`, `invoicePaid/Partial`, `invoiceEmpty`.
- `app_sections.dart`/route. Vérif : brouillon → émission (numéro immuable) → PDF → paiement partiel →
  soldé ; en retard ; persistance ; RTL ; thèmes ; `analyze/test/build`.

## Cas limites & légal
- **Numéro immuable, sans trou, par année** — jamais réutilisé même si annulée.
- Facture émise **non supprimable** (annulation seulement) — obligation légale.
- Paiement > solde → refuser ou créer un avoir.
- Modifier une facture émise → interdit (créer un avoir + nouvelle facture).
- Multidevise / TVA multiple par ligne → v2 (documenter).
