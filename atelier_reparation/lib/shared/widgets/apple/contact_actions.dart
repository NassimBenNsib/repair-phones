import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Chiffres uniquement (pour les liens tel/WhatsApp/Telegram).
String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

/// `https://wa.me/<chiffres>` à partir d'un numéro.
Uri whatsappUri(String number) => Uri.parse('https://wa.me/${_digits(number)}');

/// Lien Telegram : `@pseudo`/`pseudo` → `t.me/<pseudo>` ; numéro → `t.me/+<chiffres>`.
Uri telegramUri(String handleOrPhone) {
  final h = handleOrPhone.trim().replaceFirst('@', '');
  final digits = _digits(h);
  if (digits.isNotEmpty && digits.length == h.length) {
    return Uri.parse('https://t.me/+$digits');
  }
  return Uri.parse('https://t.me/$h');
}

/// Recherche Google Maps pour une adresse libre.
Uri mapsUri(String address) => Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}');

/// Normalise une URL de site web (ajoute `https://` si le schéma manque).
Uri websiteUri(String url) {
  final u = url.trim();
  return Uri.parse(u.startsWith(RegExp(r'https?://')) ? u : 'https://$u');
}

/// Profil Instagram à partir d'un `@pseudo` (ou d'une URL déjà complète).
Uri instagramUri(String handle) => _socialUri('instagram.com', handle);

/// Profil Facebook (`@pseudo`, pseudo ou URL complète).
Uri facebookUri(String handle) => _socialUri('facebook.com', handle);

/// Profil LinkedIn (`@pseudo`/pseudo → `/in/…`, ou URL complète).
Uri linkedinUri(String handle) => _socialUri('linkedin.com/in', handle);

/// Profil X (ex-Twitter) (`@pseudo`, pseudo ou URL complète).
Uri xUri(String handle) => _socialUri('x.com', handle);

/// Profil Snapchat (`@pseudo`, pseudo ou URL complète).
Uri snapchatUri(String handle) => _socialUri('snapchat.com/add', handle);

/// Profil TikTok — le `@` fait partie de l'URL (`tiktok.com/@pseudo`).
Uri tiktokUri(String handle) {
  final h = handle.trim();
  if (h.startsWith(RegExp(r'https?://'))) return Uri.parse(h);
  return Uri.parse('https://tiktok.com/@${h.replaceFirst('@', '')}');
}

/// Lien Signal (basé sur le numéro) : `signal.me/#p/+<chiffres>`.
Uri signalUri(String phone) {
  final p = phone.trim();
  if (p.startsWith(RegExp(r'https?://'))) return Uri.parse(p);
  return Uri.parse('https://signal.me/#p/+${_digits(p)}');
}

/// Facebook Messenger : `m.me/<pseudo>`.
Uri messengerUri(String handle) => _socialUri('m.me', handle);

/// Viber (basé sur le numéro) : `viber://chat?number=+<chiffres>`.
Uri viberUri(String phone) {
  final p = phone.trim();
  if (p.startsWith(RegExp(r'https?://'))) return Uri.parse(p);
  return Uri.parse('viber://chat?number=%2B${_digits(p)}');
}

/// LINE : `line.me/ti/p/~<id>` (ou URL complète).
Uri lineUri(String id) {
  final s = id.trim();
  if (s.startsWith(RegExp(r'https?://'))) return Uri.parse(s);
  return Uri.parse('https://line.me/ti/p/~${s.replaceFirst(RegExp(r'^[@~]'), '')}');
}

/// Chaîne YouTube : `youtube.com/@<pseudo>` (le `@` fait partie de l'URL).
Uri youtubeUri(String handle) {
  final h = handle.trim();
  if (h.startsWith(RegExp(r'https?://'))) return Uri.parse(h);
  return Uri.parse('https://youtube.com/@${h.replaceFirst('@', '')}');
}

/// Microsoft Teams : ouvre une conversation avec l'e-mail donné (ou URL).
Uri teamsUri(String value) {
  final v = value.trim();
  if (v.startsWith(RegExp(r'https?://'))) return Uri.parse(v);
  return Uri.parse(
      'https://teams.microsoft.com/l/chat/0/0?users=${Uri.encodeComponent(v)}');
}

/// Construit `https://<base>/<pseudo>` en tolérant `@` et les URL déjà complètes.
Uri _socialUri(String base, String handle) {
  final h = handle.trim();
  if (h.startsWith(RegExp(r'https?://'))) return Uri.parse(h);
  return Uri.parse('https://$base/${h.replaceFirst('@', '')}');
}

/// Lance une URI (tel:, sms:, mailto:, https://wa.me/…) avec repli discret.
Future<void> launchContact(BuildContext context, Uri uri) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(l.notProvided)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l.notProvided)));
  }
}

/// Rangée d'actions rapides de contact : Appeler · SMS · WhatsApp · E-mail.
///
/// Composant partagé (réparations & clients) : chaque bouton se désactive si la
/// coordonnée correspondante est absente.
class ContactActionsRow extends StatelessWidget {
  const ContactActionsRow({super.key, this.phone, this.email});

  final String? phone;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final digits = phone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickAction(
            icon: Icons.call,
            label: l.actionCall,
            enabled: phone != null,
            onTap: () => launchContact(context, Uri(scheme: 'tel', path: phone)),
          ),
          _QuickAction(
            icon: Icons.sms,
            label: l.actionSms,
            enabled: phone != null,
            onTap: () => launchContact(context, Uri(scheme: 'sms', path: phone)),
          ),
          _QuickAction(
            icon: Icons.chat,
            label: l.actionWhatsapp,
            enabled: phone != null,
            onTap: () =>
                launchContact(context, Uri.parse('https://wa.me/$digits')),
          ),
          _QuickAction(
            icon: Icons.mail_outline,
            label: l.actionEmail,
            enabled: email != null,
            onTap: () =>
                launchContact(context, Uri(scheme: 'mailto', path: email)),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final tint = enabled ? context.accentColor : colors.tertiaryLabel;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: ShapeDecoration(
              color: tint.withValues(alpha: 0.14),
              shape: AppleRadii.shape(AppleRadii.lg),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppleTypography.caption1.copyWith(color: tint)),
        ],
      ),
    );
  }
}
