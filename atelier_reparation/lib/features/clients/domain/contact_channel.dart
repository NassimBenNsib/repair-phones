import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';

// Couleurs de marque.
const kWhatsappColor = Color(0xFF25D366);
const kTelegramColor = Color(0xFF229ED9);
const kInstagramColor = Color(0xFFE1306C);
const kFacebookColor = Color(0xFF1877F2);
const kLinkedinColor = Color(0xFF0A66C2);
const kSnapchatColor = Color(0xFFF5B900);
const kSignalColor = Color(0xFF3A76F0);
const kWechatColor = Color(0xFF07C160);
const kMessengerColor = Color(0xFF0084FF);
const kViberColor = Color(0xFF7360F2);
const kLineColor = Color(0xFF06C755);
const kYoutubeColor = Color(0xFFFF0000);
const kTeamsColor = Color(0xFF6264A7);

/// Type d'un canal de contact choisi par l'utilisateur.
enum ContactKind {
  mobile,
  landline,
  whatsapp,
  telegram,
  email,
  website,
  instagram,
  facebook,
  linkedin,
  x,
  snapchat,
  tiktok,
  signal,
  wechat,
  messenger,
  viber,
  line,
  fax,
  youtube,
  teams,
  other,
}

extension ContactKindX on ContactKind {
  String label(AppLocalizations l) => switch (this) {
        ContactKind.mobile => l.contactKindMobile,
        ContactKind.landline => l.contactKindLandline,
        ContactKind.whatsapp => l.contactKindWhatsapp,
        ContactKind.telegram => l.contactKindTelegram,
        ContactKind.email => l.contactKindEmail,
        ContactKind.website => l.contactKindWebsite,
        ContactKind.instagram => l.contactKindInstagram,
        ContactKind.facebook => l.contactKindFacebook,
        ContactKind.linkedin => l.contactKindLinkedin,
        ContactKind.x => l.contactKindX,
        ContactKind.snapchat => l.contactKindSnapchat,
        ContactKind.tiktok => l.contactKindTiktok,
        ContactKind.signal => l.contactKindSignal,
        ContactKind.wechat => l.contactKindWechat,
        ContactKind.messenger => l.contactKindMessenger,
        ContactKind.viber => l.contactKindViber,
        ContactKind.line => l.contactKindLine,
        ContactKind.fax => l.contactKindFax,
        ContactKind.youtube => l.contactKindYoutube,
        ContactKind.teams => l.contactKindTeams,
        ContactKind.other => l.contactKindOther,
      };

  IconData get icon => switch (this) {
        ContactKind.mobile => Icons.smartphone,
        ContactKind.landline => Icons.phone_outlined,
        ContactKind.whatsapp => Icons.chat,
        ContactKind.telegram => Icons.send,
        ContactKind.email => Icons.mail_outline,
        ContactKind.website => Icons.language,
        ContactKind.instagram => Icons.camera_alt_outlined,
        ContactKind.facebook => Icons.facebook,
        ContactKind.linkedin => Icons.business_center_outlined,
        ContactKind.x => Icons.alternate_email,
        ContactKind.snapchat => Icons.camera_outlined,
        ContactKind.tiktok => Icons.music_note,
        ContactKind.signal => Icons.shield_outlined,
        ContactKind.wechat => Icons.forum_outlined,
        ContactKind.messenger => Icons.messenger_outline,
        ContactKind.viber => Icons.phone_in_talk,
        ContactKind.line => Icons.chat,
        ContactKind.fax => Icons.print_outlined,
        ContactKind.youtube => Icons.play_circle_outline,
        ContactKind.teams => Icons.groups_outlined,
        ContactKind.other => Icons.link,
      };

  Color color(AppleColors c) => switch (this) {
        ContactKind.mobile || ContactKind.landline => c.green,
        ContactKind.whatsapp => kWhatsappColor,
        ContactKind.telegram => kTelegramColor,
        ContactKind.email => c.blue,
        ContactKind.website => c.blue,
        ContactKind.instagram => kInstagramColor,
        ContactKind.facebook => kFacebookColor,
        ContactKind.linkedin => kLinkedinColor,
        ContactKind.x => c.label,
        ContactKind.snapchat => kSnapchatColor,
        ContactKind.tiktok => c.label,
        ContactKind.signal => kSignalColor,
        ContactKind.wechat => kWechatColor,
        ContactKind.messenger => kMessengerColor,
        ContactKind.viber => kViberColor,
        ContactKind.line => kLineColor,
        ContactKind.fax => c.secondaryLabel,
        ContactKind.youtube => kYoutubeColor,
        ContactKind.teams => kTeamsColor,
        ContactKind.other => c.secondaryLabel,
      };

  /// Vrai pour les canaux téléphoniques (appel + SMS).
  bool get isPhone => this == ContactKind.mobile || this == ContactKind.landline;

  /// Clavier adapté à la saisie.
  TextInputType get keyboardType => switch (this) {
        ContactKind.mobile ||
        ContactKind.landline ||
        ContactKind.whatsapp ||
        ContactKind.signal ||
        ContactKind.viber ||
        ContactKind.fax =>
          TextInputType.phone,
        ContactKind.email || ContactKind.teams => TextInputType.emailAddress,
        ContactKind.website => TextInputType.url,
        _ => TextInputType.text,
      };
}

/// Un canal de contact : un type + une valeur (numéro, pseudo, URL…).
@immutable
class ContactChannel {
  const ContactChannel({required this.kind, required this.value});

  final ContactKind kind;
  final String value;

  ContactChannel copyWith({ContactKind? kind, String? value}) =>
      ContactChannel(kind: kind ?? this.kind, value: value ?? this.value);

  Map<String, Object?> toJson() => {'kind': kind.name, 'value': value};

  factory ContactChannel.fromJson(Map<String, Object?> j) => ContactChannel(
        kind: ContactKind.values.firstWhere(
          (k) => k.name == j['kind'],
          orElse: () => ContactKind.other,
        ),
        value: j['value'] as String? ?? '',
      );
}
