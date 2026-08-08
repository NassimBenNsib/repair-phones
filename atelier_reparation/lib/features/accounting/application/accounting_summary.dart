import '../../../core/settings/vat_basis.dart';
import '../../expenses/domain/expense.dart';
import '../../invoices/domain/credit_note.dart';
import '../../invoices/domain/invoice.dart';
import '../../orders/domain/purchase_order.dart';

/// Totaux d'un mois (HT / TVA / TTC + nombre de factures).
class MonthTotals {
  MonthTotals();
  double ht = 0;
  double vat = 0;
  double ttc = 0;
  int count = 0;
}

/// Synthèse comptable d'un exercice, calculée depuis les factures émises.
class YearSummary {
  YearSummary(this.year, {this.basis = VatBasis.accrual})
      : months = List.generate(12, (_) => MonthTotals(), growable: false);

  final int year;

  /// Régime d'exigibilité de la TVA (débits vs encaissements).
  final VatBasis basis;
  final List<MonthTotals> months; // index 0 = janvier
  double collected = 0;
  double outstanding = 0;
  final Map<PaymentMethod, double> byMethod = {};

  // Achats (commandes fournisseurs reçues) → TVA déductible.
  double purchasesHt = 0;
  double purchasesVat = 0;
  double purchasesTtc = 0;
  int purchasesCount = 0;

  // Trésorerie fournisseurs (AP) : réglé sur l'exercice + reste dû (instantané).
  double supplierPaid = 0; // règlements fournisseurs datés dans l'exercice
  double supplierPayable = 0; // reste dû sur commandes reçues (instantané)

  // TVA « sur les encaissements » : part de TVA des règlements datés dans
  // l'exercice (ventes = collectée ; achats = déductible).
  double cashVatCollected = 0;
  double cashVatDeductible = 0;

  // Dépenses / charges → TVA déductible.
  double expensesHt = 0;
  double expensesVat = 0;
  int expensesCount = 0;

  // Avoirs (notes de crédit émises) → réduisent les ventes et la TVA collectée.
  double creditsHt = 0;
  double creditsVat = 0;
  int creditsCount = 0;

  double get _salesHt => months.fold(0.0, (s, m) => s + m.ht);
  double get _salesVat => months.fold(0.0, (s, m) => s + m.vat);

  /// HT des ventes, net des avoirs.
  double get ht => _salesHt - creditsHt;

  /// TVA collectée, nette des avoirs. Sur base « encaissements », part de TVA
  /// des règlements clients ; sinon TVA facturée (débits).
  double get vat =>
      (basis == VatBasis.cash ? cashVatCollected : _salesVat) - creditsVat;
  double get ttc =>
      months.fold(0.0, (s, m) => s + m.ttc) - (creditsHt + creditsVat);
  int get count => months.fold(0, (s, m) => s + m.count);

  /// TVA déductible totale (achats + dépenses). Sur base « encaissements »,
  /// la TVA des achats suit les règlements fournisseurs.
  double get deductibleVat =>
      (basis == VatBasis.cash ? cashVatDeductible : purchasesVat) + expensesVat;

  /// TVA nette due = TVA collectée (nette d'avoirs) − TVA déductible.
  double get netVat => vat - deductibleVat;

  /// Résultat brut = HT ventes (net d'avoirs) − HT achats.
  double get grossMargin => ht - purchasesHt;

  /// Résultat net = HT ventes − HT achats − HT dépenses.
  double get netResult => ht - purchasesHt - expensesHt;

  bool get isEmpty =>
      count == 0 &&
      purchasesCount == 0 &&
      expensesCount == 0 &&
      creditsCount == 0;
}

/// Agrège les factures **émises** de l'exercice [year] par mois (`issueDate`),
/// avec encaissé/impayé, ventilation des paiements par moyen, et les **achats**
/// (commandes fournisseurs **reçues**) pour la TVA déductible / la TVA nette.
YearSummary computeYearSummary(
  List<Invoice> invoices,
  int year, {
  List<PurchaseOrder> purchases = const [],
  List<Expense> expenses = const [],
  List<CreditNote> creditNotes = const [],
  VatBasis basis = VatBasis.accrual,
}) {
  final s = YearSummary(year, basis: basis);
  for (final i in invoices) {
    if (!i.isIssued) continue;
    // TVA sur les encaissements : datée par règlement (tous exercices d'émission
    // confondus) ; l'acompte est réputé encaissé à l'émission.
    final t0 = i.totals;
    final vatFrac = t0.total > 0 ? t0.taxAmount / t0.total : 0.0;
    if (i.deposit > 0.005 && i.issueDate?.year == year) {
      s.cashVatCollected += i.deposit * vatFrac;
    }
    for (final p in i.payments) {
      if (p.date.year == year) s.cashVatCollected += p.amount * vatFrac;
    }
    if (i.issueDate?.year != year) continue;
    final m = s.months[i.issueDate!.month - 1];
    final t = i.totals;
    m.ht += t.subtotal;
    m.vat += t.taxAmount;
    m.ttc += t.total;
    m.count += 1;
    s.collected += i.amountPaid;
    s.outstanding += i.balanceDue;
    for (final p in i.payments) {
      if (p.date.year == year) {
        s.byMethod[p.method] = (s.byMethod[p.method] ?? 0) + p.amount;
      }
    }
  }

  for (final po in purchases) {
    if (po.status == PoStatus.cancelled) continue;
    // Sortie de trésorerie + TVA déductible sur les encaissements : règlements
    // fournisseurs datés dans l'exercice.
    final pt = po.totals;
    final pFrac = pt.total > 0 ? pt.taxAmount / pt.total : 0.0;
    for (final p in po.payments) {
      if (p.date.year == year) {
        s.supplierPaid += p.amount;
        s.cashVatDeductible += p.amount * pFrac;
      }
    }
    if (po.status != PoStatus.received) continue;
    // Reste dû (passif courant, instantané — non borné à l'exercice).
    s.supplierPayable += po.balanceDue;
    final when = po.receivedAt ?? po.date;
    if (when.year != year) continue;
    final t = po.totals;
    s.purchasesHt += t.subtotal;
    s.purchasesVat += t.taxAmount;
    s.purchasesTtc += t.total;
    s.purchasesCount += 1;
  }

  for (final e in expenses) {
    if (e.date.year != year) continue;
    s.expensesHt += e.amountHt;
    s.expensesVat += e.vatAmount;
    s.expensesCount += 1;
  }

  for (final cn in creditNotes) {
    if (!cn.isIssued || cn.issueDate?.year != year) continue;
    final t = cn.totals;
    s.creditsHt += t.subtotal;
    s.creditsVat += t.taxAmount;
    s.creditsCount += 1;
  }
  return s;
}
