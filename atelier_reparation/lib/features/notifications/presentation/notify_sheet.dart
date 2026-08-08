import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/contact_actions.dart';
import '../../company/application/company_controller.dart';
import '../../repairs/domain/repair.dart';
import '../application/message_templates_controller.dart';
import '../application/notification_log_controller.dart';
import '../application/repair_message_vars.dart';
import '../domain/message_template.dart';
import '../domain/notification_log.dart';

/// Libellé d'un canal.
String channelLabel(AppLocalizations l, MessageChannel c) => switch (c) {
      MessageChannel.sms => l.actionSms,
      MessageChannel.whatsapp => l.actionWhatsapp,
      MessageChannel.email => l.actionEmail,
    };

/// Construit l'URI d'envoi pré-rempli pour un canal donné.
Uri buildMessageUri(MessageChannel channel, String recipient, String text,
    {String? subject}) {
  switch (channel) {
    case MessageChannel.sms:
      return Uri.parse('sms:$recipient?body=${Uri.encodeComponent(text)}');
    case MessageChannel.whatsapp:
      final digits = recipient.replaceAll(RegExp(r'[^0-9]'), '');
      return Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(text)}');
    case MessageChannel.email:
      final q = 'body=${Uri.encodeComponent(text)}'
          '${subject != null && subject.isNotEmpty ? '&subject=${Uri.encodeComponent(subject)}' : ''}';
      return Uri.parse('mailto:$recipient?$q');
  }
}

/// Ouvre la feuille « Notifier le client » pour une réparation.
Future<void> showNotifySheet(BuildContext context, Repair repair) =>
    showAppleSheet<void>(
      context: context,
      title: AppLocalizations.of(context).repairNotify,
      builder: (_) => NotifyForm(repair: repair),
    );

class NotifyForm extends ConsumerStatefulWidget {
  const NotifyForm({super.key, required this.repair});
  final Repair repair;

  @override
  ConsumerState<NotifyForm> createState() => _NotifyFormState();
}

class _NotifyFormState extends ConsumerState<NotifyForm> {
  final _body = TextEditingController();
  String? _templateId;
  MessageChannel _channel = MessageChannel.sms;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    final templates = ref.read(messageTemplatesProvider);
    final suggested = suggestedTemplateId(widget.repair.status);
    final tpl = templates.firstWhere((t) => t.id == suggested,
        orElse: () => templates.isNotEmpty
            ? templates.first
            : const MessageTemplate(
                id: '', name: '', channel: MessageChannel.sms, body: ''));
    _templateId = tpl.id.isEmpty ? null : tpl.id;
    _channel = tpl.channel;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Le rendu utilise AppLocalizations → interdit dans initState.
    if (_didInit) return;
    _didInit = true;
    if (_templateId != null) {
      final tpl = ref.read(messageTemplatesProvider.notifier).byId(_templateId!);
      if (tpl != null) _applyTemplate(tpl);
    }
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  void _applyTemplate(MessageTemplate tpl) {
    final l = AppLocalizations.of(context);
    final vars =
        repairMessageVars(widget.repair, ref.read(companyProvider), l);
    _body.text = renderTemplate(tpl.body, vars);
  }

  String? get _recipient {
    final r = widget.repair;
    return _channel == MessageChannel.email ? r.clientEmail : r.clientPhone;
  }

  void _send() {
    final to = _recipient;
    if (to == null || to.isEmpty) return;
    final text = _body.text.trim();
    final tpl = _templateId == null
        ? null
        : ref.read(messageTemplatesProvider.notifier).byId(_templateId!);
    // Journalise l'intention (même si le lancement échoue).
    ref.read(notificationLogProvider.notifier).add(NotificationLogEntry(
          id: const Uuid().v4(),
          at: DateTime.now(),
          channel: _channel,
          to: to,
          body: text,
          repairRef: widget.repair.reference,
          clientId: widget.repair.clientId,
          templateId: _templateId,
        ));
    launchContact(context,
        buildMessageUri(_channel, to, text, subject: tpl?.subject));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final templates =
        ref.watch(messageTemplatesProvider).where((t) => t.active).toList();
    final to = _recipient;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Modèles.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l.notifyTemplate,
                style: AppleTypography.footnote
                    .copyWith(color: colors.secondaryLabel)),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in templates)
              AppleChip(
                label: t.name,
                selected: _templateId == t.id,
                onTap: () => setState(() {
                  _templateId = t.id;
                  _channel = t.channel;
                  _applyTemplate(t);
                }),
              ),
          ]),
          const SizedBox(height: 16),
          // Canal.
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in MessageChannel.values)
              AppleChip(
                label: channelLabel(l, c),
                selected: _channel == c,
                onTap: () => setState(() => _channel = c),
              ),
          ]),
          const SizedBox(height: 16),
          AppleTextField(controller: _body, label: l.notifyMessage,
              minLines: 3, maxLines: 6),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
                to == null || to.isEmpty ? l.notifyNoContact : to,
                style: AppleTypography.footnote.copyWith(
                    color: to == null || to.isEmpty
                        ? colors.red
                        : colors.secondaryLabel)),
          ),
          const SizedBox(height: 16),
          AppleButton(
            label: l.notifySend,
            icon: Icons.send,
            expand: true,
            onPressed: (to == null || to.isEmpty) ? null : _send,
          ),
        ],
      ),
    );
  }
}
