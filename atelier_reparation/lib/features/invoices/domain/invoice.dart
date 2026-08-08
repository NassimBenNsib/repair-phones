import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/totals.dart';
import '../../../l10n/app_localizations.dart';

/// Statut d'une facture.
enum InvoiceStatus { draft, issued, partial, paid, overdue, cancelled }

extension InvoiceStatusX on InvoiceStatus {
  String label(AppLocalizations l) => switch (this) {
        InvoiceStatus.draft => l.invoiceStatusDraft,
        InvoiceStatus.issued => l.invoiceStatusIssued,
        InvoiceStatus.partial => l.invoiceStatusPartial,
        InvoiceStatus.paid => l.invoiceStatusPaid,
        InvoiceStatus.overdue => l.invoiceStatusOverdue,
        InvoiceStatus.cancelled => l.invoiceStatusCancelled,
      };

  Color color(AppleColors c) => switch (this) {
        InvoiceStatus.draft => c.secondaryLabel,
        InvoiceStatus.issued => c.blue,
        InvoiceStatus.partial => c.orange,
        InvoiceStatus.paid => c.green,
        InvoiceStatus.overdue => c.red,
        InvoiceStatus.cancelled => c.secondaryLabel,
      };
}

/// Moyen de paiement. `credit` = réglé depuis l'avoir/compte client
/// (usage programmatique, exclu de la saisie manuelle).
enum PaymentMethod { cash, card, transfer, check, credit }

extension PaymentMethodX on PaymentMethod {
  String label(AppLocalizations l) => switch (this) {
        PaymentMethod.cash => l.paymentMethodCash,
        PaymentMethod.card => l.paymentMethodCard,
        PaymentMethod.transfer => l.paymentMethodTransfer,
        PaymentMethod.check => l.paymentMethodCheck,
        PaymentMethod.credit => l.paymentMethodCredit,
      };

  /// Moyens sélectionnables manuellement (exclut l'avoir).
  static List<PaymentMethod> get manual =>
      PaymentMethod.values.where((m) => m != PaymentMethod.credit).toList();
}

/// Encaissement rattaché à une facture.
@immutable
class Payment {
  const Payment({
    required this.id,
    required this.date,
    required this.amount,
    this.method = PaymentMethod.cash,
  });

  final String id;
  final DateTime date;
  final double amount;
  final PaymentMethod method;

  Map<String, Object?> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'method': method.name,
      };

  factory Payment.fromJson(Map<String, Object?> j) => Payment(
        id: j['id'] as String,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime(2024),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        method: PaymentMethod.values.firstWhere(
          (m) => m.name == j['method'],
          orElse: () => PaymentMethod.cash,
        ),
      );
}

/// Facture client. Le numéro légal est attribué à l'émission (immuable).
@immutable
class Invoice {
  const Invoice({
    required this.id,
    this.number = '',
    required this.clientId,
    required this.clientName,
    this.quoteId,
    this.repairId,
    this.status = InvoiceStatus.draft,
    required this.date,
    this.issueDate,
    this.dueDate,
    this.lines = const [],
    this.payments = const [],
    this.discount = 0,
    this.taxRate = 0.20,
    this.deposit = 0,
    this.notes,
  });

  final String id;
  final String number; // vide tant que non émise
  final String clientId;
  final String clientName;
  final String? quoteId;
  final String? repairId;
  final InvoiceStatus status;
  final DateTime date;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final List<LineItem> lines;
  final List<Payment> payments;
  final double discount;
  final double taxRate;
  final double deposit;
  final String? notes;

  Totals get totals =>
      Totals.compute(lines, discount: discount, globalTaxRate: taxRate);

  /// Montant encaissé (acompte + paiements).
  double get amountPaid =>
      deposit + payments.fold<double>(0, (s, p) => s + p.amount);

  /// Reste à payer.
  double get balanceDue => (totals.total - amountPaid).clamp(0, double.infinity);

  bool get isIssued => number.isNotEmpty;

  /// Statut affiché : bascule en « en retard » si échéance dépassée et solde dû.
  InvoiceStatus effectiveStatus(DateTime now) {
    if (status == InvoiceStatus.issued || status == InvoiceStatus.partial) {
      if (dueDate != null && now.isAfter(dueDate!) && balanceDue > 0.005) {
        return InvoiceStatus.overdue;
      }
    }
    return status;
  }

  Invoice copyWith({
    String? number,
    String? clientId,
    String? clientName,
    InvoiceStatus? status,
    DateTime? issueDate,
    DateTime? dueDate,
    List<LineItem>? lines,
    List<Payment>? payments,
    double? discount,
    double? deposit,
    String? notes,
  }) {
    return Invoice(
      id: id,
      number: number ?? this.number,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      quoteId: quoteId,
      repairId: repairId,
      status: status ?? this.status,
      date: date,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      lines: lines ?? this.lines,
      payments: payments ?? this.payments,
      discount: discount ?? this.discount,
      taxRate: taxRate,
      deposit: deposit ?? this.deposit,
      notes: notes ?? this.notes,
    );
  }
}
