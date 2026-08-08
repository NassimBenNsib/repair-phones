import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'apple_avatar.dart';
import 'apple_card.dart';
import 'contact_actions.dart';

// Couleurs de marque pour les canaux de contact.
const _whatsappColor = Color(0xFF25D366);
const _telegramColor = Color(0xFF229ED9);

/// Carte de coordonnées façon iOS avec **actions intégrées** : la ligne
/// téléphone porte directement les boutons Appeler · WhatsApp · Telegram ; les
/// lignes e-mail et adresse sont cliquables (mail / itinéraire).
///
/// Partagée entre le détail client et le détail réparation.
class ContactInfoCard extends StatelessWidget {
  const ContactInfoCard({
    super.key,
    this.name,
    this.phone,
    this.email,
    this.address,
  });

  final String? name;
  final String? phone;
  final String? email;
  final String? address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    final rows = <Widget>[
      if (name != null) _NameRow(name: name!),
      if (phone != null)
        _ContactRow(
          icon: Icons.call,
          tint: colors.green,
          label: l.fieldPhone,
          value: phone!,
          actions: [
            _MiniAction(
              icon: Icons.call,
              tint: colors.green,
              tooltip: l.actionCall,
              onTap: () =>
                  launchContact(context, Uri(scheme: 'tel', path: phone)),
            ),
            _MiniAction(
              icon: Icons.chat,
              tint: _whatsappColor,
              tooltip: l.actionWhatsapp,
              onTap: () => launchContact(context, whatsappUri(phone!)),
            ),
            _MiniAction(
              icon: Icons.send,
              tint: _telegramColor,
              tooltip: l.actionTelegram,
              onTap: () => launchContact(context, telegramUri(phone!)),
            ),
          ],
        ),
      if (email != null)
        _ContactRow(
          icon: Icons.mail_outline,
          tint: colors.blue,
          label: l.fieldEmail,
          value: email!,
          onTap: () =>
              launchContact(context, Uri(scheme: 'mailto', path: email)),
          trailing: Icons.north_east,
        ),
      if (address != null)
        _ContactRow(
          icon: Icons.location_on_outlined,
          tint: colors.orange,
          label: l.fieldAddress,
          value: address!,
          onTap: () => launchContact(
            context,
            Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address!)}'),
          ),
          trailing: Icons.directions_outlined,
          trailingTooltip: l.actionDirections,
        ),
    ];

    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(Divider(
            height: 0.5, thickness: 0.5, indent: 60, color: colors.separator));
      }
    }

    return AppleCard(
      padding: EdgeInsets.zero,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Padding(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AppleAvatar(name: name, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: AppleTypography.headline.copyWith(color: colors.label)),
          ),
        ],
      ),
    );
  }
}

/// Ligne de coordonnée : icône, libellé/valeur, et soit des boutons d'action
/// ([actions]), soit une action sur toute la ligne ([onTap] + [trailing]).
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    this.actions,
    this.onTap,
    this.trailing,
    this.trailingTooltip,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String value;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final IconData? trailing;
  final String? trailingTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final content = Padding(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: ShapeDecoration(
              color: tint.withValues(alpha: 0.16),
              shape: AppleRadii.shape(AppleRadii.sm),
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: AppleTypography.caption1
                        .copyWith(color: colors.secondaryLabel)),
                const SizedBox(height: 1),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppleTypography.body.copyWith(color: colors.label)),
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(width: 8),
            ...actions!,
          ] else if (trailing != null) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: trailingTooltip ?? '',
              child: Icon(trailing, size: 18, color: colors.tertiaryLabel),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: content,
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.tint,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 34,
            height: 34,
            decoration: ShapeDecoration(
              color: tint.withValues(alpha: 0.14),
              shape: AppleRadii.shape(AppleRadii.md),
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
        ),
      ),
    );
  }
}
