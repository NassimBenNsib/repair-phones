import '../../../core/data/local_store.dart';
import '../domain/message_template.dart';

/// (Dé)sérialisation d'un [MessageTemplate].
class MessageTemplateMapper implements EntityMapper<MessageTemplate> {
  @override
  String get collection => 'message_templates';

  @override
  String idOf(MessageTemplate t) => t.id;

  @override
  Map<String, Object?> toJson(MessageTemplate t) => {
        'id': t.id,
        'name': t.name,
        'channel': t.channel.name,
        'body': t.body,
        'subject': t.subject,
        'active': t.active,
        'order': t.order,
      };

  @override
  MessageTemplate fromJson(Map<String, Object?> j) => MessageTemplate(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        channel: MessageChannel.values.firstWhere(
            (c) => c.name == j['channel'],
            orElse: () => MessageChannel.sms),
        body: j['body'] as String? ?? '',
        subject: j['subject'] as String?,
        active: j['active'] as bool? ?? true,
        order: (j['order'] as num?)?.toInt() ?? 0,
      );
}
