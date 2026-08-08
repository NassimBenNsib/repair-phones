import '../../../core/data/local_store.dart';
import '../../../core/domain/line_item.dart';
import '../domain/quote.dart';

/// (Dé)sérialisation d'un [Quote] pour le stockage local.
class QuoteMapper implements EntityMapper<Quote> {
  @override
  String get collection => 'quotes';

  @override
  String idOf(Quote q) => q.id;

  @override
  Map<String, Object?> toJson(Quote q) => {
        'id': q.id,
        'number': q.number,
        'clientId': q.clientId,
        'clientName': q.clientName,
        'repairId': q.repairId,
        'status': q.status.name,
        'date': q.date.toIso8601String(),
        'validUntil': q.validUntil?.toIso8601String(),
        'discount': q.discount,
        'taxRate': q.taxRate,
        'notes': q.notes,
        'lines': [for (final l in q.lines) l.toJson()],
      };

  @override
  Quote fromJson(Map<String, Object?> j) => Quote(
        id: j['id'] as String,
        number: j['number'] as String? ?? '',
        clientId: j['clientId'] as String? ?? '',
        clientName: j['clientName'] as String? ?? '',
        repairId: j['repairId'] as String?,
        status: QuoteStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => QuoteStatus.draft,
        ),
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime(2024),
        validUntil: j['validUntil'] == null
            ? null
            : DateTime.tryParse(j['validUntil'] as String),
        discount: (j['discount'] as num?)?.toDouble() ?? 0,
        taxRate: (j['taxRate'] as num?)?.toDouble() ?? 0.20,
        notes: j['notes'] as String?,
        lines: [
          for (final l in (j['lines'] as List? ?? const []))
            LineItem.fromJson(Map<String, Object?>.from(l as Map)),
        ],
      );
}
