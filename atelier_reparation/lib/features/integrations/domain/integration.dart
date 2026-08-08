import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Catégorie d'intégration (pour regrouper le catalogue).
enum IntegrationCategory { payments, messaging, cloud, automation }

extension IntegrationCategoryX on IntegrationCategory {
  String label(AppLocalizations l) => switch (this) {
        IntegrationCategory.payments => l.integrationCatPayments,
        IntegrationCategory.messaging => l.integrationCatMessaging,
        IntegrationCategory.cloud => l.integrationCatCloud,
        IntegrationCategory.automation => l.integrationCatAutomation,
      };
}

/// Un champ de configuration d'une intégration.
class IntegrationField {
  const IntegrationField(this.key, this.label,
      {this.secret = false, this.optional = false, this.hint});

  final String key;
  final String Function(AppLocalizations l) label;

  /// Champ sensible (masqué ; à déplacer vers le stockage sécurisé en prod).
  final bool secret;
  final bool optional;
  final String? hint;
}

/// Fournisseurs tiers pris en charge par le catalogue d'intégrations.
enum IntegrationKind {
  flouci,
  konnect,
  clictopay,
  stripe,
  googleDrive,
  gmail,
  outlook,
  onedrive,
  whatsapp,
  messenger,
  sms,
  telegram,
  teams,
  slack,
  zapier,
  applePay,
  icloud,
  appleMessages,
}

extension IntegrationKindX on IntegrationKind {
  /// Nom de marque (non traduit).
  String get brand => switch (this) {
        IntegrationKind.flouci => 'Flouci',
        IntegrationKind.konnect => 'Konnect',
        IntegrationKind.clictopay => 'ClicToPay',
        IntegrationKind.stripe => 'Stripe',
        IntegrationKind.googleDrive => 'Google Drive',
        IntegrationKind.gmail => 'Gmail',
        IntegrationKind.outlook => 'Outlook',
        IntegrationKind.onedrive => 'OneDrive',
        IntegrationKind.whatsapp => 'WhatsApp Business',
        IntegrationKind.messenger => 'Messenger',
        IntegrationKind.sms => 'SMS',
        IntegrationKind.telegram => 'Telegram',
        IntegrationKind.teams => 'Microsoft Teams',
        IntegrationKind.slack => 'Slack',
        IntegrationKind.zapier => 'Zapier',
        IntegrationKind.applePay => 'Apple Pay',
        IntegrationKind.icloud => 'iCloud',
        IntegrationKind.appleMessages => 'Apple Messages',
      };

  IntegrationCategory get category => switch (this) {
        IntegrationKind.flouci ||
        IntegrationKind.konnect ||
        IntegrationKind.clictopay ||
        IntegrationKind.stripe ||
        IntegrationKind.applePay =>
          IntegrationCategory.payments,
        IntegrationKind.googleDrive ||
        IntegrationKind.gmail ||
        IntegrationKind.outlook ||
        IntegrationKind.onedrive ||
        IntegrationKind.icloud =>
          IntegrationCategory.cloud,
        IntegrationKind.whatsapp ||
        IntegrationKind.messenger ||
        IntegrationKind.sms ||
        IntegrationKind.telegram ||
        IntegrationKind.appleMessages =>
          IntegrationCategory.messaging,
        IntegrationKind.teams ||
        IntegrationKind.slack ||
        IntegrationKind.zapier =>
          IntegrationCategory.automation,
      };

  IconData get icon => switch (this) {
        IntegrationKind.flouci => Icons.account_balance_wallet_outlined,
        IntegrationKind.konnect => Icons.credit_card,
        IntegrationKind.clictopay => Icons.point_of_sale_outlined,
        IntegrationKind.stripe => Icons.payments_outlined,
        IntegrationKind.googleDrive => Icons.cloud_upload_outlined,
        IntegrationKind.gmail => Icons.mail_outline,
        IntegrationKind.outlook => Icons.alternate_email,
        IntegrationKind.onedrive => Icons.cloud_outlined,
        IntegrationKind.whatsapp => Icons.chat_outlined,
        IntegrationKind.messenger => Icons.forum_outlined,
        IntegrationKind.sms => Icons.sms_outlined,
        IntegrationKind.telegram => Icons.send_outlined,
        IntegrationKind.teams => Icons.groups_outlined,
        IntegrationKind.slack => Icons.tag,
        IntegrationKind.zapier => Icons.bolt_outlined,
        IntegrationKind.applePay => Icons.apple,
        IntegrationKind.icloud => Icons.cloud,
        IntegrationKind.appleMessages => Icons.chat_bubble_outline,
      };

  /// Couleur de marque de la pastille.
  Color get color => switch (this) {
        IntegrationKind.flouci => const Color(0xFF17A2B8),
        IntegrationKind.konnect => const Color(0xFF2F6FED),
        IntegrationKind.clictopay => const Color(0xFF5B4FE0),
        IntegrationKind.stripe => const Color(0xFF635BFF),
        IntegrationKind.googleDrive => const Color(0xFF2AA85F),
        IntegrationKind.gmail => const Color(0xFFEA4335),
        IntegrationKind.outlook => const Color(0xFF0F6CBD),
        IntegrationKind.onedrive => const Color(0xFF0364B8),
        IntegrationKind.whatsapp => const Color(0xFF25D366),
        IntegrationKind.messenger => const Color(0xFF0084FF),
        IntegrationKind.sms => const Color(0xFFF59E0B),
        IntegrationKind.telegram => const Color(0xFF229ED9),
        IntegrationKind.teams => const Color(0xFF6264A7),
        IntegrationKind.slack => const Color(0xFF611F69),
        IntegrationKind.zapier => const Color(0xFFFF4A00),
        IntegrationKind.applePay => const Color(0xFF6E6E73),
        IntegrationKind.icloud => const Color(0xFF3693F3),
        IntegrationKind.appleMessages => const Color(0xFF007AFF),
      };

  /// Intégration via OAuth (connexion de compte) plutôt que des champs.
  bool get oauth =>
      this == IntegrationKind.googleDrive ||
      this == IntegrationKind.onedrive ||
      this == IntegrationKind.icloud;

  /// Page du fournisseur ouverte lors de la liaison d'un compte OAuth.
  String? get accountUrl => switch (this) {
        IntegrationKind.googleDrive => 'https://drive.google.com',
        IntegrationKind.onedrive => 'https://onedrive.live.com',
        IntegrationKind.icloud => 'https://www.icloud.com',
        _ => null,
      };

  String description(AppLocalizations l) => switch (this) {
        IntegrationKind.flouci => l.integrationDescFlouci,
        IntegrationKind.konnect => l.integrationDescKonnect,
        IntegrationKind.clictopay => l.integrationDescClictopay,
        IntegrationKind.stripe => l.integrationDescStripe,
        IntegrationKind.googleDrive => l.integrationDescDrive,
        IntegrationKind.gmail => l.integrationDescGmail,
        IntegrationKind.outlook => l.integrationDescOutlook,
        IntegrationKind.onedrive => l.integrationDescOnedrive,
        IntegrationKind.whatsapp => l.integrationDescWhatsapp,
        IntegrationKind.messenger => l.integrationDescMessenger,
        IntegrationKind.sms => l.integrationDescSms,
        IntegrationKind.telegram => l.integrationDescTelegram,
        IntegrationKind.teams => l.integrationDescTeams,
        IntegrationKind.slack => l.integrationDescSlack,
        IntegrationKind.zapier => l.integrationDescZapier,
        IntegrationKind.applePay => l.integrationDescApplepay,
        IntegrationKind.icloud => l.integrationDescIcloud,
        IntegrationKind.appleMessages => l.integrationDescApplemsg,
      };

  List<IntegrationField> get fields => switch (this) {
        IntegrationKind.flouci => [
            IntegrationField('appId', (l) => l.integrationFieldAppId),
            IntegrationField('privateToken', (l) => l.integrationFieldPrivateToken,
                secret: true),
          ],
        IntegrationKind.konnect => [
            IntegrationField('apiKey', (l) => l.integrationFieldApiKey,
                secret: true),
            IntegrationField('walletId', (l) => l.integrationFieldWalletId),
          ],
        IntegrationKind.clictopay => [
            IntegrationField('merchantUser', (l) => l.integrationFieldMerchantUser),
            IntegrationField(
                'merchantPassword', (l) => l.integrationFieldMerchantPassword,
                secret: true),
          ],
        IntegrationKind.stripe => [
            IntegrationField('secretKey', (l) => l.integrationFieldSecretKey,
                secret: true),
          ],
        IntegrationKind.googleDrive => const [],
        IntegrationKind.onedrive => const [],
        IntegrationKind.gmail || IntegrationKind.outlook => [
            IntegrationField('email', (l) => l.fieldEmail),
            IntegrationField('appPassword', (l) => l.integrationFieldAppPassword,
                secret: true),
          ],
        IntegrationKind.whatsapp => [
            IntegrationField('phoneId', (l) => l.integrationFieldPhoneId),
            IntegrationField('accessToken', (l) => l.integrationFieldAccessToken,
                secret: true),
          ],
        IntegrationKind.messenger => [
            IntegrationField('pageLink', (l) => l.integrationFieldPageLink),
          ],
        IntegrationKind.sms => [
            IntegrationField('sender', (l) => l.integrationFieldSender),
            IntegrationField('apiKey', (l) => l.integrationFieldApiKey,
                secret: true),
          ],
        IntegrationKind.telegram => [
            IntegrationField('botToken', (l) => l.integrationFieldBotToken,
                secret: true),
            IntegrationField('chatId', (l) => l.integrationFieldChatId),
          ],
        IntegrationKind.teams ||
        IntegrationKind.slack ||
        IntegrationKind.zapier =>
          [
            IntegrationField('webhookUrl', (l) => l.integrationFieldWebhookUrl,
                secret: true),
          ],
        IntegrationKind.applePay => [
            IntegrationField('merchantId', (l) => l.integrationFieldMerchantId),
          ],
        IntegrationKind.icloud => const [],
        IntegrationKind.appleMessages => [
            IntegrationField('businessId', (l) => l.integrationFieldBusinessId),
          ],
      };
}

/// État configurable d'une intégration (persisté). Les valeurs secrètes ne
/// devront PAS transiter par les sauvegardes ni les journaux en production.
@immutable
class Integration {
  const Integration({
    required this.kind,
    this.enabled = false,
    this.config = const {},
  });

  final IntegrationKind kind;
  final bool enabled;
  final Map<String, String> config;

  String get id => kind.name;

  /// Tous les champs requis (non optionnels) sont renseignés.
  bool get isConfigured => kind.oauth
      ? config['connected'] == 'true'
      : kind.fields
          .where((f) => !f.optional)
          .every((f) => (config[f.key] ?? '').trim().isNotEmpty);

  Integration copyWith({bool? enabled, Map<String, String>? config}) =>
      Integration(
        kind: kind,
        enabled: enabled ?? this.enabled,
        config: config ?? this.config,
      );
}

/// Statut affiché d'une intégration.
enum IntegrationStatus { active, disabled, notConfigured }

extension IntegrationStatusX on Integration {
  IntegrationStatus get status {
    if (!isConfigured) return IntegrationStatus.notConfigured;
    return enabled ? IntegrationStatus.active : IntegrationStatus.disabled;
  }
}

/// Nature d'un problème détecté lors de la validation d'une intégration.
enum IntegrationIssue {
  none,
  notConnected,
  missingField,
  invalidUrl,
  invalidEmail,
  tooShort,
}

/// Résultat de validation locale d'une intégration (pur, sans réseau).
@immutable
class IntegrationValidation {
  const IntegrationValidation(this.issue, [this.fieldKey]);

  final IntegrationIssue issue;

  /// Clé du champ concerné (pour un message localisé), le cas échéant.
  final String? fieldKey;

  bool get ok => issue == IntegrationIssue.none;

  static const IntegrationValidation valid =
      IntegrationValidation(IntegrationIssue.none);
}

final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool _isUrlField(String key) =>
    key.toLowerCase().endsWith('url') || key == 'pageLink';

bool _isEmailField(String key) => key.toLowerCase().contains('email');

/// Valide la configuration d'une intégration **localement** (champs requis,
/// format des URL/e-mails, longueur minimale des secrets). Ne teste PAS un
/// aller-retour réseau — c'est un contrôle de cohérence avant activation.
IntegrationValidation validateIntegration(Integration i) {
  if (i.kind.oauth) {
    return i.config['connected'] == 'true'
        ? IntegrationValidation.valid
        : const IntegrationValidation(IntegrationIssue.notConnected);
  }
  for (final f in i.kind.fields) {
    final value = (i.config[f.key] ?? '').trim();
    if (value.isEmpty) {
      if (f.optional) continue;
      return IntegrationValidation(IntegrationIssue.missingField, f.key);
    }
    if (_isUrlField(f.key)) {
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.isAbsolute || !uri.scheme.startsWith('http')) {
        return IntegrationValidation(IntegrationIssue.invalidUrl, f.key);
      }
    } else if (_isEmailField(f.key)) {
      if (!_emailRe.hasMatch(value)) {
        return IntegrationValidation(IntegrationIssue.invalidEmail, f.key);
      }
    } else if (f.secret && value.length < 8) {
      return IntegrationValidation(IntegrationIssue.tooShort, f.key);
    }
  }
  return IntegrationValidation.valid;
}
