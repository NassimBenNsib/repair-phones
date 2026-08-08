import '../../../core/data/local_store.dart';
import '../domain/cash_session.dart';

/// (Dé)sérialisation d'une [CashSession].
class CashSessionMapper implements EntityMapper<CashSession> {
  @override
  String get collection => 'cash_sessions';

  @override
  String idOf(CashSession s) => s.id;

  @override
  Map<String, Object?> toJson(CashSession s) => {
        'id': s.id,
        'openedAt': s.openedAt.toIso8601String(),
        'openingFloat': s.openingFloat,
        'closedAt': s.closedAt?.toIso8601String(),
        'countedCash': s.countedCash,
        'openedBy': s.openedBy,
        'closedBy': s.closedBy,
        'note': s.note,
      };

  @override
  CashSession fromJson(Map<String, Object?> j) => CashSession(
        id: j['id'] as String,
        openedAt:
            DateTime.tryParse(j['openedAt'] as String? ?? '') ?? DateTime.now(),
        openingFloat: (j['openingFloat'] as num?)?.toDouble() ?? 0,
        closedAt: j['closedAt'] == null
            ? null
            : DateTime.tryParse(j['closedAt'] as String),
        countedCash: (j['countedCash'] as num?)?.toDouble(),
        openedBy: j['openedBy'] as String?,
        closedBy: j['closedBy'] as String?,
        note: j['note'] as String?,
      );
}
