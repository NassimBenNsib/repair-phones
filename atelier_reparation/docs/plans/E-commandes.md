# E — Commandes (Bons d'achat / Purchase Orders)

**But** : commander des pièces à un fournisseur, suivre la réception, **réapprovisionner le stock**.
**Dépendances** : 00, A (Fournisseurs), Catalogue (produits/variantes existants), 0.2 (`LineItem`/`Totals`),
0.3 (numérotation). **Section nav** : `orders` (placeholder).

---

## E1 — Domaine + DB

```
enum PoStatus { draft, ordered, received, cancelled }

class PurchaseOrderLine {
  String id; String? productId; String? variantId; // FK catalogue (nullable = libre)
  String label; double qty; double unitPrice; double taxRate;
}
class PurchaseOrder {
  String id; String number;            // CMD-YYYY-#### (à la validation)
  String supplierId;                   // FK
  PoStatus status;                     // défaut draft
  DateTime date; DateTime? expectedDate; DateTime? receivedAt;
  List<PurchaseOrderLine> lines; String? notes;
  Totals get totals => Totals.compute(lines);
}
```
Tables `purchase_orders`, `purchase_order_lines`.

## E2 — Repository + provider

`purchaseOrdersProvider = AsyncNotifier<List<PurchaseOrder>>`. Chargement des lignes en jointure.

## E3 — Liste (`orders_screen.dart`)

- Adaptatif ; recherche (numéro / fournisseur) ; **filtres statut** (chips) + filtre fournisseur ;
  tri (récent / montant) ; `＋`.
- Row : `number`, fournisseur, badge statut, date, **total TTC**.

## E4 — Détail (`order_detail.dart`)

- **En-tête** : `number`, badge statut, fournisseur (via **supplier_picker**), dates (pickers).
- **Lignes** : éditeur de lignes — ajouter via **product_picker** (catalogue) *ou* saisie libre ;
  colonnes qté × PU (+ TVA) ; suppression ; total par ligne.
- **Totaux** : `Totals` (HT / TVA / TTC).
- **Notes**.
- **Édition inline** ; workflow **statut** : `draft → ordered → received` (+ `cancelled`).

## E5 — Réception & stock

- Action **« Réceptionner »** (statut `received`, `receivedAt=now`) → pour chaque ligne liée à une
  variante catalogue : **incrémenter le stock** (`catalog_controller`/repository) de `qty`.
- Réception partielle (option) : quantité reçue par ligne. v1 = réception totale.
- Journaliser un mouvement de stock (table `stock_movements`) — recommandé pour la traçabilité.

## E6 — i18n + vérif

- **i18n** : `navOrders`(existe), `orderNew`, `orderNumber`, `orderStatusDraft/Ordered/Received/
  Cancelled`, `orderExpectedDate`, `orderReceive`, `orderSupplier`, `orderAddLine`, `orderEmpty`,
  `orderQty`, `orderUnitPrice`. (`priceLabel`, `stockLabel`, totaux réutil.)
- `app_sections.dart`/route. Vérif : création → commande → réception **incrémente le stock visible dans
  Catalogue**, persistance, RTL, thèmes, `analyze/test/build`.

## Cas limites
- Réceptionner deux fois → bloquer (statut déjà `received`).
- Ligne libre (sans `productId`) → pas d'impact stock.
- Annuler après réception → interdit (ou créer un mouvement inverse).
- Fournisseur/produit supprimé → garder le libellé caché (`label`) pour l'historique.
