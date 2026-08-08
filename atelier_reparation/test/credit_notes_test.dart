// Avoirs (CN1) : émission avec numéro légal, et réduction des ventes / TVA
// collectée dans la synthèse comptable.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/accounting/application/accounting_summary.dart';
import 'package:atelier_reparation/features/invoices/application/credit_notes_controller.dart';
import 'package:atelier_reparation/features/invoices/domain/credit_note.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _inv(double unitPrice) => Invoice(
      id: 'i1',
      number: 'F1',
      clientId: 'c1',
      clientName: 'Client',
      status: InvoiceStatus.issued,
      date: DateTime(2026, 3, 5),
      issueDate: DateTime(2026, 3, 5),
      lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: unitPrice)],
      taxRate: 0.20,
    );

void main() {
  test('émission : numéro légal AVOIR + verrouillage', () {
    final c = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(c.dispose);
    final ctrl = c.read(creditNotesProvider.notifier);

    final cn = ctrl.createFrom(
      clientId: 'c1',
      clientName: 'Client',
      invoiceId: 'i1',
      lines: [const LineItem(id: 'l', label: 'Retour écran', qty: 1, unitPrice: 50)],
      reason: 'Retour',
    );
    expect(cn.isIssued, isFalse);

    ctrl.issue(cn.id, now: DateTime(2026, 3, 10));
    final issued = ctrl.byId(cn.id)!;
    expect(issued.number, 'AVOIR-2026-0001');
    expect(issued.status, CreditNoteStatus.issued);
    expect(issued.totals.total, closeTo(60, 1e-9)); // 50 + 20%

    // Ré-émission → no-op (numéro immuable).
    ctrl.issue(cn.id);
    expect(ctrl.byId(cn.id)!.number, 'AVOIR-2026-0001');
  });

  test('comptabilité : un avoir réduit les ventes et la TVA collectée', () {
    final creditNote = CreditNote(
      id: 'av1',
      number: 'AVOIR-2026-0001',
      clientId: 'c1',
      clientName: 'Client',
      status: CreditNoteStatus.issued,
      date: DateTime(2026, 3, 10),
      issueDate: DateTime(2026, 3, 10),
      lines: [const LineItem(id: 'l', label: 'Retour', qty: 1, unitPrice: 100)],
      taxRate: 0.20,
    );

    final s = computeYearSummary([_inv(500)], 2026, creditNotes: [creditNote]);
    // Ventes 500 − avoir 100 = 400 HT ; TVA 100 − 20 = 80.
    expect(s.ht, closeTo(400, 1e-9));
    expect(s.vat, closeTo(80, 1e-9));
    expect(s.creditsHt, closeTo(100, 1e-9));
    expect(s.creditsVat, closeTo(20, 1e-9));
    expect(s.netVat, closeTo(80, 1e-9)); // pas d'achats/dépenses

    // Un avoir brouillon (non émis) ne compte pas.
    final draft = computeYearSummary([_inv(500)], 2026, creditNotes: [
      creditNote.copyWith(number: '', status: CreditNoteStatus.draft),
    ]);
    expect(draft.creditsHt, 0);
    expect(draft.vat, closeTo(100, 1e-9));
  });
}
