import '../../../core/data/local_store.dart';
import '../domain/message_template.dart';
import '../domain/notification_log.dart';

/// (Dé)sérialisation d'une [NotificationLogEntry].
class NotificationLogMapper implements EntityMapper<NotificationLogEntry> {
  @override
  String get collection => 'notifications';

  @override
  String idOf(NotificationLogEntry e) => e.id;

  @override
  Map<String, Object?> toJson(NotificationLogEntry e) => {
        'id': e.id,
        'at': e.at.toIso8601String(),
        'channel': e.channel.name,
        'to': e.to,
        'body': e.body,
        'repairRef': e.repairRef,
        'clientId': e.clientId,
        'templateId': e.templateId,
      };

  @override
  NotificationLogEntry fromJson(Map<String, Object?> j) => NotificationLogEntry(
        id: j['id'] as String,
        at: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime.now(),
        channel: MessageChannel.values.firstWhere(
            (c) => c.name == j['channel'],
            orElse: () => MessageChannel.sms),
        to: j['to'] as String? ?? '',
        body: j['body'] as String? ?? '',
        repairRef: j['repairRef'] as String?,
        clientId: j['clientId'] as String?,
        templateId: j['templateId'] as String?,
      );
}
