# F — Devis (Quotes) — complet

**But** : établir un devis (prestations + pièces), le faire accepter, l'exporter en PDF, le convertir en
facture.
**Dépendances** : 00 (LineItem/Totals, numérotation, PDF), B (Clients), Catalogue + Prestations
(sélecteurs existants), Réparations (créer un devis depuis une fiche). **Section nav** : `quotes`.

---

## F1 — Domaine + DB

```
enum QuoteStatus { draft, sent, accepted, refused, expired }

class Quote {
  String id; String number;         // DEVIS-YYYY-####
  String clientId;                  // FK
  String? repairId;                 // FK optionnel (origine)
  QuoteStatus status;               // défaut draft
  DateTime date; DateTime? validUntil;
  List<LineItem> lines;             // prestations + pièces
  double discount; double taxRate;  // remise €, TVA globale (ou par ligne)
  String? notes;
  Totals get totals => Totals.compute(lines, discount: discount, globalTaxRate: taxRate);
}
```
Tables `quotes`, `quote_lines`.

## F2 — Repository + provider

`quotesProvider = AsyncNotifier<List<Quote>>`. Numéro assigné à la création (brouillon) ou à l'envoi
(choix : brouillon sans numéro, `DEVIS-…` à l'envoi — recommandé).

## F3 — Liste (`quotes_screen.dart`)

- Adaptatif ; recherche (numéro / client) ; **filtres statut** ; tri (récent / montant) ;
  `＋` (**vierge** ou **depuis une réparation** → pré-remplit lignes = prestations+pièces de la fiche).
- Row : `number`, client, badge statut, date, **total TTC**, pastille « expire le… » si proche.

## F4 — Détail (`quote_detail.dart`)

- **En-tête** : `number`, badge statut, **client** (client_picker), `date`, `validUntil` (date picker).
- **Lignes** : éditeur — **prestations** via `service_picker_sheet` (existe) + **pièces** via
  `product_picker` (catalogue) ; qté × PU ; remise par ligne (option). Total par ligne.
- **Récapitulatif** : `Totals` (HT / remise / TVA / TTC) — carte claire, total en évidence.
- **Notes / conditions**.
- **Édition inline** ; workflow **statut**.

## F5 — Actions

- **Exporter / Imprimer PDF** (`DocumentPdf`, 0.5) — en-tête entreprise + client + lignes + totaux.
- **Envoyer** → `sent` (+ événement).
- **Accepter / Refuser** → `accepted`/`refused`.
- **Convertir en facture** → crée une `Invoice` (G) reprenant client + lignes + totaux, lie `quoteId`.
- Expiration auto : `validUntil` dépassé & non accepté → `expired` (calcul à l'affichage).

## F6 — i18n + vérif

- **i18n** : `navQuotes`(existe), `quoteNew`, `quoteNumber`, `quoteStatusDraft/Sent/Accepted/Refused/
  Expired`, `quoteValidUntil`, `quoteFromRepair`, `quoteSend`, `quoteAccept`, `quoteRefuse`,
  `quoteConvertInvoice`, `quoteEmpty`, `quoteDiscount`, `quoteSubtotal`, `quoteTax`, `quoteTotal`.
- `app_sections.dart`/route. Vérif : création (vierge + depuis réparation), lignes via les 2 sélecteurs,
  PDF, conversion en facture, persistance, RTL, thèmes, `analyze/test/build`.

## Cas limites
- Devis accepté puis modifié → verrouiller l'édition (ou versionner).
- Conversion multiple d'un même devis → empêcher (garder `invoiceId` de liaison).
- Ligne sans prix (prestation gratuite) → autorisée.
- Remise > total → clamp.
