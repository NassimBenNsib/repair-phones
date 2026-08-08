import 'package:flutter/foundation.dart';

/// Canal d'envoi d'un message client.
enum MessageChannel { sms, whatsapp, email }

/// Modèle de message réutilisable. Le corps peut contenir des variables entre
/// accolades : `{client} {device} {ref} {total} {balance} {status} {shop}`…
@immutable
class MessageTemplate {
  const MessageTemplate({
    required this.id,
    required this.name,
    required this.channel,
    required this.body,
    this.subject,
    this.active = true,
    this.order = 0,
  });

  final String id;
  final String name;
  final MessageChannel channel;
  final String body;

  /// Objet (e-mail uniquement).
  final String? subject;
  final bool active;
  final int order;

  MessageTemplate copyWith({
    String? name,
    MessageChannel? channel,
    String? body,
    String? subject,
    bool clearSubject = false,
    bool? active,
    int? order,
  }) =>
      MessageTemplate(
        id: id,
        name: name ?? this.name,
        channel: channel ?? this.channel,
        body: body ?? this.body,
        subject: clearSubject ? null : (subject ?? this.subject),
        active: active ?? this.active,
        order: order ?? this.order,
      );
}

/// Remplace les variables `{cle}` par leur valeur ; laisse littéral si inconnue.
final RegExp _placeholder = RegExp(r'\{(\w+)\}');
String renderTemplate(String body, Map<String, String> vars) =>
    body.replaceAllMapped(_placeholder, (m) {
      final key = m.group(1)!;
      return vars.containsKey(key) ? vars[key]! : m.group(0)!;
    });

/// Modèles de démonstration, alignés sur les étapes du cycle de vie.
const List<MessageTemplate> seedMessageTemplates = [
  MessageTemplate(
    id: 'tpl-ready',
    name: 'Réparation prête',
    channel: MessageChannel.sms,
    body:
        'Bonjour {client}, votre {device} ({ref}) est prêt à être récupéré. Solde à régler : {balance}. — {shop}',
    order: 0,
  ),
  MessageTemplate(
    id: 'tpl-quote',
    name: 'Devis à approuver',
    channel: MessageChannel.sms,
    body:
        'Bonjour {client}, un devis pour votre {device} ({ref}) est disponible : {total}. Merci de nous confirmer votre accord. — {shop}',
    order: 1,
  ),
  MessageTemplate(
    id: 'tpl-parts',
    name: 'En attente de pièces',
    channel: MessageChannel.sms,
    body:
        'Bonjour {client}, la réparation de votre {device} ({ref}) est en attente de pièces. Nous vous tiendrons informé. — {shop}',
    order: 2,
  ),
  MessageTemplate(
    id: 'tpl-received',
    name: 'Prise en charge',
    channel: MessageChannel.sms,
    body:
        'Bonjour {client}, nous avons bien reçu votre {device}. Référence de suivi : {ref}. — {shop}',
    order: 3,
  ),
];
