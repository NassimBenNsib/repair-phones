// ST1 — relevé de compte client : débits (factures), crédits (acomptes /
// règlements), solde courant, et bornes de période.

import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/clients/application/client_statement.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice({
  required String number,
  required DateTime date,
  required double unitPrice,
  double deposit = 0,
  List<Payment> payments = const [],
  InvoiceStatus status = InvoiceStatus.issued,
}) =>
    Invoice(
      id: number,
      number: status == InvoiceStatus.issued ? number : '',
      clientId: 'c1',
      clientName: 'Client',
      status: status,
      date: date,
      issueDate: status == InvoiceStatus.issued ? date : null,
      lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: unitPrice)],
      taxRate: 0, // TTC = HT pour simplifier les assertions
      deposit: deposit,
      payments: payments,
    );

void main() {
  test('débits, crédits et solde de clôture = encours', () {
    final invoices = [
      _invoice(number: 'F1', date: DateTime(2026, 1, 10), unitPrice: 100),
      _invoice(
        number: 'F2',
        date: DateTime(2026, 2, 5),
        unitPrice: 200,
        deposit: 50,
        payments: [
          Payment(id: 'p1', date: DateTime(2026, 2, 20), amount: 100),
        ],
      ),
    ];

    final s = buildClientStatement(invoices);

    // F1 débit 100 ; F2 débit 200, acompte 50, règlement 100.
    expect(s.totalDebit, closeTo(300, 1e-9));
    expect(s.totalCredit, closeTo(150, 1e-9));
    // Clôture = 300 − 150 = 150 (reste dû).
    expect(s.closingBalance, closeTo(150, 1e-9));

    // Lignes chronologiques : F1(100) → F2(200) → acompte(50) → règlement(100).
    expect(s.lines.map((l) => l.balance).toList(),
        [100.0, 300.0, 250.0, 150.0]);
    expect(s.lines.first.type, StatementEntryType.invoice);
    expect(s.lines[2].type, StatementEntryType.deposit);
    expect(s.lines.last.type, StatementEntryType.payment);
  });

  test('les brouillons sont exclus', () {
    final s = buildClientStatement([
      _invoice(
          number: 'D1',
          date: DateTime(2026, 3, 1),
          unitPrice: 999,
          status: InvoiceStatus.draft),
    ]);
    expect(s.isEmpty, isTrue);
    expect(s.closingBalance, 0);
  });

  test('bornes de période : solde d\'ouverture agrège l\'antérieur', () {
    final invoices = [
      _invoice(number: 'F1', date: DateTime(2026, 1, 10), unitPrice: 100),
      _invoice(number: 'F2', date: DateTime(2026, 2, 10), unitPrice: 200),
    ];

    final s = buildClientStatement(invoices, from: DateTime(2026, 2, 1));
    // F1 (janvier) → solde d'ouverture ; seule F2 est visible.
    expect(s.openingBalance, closeTo(100, 1e-9));
    expect(s.lines.length, 1);
    expect(s.lines.single.reference, 'F2');
    expect(s.lines.single.balance, closeTo(300, 1e-9));
    expect(s.closingBalance, closeTo(300, 1e-9));
  });
}
