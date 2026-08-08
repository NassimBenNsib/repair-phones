import 'package:flutter/foundation.dart';

import '../../invoices/domain/invoice.dart';

/// Nature d'une ligne de relevé client.
/// - [invoice] : facture émise → débit (le client doit).
/// - [deposit] : acompte porté sur la facture → crédit.
/// - [payment] : règlement d'une facture → crédit.
enum StatementEntryType { invoice, deposit, payment }

/// Une ligne du relevé de compte, avec solde courant.
@immutable
class StatementLine {
  const StatementLine({
    required this.date,
    required this.type,
    required this.reference,
    required this.debit,
    required this.credit,
    required this.balance,
    this.method,
  });

  final DateTime date;
  final StatementEntryType type;
  final String reference; // numéro de facture rattaché
  final double debit; // > 0 pour une facture
  final double credit; // > 0 pour un acompte / règlement
  final double balance; // solde courant après cette ligne
  final PaymentMethod? method; // pour un règlement
}

/// Relevé de compte d'un client : lignes chronologiques + totaux.
@immutable
class ClientStatement {
  const ClientStatement({
    required this.lines,
    required this.openingBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
    this.from,
    this.to,
  });

  final List<StatementLine> lines;
  final double openingBalance; // solde avant [from]
  final double totalDebit; // Σ débits de la période
  final double totalCredit; // Σ crédits de la période
  final double closingBalance; // openingBalance + totalDebit − totalCredit
  final DateTime? from;
  final DateTime? to;

  bool get isEmpty => lines.isEmpty;
}

// Événement brut avant calcul du solde.
class _Event {
  _Event(this.date, this.type, this.reference, this.debit, this.credit,
      this.method);
  final DateTime date;
  final StatementEntryType type;
  final String reference;
  final double debit;
  final double credit;
  final PaymentMethod? method;
}

int _typeRank(StatementEntryType t) => switch (t) {
      StatementEntryType.invoice => 0,
      StatementEntryType.deposit => 1,
      StatementEntryType.payment => 2,
    };

/// Construit le relevé d'un client à partir de **ses** factures.
///
/// Chaque facture émise génère un débit (total TTC), son acompte et chacun de
/// ses règlements génèrent des crédits datés. Le solde de clôture égale l'encours
/// (`Σ balanceDue`) lorsque aucune borne n'est posée. Pur et testable.
///
/// [from]/[to] (inclusifs) bornent la période affichée ; le solde d'ouverture
/// agrège les mouvements antérieurs à [from].
ClientStatement buildClientStatement(
  List<Invoice> clientInvoices, {
  DateTime? from,
  DateTime? to,
}) {
  final events = <_Event>[];
  for (final i in clientInvoices) {
    if (!i.isIssued) continue;
    final issued = i.issueDate ?? i.date;
    events.add(_Event(
        issued, StatementEntryType.invoice, i.number, i.totals.total, 0, null));
    if (i.deposit > 0.005) {
      events.add(_Event(
          issued, StatementEntryType.deposit, i.number, 0, i.deposit, null));
    }
    for (final p in i.payments) {
      events.add(_Event(p.date, StatementEntryType.payment, i.number, 0,
          p.amount, p.method));
    }
  }

  events.sort((a, b) {
    final d = a.date.compareTo(b.date);
    return d != 0 ? d : _typeRank(a.type).compareTo(_typeRank(b.type));
  });

  bool before(DateTime d) => from != null && d.isBefore(from);
  bool after(DateTime d) => to != null && d.isAfter(to);

  var opening = 0.0;
  for (final e in events) {
    if (before(e.date)) opening += e.debit - e.credit;
  }

  final lines = <StatementLine>[];
  var balance = opening;
  var totalDebit = 0.0;
  var totalCredit = 0.0;
  for (final e in events) {
    if (before(e.date) || after(e.date)) continue;
    balance += e.debit - e.credit;
    totalDebit += e.debit;
    totalCredit += e.credit;
    lines.add(StatementLine(
      date: e.date,
      type: e.type,
      reference: e.reference,
      debit: e.debit,
      credit: e.credit,
      balance: balance,
      method: e.method,
    ));
  }

  return ClientStatement(
    lines: lines,
    openingBalance: opening,
    totalDebit: totalDebit,
    totalCredit: totalCredit,
    closingBalance: opening + totalDebit - totalCredit,
    from: from,
    to: to,
  );
}
