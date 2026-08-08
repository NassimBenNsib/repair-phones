import '../../../core/data/local_store.dart';
import '../domain/account_event.dart';

/// (Dé)sérialisation d'un [AccountEvent] pour le stockage local.
class AccountEventMapper implements EntityMapper<AccountEvent> {
  @override
  String get collection => 'account_events';

  @override
  String idOf(AccountEvent e) => e.id;

  @override
  Map<String, Object?> toJson(AccountEvent e) => {
        'id': e.id,
        'at': e.at.toIso8601String(),
        'kind': e.kind.name,
        'actorId': e.actorId,
        'actorEmail': e.actorEmail,
        'targetId': e.targetId,
        'targetEmail': e.targetEmail,
        'detail': e.detail,
      };

  @override
  AccountEvent fromJson(Map<String, Object?> j) => AccountEvent(
        id: j['id'] as String,
        at: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime(2000),
        kind: AccountEventKind.values.firstWhere(
          (k) => k.name == j['kind'],
          orElse: () => AccountEventKind.updated,
        ),
        actorId: j['actorId'] as String?,
        actorEmail: j['actorEmail'] as String? ?? '',
        targetId: j['targetId'] as String?,
        targetEmail: j['targetEmail'] as String?,
        detail: j['detail'] as String?,
      );
}
