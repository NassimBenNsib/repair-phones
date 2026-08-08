import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/totals.dart';
import '../../../l10n/app_localizations.dart';

/// Statut d'un devis.
enum QuoteStatus { draft, sent, accepted, refused, expired }

extension QuoteStatusX on QuoteStatus {
  String label(AppLocalizations l) => switch (this) {
        QuoteStatus.draft => l.quoteStatusDraft,
        QuoteStatus.sent => l.quoteStatusSent,
        QuoteStatus.accepted => l.quoteStatusAccepted,
        QuoteStatus.refused => l.quoteStatusRefused,
        QuoteStatus.expired => l.quoteStatusExpired,
      };

  Color color(AppleColors c) => switch (this) {
        QuoteStatus.draft => c.secondaryLabel,
        QuoteStatus.sent => c.blue,
        QuoteStatus.accepted => c.green,
        QuoteStatus.refused => c.red,
        QuoteStatus.expired => c.orange,
      };
}

/// Devis client.
@immutable
class Quote {
  const Quote({
    required this.id,
    required this.number,
    required this.clientId,
    required this.clientName,
    this.repairId,
    this.status = QuoteStatus.draft,
    required this.date,
    this.validUntil,
    this.lines = const [],
    this.discount = 0,
    this.taxRate = 0.20,
    this.notes,
  });

  final String id;
  final String number;
  final String clientId;
  final String clientName; // libellé caché (affichage sans jointure)
  final String? repairId;
  final QuoteStatus status;
  final DateTime date;
  final DateTime? validUntil;
  final List<LineItem> lines;
  final double discount;
  final double taxRate;
  final String? notes;

  Totals get totals =>
      Totals.compute(lines, discount: discount, globalTaxRate: taxRate);

  Quote copyWith({
    String? clientId,
    String? clientName,
    QuoteStatus? status,
    DateTime? validUntil,
    List<LineItem>? lines,
    double? discount,
    String? notes,
  }) {
    return Quote(
      id: id,
      number: number,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      repairId: repairId,
      status: status ?? this.status,
      date: date,
      validUntil: validUntil ?? this.validUntil,
      lines: lines ?? this.lines,
      discount: discount ?? this.discount,
      taxRate: taxRate,
      notes: notes ?? this.notes,
    );
  }
}
