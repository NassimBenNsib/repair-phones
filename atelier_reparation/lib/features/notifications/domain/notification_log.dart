import 'package:flutter/foundation.dart';

import 'message_template.dart';

/// Entrée du journal de communication : trace d'un message envoyé (assisté) à
/// un client, rattaché éventuellement à une réparation.
@immutable
class NotificationLogEntry {
  const NotificationLogEntry({
    required this.id,
    required this.at,
    required this.channel,
    required this.to,
    required this.body,
    this.repairRef,
    this.clientId,
    this.templateId,
  });

  final String id;
  final DateTime at;
  final MessageChannel channel;

  /// Destinataire (numéro / e-mail) tel qu'utilisé.
  final String to;
  final String body;
  final String? repairRef;
  final String? clientId;
  final String? templateId;
}
