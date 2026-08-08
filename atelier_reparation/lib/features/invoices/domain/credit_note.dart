import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/totals.dart';
import '../../../l10n/app_localizations.dart';

/// Statut d'un avoir (note de crédit).
enum CreditNoteStatus { draft, issued }

extension CreditNoteStatusX on CreditNoteStatus {
  String label(AppLocalizations l) => switch (this) {
        CreditNoteStatus.draft => l.invoiceStatusDraft,
        CreditNoteStatus.issued => l.invoiceStatusIssued,
      };

  Color color(AppleColors c) => switch (this) {
        CreditNoteStatus.draft => c.secondaryLabel,
        CreditNoteStatus.issued => c.purple,
      };
}

/// Avoir / note de crédit : document légal numéroté qui **crédite** un client
/// (correction, retour, remise a posteriori), rattaché ou non à une facture.
@immutable
class CreditNote {
  const CreditNote({
    required this.id,
    this.number = '',
    required this.clientId,
    required this.clientName,
    this.invoiceId,
    this.status = CreditNoteStatus.draft,
    required this.date,
    this.issueDate,
    this.lines = const [],
    this.taxRate = 0.20,
    this.reason,
  });

  final String id;
  final String number; // vide tant que non émis
  final String clientId;
  final String clientName;
  final String? invoiceId;
  final CreditNoteStatus status;
  final DateTime date;
  final DateTime? issueDate;
  final List<LineItem> lines;
  final double taxRate;
  final String? reason;

  Totals get totals => Totals.compute(lines, globalTaxRate: taxRate);
  bool get isIssued => number.isNotEmpty;

  CreditNote copyWith({
    String? number,
    CreditNoteStatus? status,
    DateTime? issueDate,
    List<LineItem>? lines,
    double? taxRate,
    String? reason,
  }) =>
      CreditNote(
        id: id,
        number: number ?? this.number,
        clientId: clientId,
        clientName: clientName,
        invoiceId: invoiceId,
        status: status ?? this.status,
        date: date,
        issueDate: issueDate ?? this.issueDate,
        lines: lines ?? this.lines,
        taxRate: taxRate ?? this.taxRate,
        reason: reason ?? this.reason,
      );
}
