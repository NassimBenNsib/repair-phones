import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/contact_actions.dart';
import '../domain/contact_channel.dart';

/// URI de lancement d'un canal selon son type (null si non actionnable).
Uri? channelUri(ContactKind kind, String value) {
  final v = value.trim();
  if (v.isEmpty) return null;
  return switch (kind) {
    ContactKind.mobile || ContactKind.landline => Uri(scheme: 'tel', path: v),
    ContactKind.whatsapp => whatsappUri(v),
    ContactKind.telegram => telegramUri(v),
    ContactKind.email => Uri(scheme: 'mailto', path: v),
    ContactKind.website => websiteUri(v),
    ContactKind.instagram => instagramUri(v),
    ContactKind.facebook => facebookUri(v),
    ContactKind.linkedin => linkedinUri(v),
    ContactKind.x => xUri(v),
    ContactKind.snapchat => snapchatUri(v),
    ContactKind.tiktok => tiktokUri(v),
    ContactKind.signal => signalUri(v),
    ContactKind.messenger => messengerUri(v),
    ContactKind.viber => viberUri(v),
    ContactKind.line => lineUri(v),
    ContactKind.youtube => youtubeUri(v),
    ContactKind.teams => teamsUri(v),
    ContactKind.wechat => null, // pas de lien web fiable → affichage seul
    ContactKind.fax => null, // numéro de fax → affichage seul
    ContactKind.other => null,
  };
}

// Couleurs de marque des actions rapides du téléphone principal.
const _whatsappColor = Color(0xFF25D366);
const _telegramColor = Color(0xFF229ED9);

/// Carte « intelligente » des coordonnées : d'abord le **téléphone** et l'**e-mail**
/// principaux (synchronisés avec la fiche), puis les canaux supplémentaires
/// (WhatsApp, Instagram, site…). Chaque ligne est actionnable.
class ClientChannelsCard extends StatelessWidget {
  const ClientChannelsCard({
    super.key,
    required this.channels,
    this.mainPhone,
    this.mainEmail,
  });

  final List<ContactChannel> channels;
  final String? mainPhone;
  final String? mainEmail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final phone = mainPhone?.trim() ?? '';
    final email = mainEmail?.trim() ?? '';
    if (phone.isEmpty && email.isEmpty && channels.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[
      if (phone.isNotEmpty)
        _ChannelRow(
          icon: Icons.call,
          tint: colors.green,
          label: l.fieldPhone,
          value: phone,
          actions: [
            _MiniAction(
                icon: Icons.call,
                tint: colors.green,
                tooltip: l.actionCall,
                onTap: () =>
                    launchContact(context, Uri(scheme: 'tel', path: phone))),
            _MiniAction(
                icon: Icons.chat,
                tint: _whatsappColor,
                tooltip: l.actionWhatsapp,
                onTap: () => launchContact(context, whatsappUri(phone))),
            _MiniAction(
                icon: Icons.send,
                tint: _telegramColor,
                tooltip: l.actionTelegram,
                onTap: () => launchContact(context, telegramUri(phone))),
          ],
        ),
      if (email.isNotEmpty)
        _ChannelRow(
          icon: Icons.mail_outline,
          tint: colors.blue,
          label: l.fieldEmail,
          value: email,
          trailing: Icons.north_east,
          onTap: () =>
              launchContact(context, Uri(scheme: 'mailto', path: email)),
        ),
      for (final ch in channels)
        () {
          final uri = channelUri(ch.kind, ch.value);
          return _ChannelRow(
            icon: ch.kind.icon,
            tint: ch.kind.color(colors),
            label: ch.kind.label(l),
            value: ch.value,
            onTap: uri == null ? null : () => launchContact(context, uri),
            trailing: uri == null
                ? null
                : (ch.kind.isPhone ? Icons.call : Icons.north_east),
          );
        }(),
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

/// Ligne de coordonnée : icône colorée + libellé/valeur, avec soit des boutons
/// d'action ([actions]), soit une action sur toute la ligne ([onTap]).
class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    this.actions,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String value;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final IconData? trailing;

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
            Icon(trailing, size: 18, color: colors.tertiaryLabel),
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

/// Petit bouton d'action rapide (pastille colorée).
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

/// Éditeur de canaux : ajouter/supprimer des contacts et **choisir le type**
/// de chacun (mobile, fixe, WhatsApp, Telegram, e-mail, site, Instagram…).
class ChannelsEditor extends StatefulWidget {
  const ChannelsEditor(
      {super.key, required this.initial, required this.onChanged});

  final List<ContactChannel> initial;
  final ValueChanged<List<ContactChannel>> onChanged;

  @override
  State<ChannelsEditor> createState() => _ChannelsEditorState();
}

class _EditRow {
  _EditRow(this.kind, this.ctrl);
  ContactKind kind;
  final TextEditingController ctrl;
}

class _ChannelsEditorState extends State<ChannelsEditor> {
  late final List<_EditRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final c in widget.initial)
        _EditRow(c.kind, TextEditingController(text: c.value)..addListener(_emit)),
    ];
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.ctrl.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged([
      for (final r in _rows)
        if (r.ctrl.text.trim().isNotEmpty)
          ContactChannel(kind: r.kind, value: r.ctrl.text.trim()),
    ]);
  }

  void _add() {
    setState(() =>
        _rows.add(_EditRow(ContactKind.mobile, TextEditingController()..addListener(_emit))));
  }

  void _remove(int i) {
    setState(() {
      _rows[i].ctrl.dispose();
      _rows.removeAt(i);
    });
    _emit();
  }

  Future<void> _pickKind(int i) async {
    final l = AppLocalizations.of(context);
    final choice = await showAppleSelectionSheet<ContactKind>(
      context: context,
      title: l.contactKindTitle,
      selected: _rows[i].kind,
      options: [
        for (final k in ContactKind.values)
          AppleSheetOption(k, k.label(l),
              leading: Icon(k.icon, size: 20, color: k.color(context.appleColors))),
      ],
    );
    if (choice != null) {
      setState(() => _rows[i].kind = choice);
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _pickKind(i),
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: _rows[i].kind.color(colors).withValues(alpha: 0.16),
                      shape: AppleRadii.shape(AppleRadii.md),
                    ),
                    child: Icon(_rows[i].kind.icon,
                        color: _rows[i].kind.color(colors), size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppleTextField(
                    controller: _rows[i].ctrl,
                    hint: _rows[i].kind.label(l),
                    keyboardType: _rows[i].kind.keyboardType,
                  ),
                ),
                IconButton(
                  onPressed: () => _remove(i),
                  icon: Icon(Icons.remove_circle_outline, color: colors.red),
                ),
              ],
            ),
          ),
        AppleButton(
          label: l.clientAddContact,
          icon: Icons.add,
          style: AppleButtonStyle.tinted,
          expand: true,
          onPressed: _add,
        ),
      ],
    );
  }
}
