import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/core/settings/vat_basis.dart';
import 'package:atelier_reparation/features/accounting/application/accounting_summary.dart';
import 'package:atelier_reparation/features/expenses/domain/expense.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:atelier_reparation/features/orders/domain/purchase_order.dart';
import 'package:flutter_test/flutter_test.dart';

PurchaseOrder _po(PoStatus status, double unitPrice) => PurchaseOrder(
      id: 'po1',
      number: 'CMD1',
      supplierId: 's1',
      status: status,
      date: DateTime(2026, 3, 1),
      receivedAt: DateTime(2026, 3, 2),
      lines: [LineItem(id: 'pl', label: 'part', qty: 1, unitPrice: unitPrice)],
      taxRate: 0.20,
    );

Invoice _inv({
  required String number,
  required DateTime? issueDate,
  required List<LineItem> lines,
  List<Payment> payments = const [],
}) =>
    Invoice(
      id: 'i-$number',
      number: number,
      clientId: 'c1',
      clientName: 'Client',
      status: InvoiceStatus.issued,
      date: DateTime(2026, 1, 1),
      issueDate: issueDate,
      lines: lines,
      payments: payments,
      taxRate: 0.20,
    );

void main() {
  final line100 =
      [const LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)];

  test('aggregates issued invoices of the year by month (HT/TVA/TTC)', () {
    final invoices = [
      _inv(
        number: 'FACT-2026-0001',
        issueDate: DateTime(2026, 3, 10),
        lines: line100,
        payments: [
          Payment(
              id: 'p1',
              date: DateTime(2026, 3, 15),
              amount: 50,
              method: PaymentMethod.cash),
        ],
      ),
      _inv(
        number: 'FACT-2026-0002',
        issueDate: DateTime(2026, 3, 20),
        lines: [const LineItem(id: 'l', label: 'y', qty: 2, unitPrice: 50)],
      ),
      // Draft (no number) → excluded.
      _inv(number: '', issueDate: DateTime(2026, 3, 25), lines: line100),
      // Prior year → excluded from 2026.
      _inv(
          number: 'FACT-2025-0009',
          issueDate: DateTime(2025, 12, 1),
          lines: line100),
    ];

    final s = computeYearSummary(invoices, 2026);

    final march = s.months[2]; // index 2 = mars
    expect(march.count, 2);
    expect(march.ht, closeTo(200, 1e-9));
    expect(march.vat, closeTo(40, 1e-9));
    expect(march.ttc, closeTo(240, 1e-9));

    expect(s.ht, closeTo(200, 1e-9));
    expect(s.vat, closeTo(40, 1e-9));
    expect(s.ttc, closeTo(240, 1e-9));
    expect(s.collected, closeTo(50, 1e-9));
    expect(s.outstanding, closeTo(190, 1e-9)); // (120-50) + 120
    expect(s.byMethod[PaymentMethod.cash], closeTo(50, 1e-9));
    expect(s.isEmpty, isFalse);

    // A year with no issued invoices is empty.
    expect(computeYearSummary(invoices, 2024).isEmpty, isTrue);
  });

  test('achats reçus → TVA déductible / nette due / marge', () {
    final s = computeYearSummary(
      [_inv(number: 'F1', issueDate: DateTime(2026, 3, 5), lines: [
        const LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 500),
      ])],
      2026,
      purchases: [_po(PoStatus.received, 100)],
    );
    expect(s.vat, closeTo(100, 1e-9)); // TVA collectée
    expect(s.purchasesVat, closeTo(20, 1e-9)); // TVA déductible
    expect(s.netVat, closeTo(80, 1e-9)); // nette due
    expect(s.purchasesHt, closeTo(100, 1e-9));
    expect(s.grossMargin, closeTo(400, 1e-9)); // 500 − 100
  });

  test('seules les commandes REÇUES comptent', () {
    final s = computeYearSummary(
      [_inv(number: 'F1', issueDate: DateTime(2026, 3, 5), lines: line100)],
      2026,
      purchases: [_po(PoStatus.draft, 100), _po(PoStatus.ordered, 100)],
    );
    expect(s.purchasesVat, 0);
    expect(s.netVat, closeTo(20, 1e-9)); // = TVA collectée (facture à 100)
  });

  test('dépenses → TVA déductible totale et résultat net', () {
    final s = computeYearSummary(
      [_inv(number: 'F1', issueDate: DateTime(2026, 3, 5), lines: [
        const LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 500),
      ])],
      2026,
      purchases: [_po(PoStatus.received, 100)],
      expenses: [
        Expense(
            id: 'e1',
            date: DateTime(2026, 4, 1),
            label: 'Loyer',
            category: ExpenseCategory.rent,
            amountHt: 200),
        // Hors exercice → ignoré.
        Expense(
            id: 'e2',
            date: DateTime(2025, 12, 1),
            label: 'Ancien',
            category: ExpenseCategory.other,
            amountHt: 999),
      ],
    );
    expect(s.expensesHt, closeTo(200, 1e-9));
    expect(s.expensesVat, closeTo(40, 1e-9));
    expect(s.deductibleVat, closeTo(60, 1e-9)); // 20 achat + 40 dépense
    expect(s.netVat, closeTo(40, 1e-9)); // 100 − 60
    expect(s.grossMargin, closeTo(400, 1e-9)); // 500 − 100
    expect(s.netResult, closeTo(200, 1e-9)); // 500 − 100 − 200
  });

  test('trésorerie fournisseurs : réglé (exercice) + reste dû (instantané)', () {
    // Commande reçue TTC 120 (100 + 20%), réglée 50 en 2026 et 30 en 2025.
    final po = PurchaseOrder(
      id: 'po1',
      number: 'CMD1',
      supplierId: 's1',
      status: PoStatus.received,
      date: DateTime(2026, 3, 1),
      receivedAt: DateTime(2026, 3, 2),
      taxRate: 0.20,
      lines: const [LineItem(id: 'pl', label: 'part', qty: 1, unitPrice: 100)],
      payments: [
        Payment(id: 'p1', date: DateTime(2026, 5, 1), amount: 50),
        Payment(id: 'p2', date: DateTime(2025, 12, 1), amount: 30),
      ],
    );

    final s = computeYearSummary(const <Invoice>[], 2026, purchases: [po]);
    // Réglé sur l'exercice = 50 (le règlement 2025 est exclu).
    expect(s.supplierPaid, closeTo(50, 1e-9));
    // Reste dû = 120 − (50 + 30) = 40 (instantané, tous exercices).
    expect(s.supplierPayable, closeTo(40, 1e-9));
  });

  test('TVA sur les encaissements vs sur les débits', () {
    // Facture TTC 600 (500 HT + 100 TVA), émise en 2026, réglée 300 en 2026.
    final invoice = _inv(
      number: 'F1',
      issueDate: DateTime(2026, 2, 1),
      lines: [const LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 500)],
      payments: [Payment(id: 'p', date: DateTime(2026, 3, 1), amount: 300)],
    );
    // Achat reçu TTC 240 (200 + 40 TVA), réglé 120 en 2026.
    final po = PurchaseOrder(
      id: 'po',
      number: 'CMD',
      supplierId: 's1',
      status: PoStatus.received,
      date: DateTime(2026, 1, 5),
      receivedAt: DateTime(2026, 1, 6),
      taxRate: 0.20,
      lines: const [LineItem(id: 'pl', label: 'part', qty: 1, unitPrice: 200)],
      payments: [Payment(id: 'pp', date: DateTime(2026, 1, 20), amount: 120)],
    );

    final accrual = computeYearSummary([invoice], 2026, purchases: [po]);
    expect(accrual.vat, closeTo(100, 1e-9)); // TVA facturée
    expect(accrual.deductibleVat, closeTo(40, 1e-9)); // TVA sur achat reçu
    expect(accrual.netVat, closeTo(60, 1e-9));

    final cash = computeYearSummary([invoice], 2026,
        purchases: [po], basis: VatBasis.cash);
    // Encaissé 300/600 → TVA collectée 50 ; réglé 120/240 → déductible 20.
    expect(cash.vat, closeTo(50, 1e-9));
    expect(cash.deductibleVat, closeTo(20, 1e-9));
    expect(cash.netVat, closeTo(30, 1e-9));
    // Le chiffre d'affaires (HT) reste en comptabilité d'engagement.
    expect(cash.ht, closeTo(500, 1e-9));
  });
}
