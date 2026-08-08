import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/totals.dart';
import '../../../l10n/app_localizations.dart';
import '../../invoices/domain/invoice.dart' show Payment;

/// Statut d'une commande fournisseur.
enum PoStatus { draft, ordered, received, cancelled }

extension PoStatusX on PoStatus {
  String label(AppLocalizations l) => switch (this) {
        PoStatus.draft => l.orderStatusDraft,
        PoStatus.ordered => l.orderStatusOrdered,
        PoStatus.received => l.orderStatusReceived,
        PoStatus.cancelled => l.orderStatusCancelled,
      };

  Color color(AppleColors c) => switch (this) {
        PoStatus.draft => c.secondaryLabel,
        PoStatus.ordered => c.blue,
        PoStatus.received => c.green,
        PoStatus.cancelled => c.red,
      };
}

/// Commande fournisseur (bon d'achat).
@immutable
class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.number,
    required this.supplierId,
    this.status = PoStatus.draft,
    required this.date,
    this.expectedDate,
    this.receivedAt,
    this.lines = const [],
    this.taxRate = 0.20,
    this.notes,
    this.payments = const [],
  });

  final String id;
  final String number;
  final String supplierId;
  final PoStatus status;
  final DateTime date;
  final DateTime? expectedDate;
  final DateTime? receivedAt;
  final List<LineItem> lines;
  final double taxRate;
  final String? notes;

  /// Règlements fournisseur (comptabilité fournisseur / AP).
  final List<Payment> payments;

  Totals get totals => Totals.compute(lines, globalTaxRate: taxRate);

  double get amountPaid => payments.fold<double>(0, (s, p) => s + p.amount);

  /// Reste dû au fournisseur (jamais négatif).
  double get balanceDue =>
      (totals.total - amountPaid).clamp(0, double.infinity);

  bool get isPaid => balanceDue <= 0.005;

  PurchaseOrder copyWith({
    String? supplierId,
    PoStatus? status,
    DateTime? expectedDate,
    DateTime? receivedAt,
    List<LineItem>? lines,
    String? notes,
    List<Payment>? payments,
  }) {
    return PurchaseOrder(
      id: id,
      number: number,
      supplierId: supplierId ?? this.supplierId,
      status: status ?? this.status,
      date: date,
      expectedDate: expectedDate ?? this.expectedDate,
      receivedAt: receivedAt ?? this.receivedAt,
      lines: lines ?? this.lines,
      taxRate: taxRate,
      notes: notes ?? this.notes,
      payments: payments ?? this.payments,
    );
  }
}
