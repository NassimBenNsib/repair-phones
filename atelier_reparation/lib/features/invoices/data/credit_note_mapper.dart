import '../../../core/data/local_store.dart';
import '../../../core/domain/line_item.dart';
import '../domain/credit_note.dart';

/// (Dé)sérialisation d'un [CreditNote].
class CreditNoteMapper implements EntityMapper<CreditNote> {
  @override
  String get collection => 'credit_notes';

  @override
  String idOf(CreditNote c) => c.id;

  @override
  Map<String, Object?> toJson(CreditNote c) => {
        'id': c.id,
        'number': c.number,
        'clientId': c.clientId,
        'clientName': c.clientName,
        'invoiceId': c.invoiceId,
        'status': c.status.name,
        'date': c.date.toIso8601String(),
        'issueDate': c.issueDate?.toIso8601String(),
        'lines': [for (final l in c.lines) l.toJson()],
        'taxRate': c.taxRate,
        'reason': c.reason,
      };

  @override
  CreditNote fromJson(Map<String, Object?> j) => CreditNote(
        id: j['id'] as String,
        number: j['number'] as String? ?? '',
        clientId: j['clientId'] as String? ?? '',
        clientName: j['clientName'] as String? ?? '',
        invoiceId: j['invoiceId'] as String?,
        status: CreditNoteStatus.values.firstWhere(
            (s) => s.name == j['status'],
            orElse: () => CreditNoteStatus.draft),
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        issueDate: j['issueDate'] == null
            ? null
            : DateTime.tryParse(j['issueDate'] as String),
        lines: [
          for (final l in (j['lines'] as List? ?? const []))
            LineItem.fromJson(Map<String, Object?>.from(l as Map)),
        ],
        taxRate: (j['taxRate'] as num?)?.toDouble() ?? 0.20,
        reason: j['reason'] as String?,
      );
}
