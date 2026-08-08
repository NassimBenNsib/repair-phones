// Notifications (N1) : interpolation de gabarit, variables réparation, modèle
// suggéré par statut, et journal de communication.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/company/domain/company_profile.dart';
import 'package:atelier_reparation/features/notifications/application/message_templates_controller.dart';
import 'package:atelier_reparation/features/notifications/application/notification_log_controller.dart';
import 'package:atelier_reparation/features/notifications/application/repair_message_vars.dart';
import 'package:atelier_reparation/features/notifications/domain/message_template.dart';
import 'package:atelier_reparation/features/notifications/domain/notification_log.dart';
import 'package:atelier_reparation/features/notifications/presentation/notify_sheet.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('renderTemplate : remplace les variables connues, garde le reste', () {
    const body = 'Bonjour {client}, {device} ({ref}) — {inconnu}';
    final out = renderTemplate(body, {
      'client': 'Alice',
      'device': 'iPhone 13',
      'ref': '#R-2026-0001',
    });
    expect(out, 'Bonjour Alice, iPhone 13 (#R-2026-0001) — {inconnu}');
  });

  test('repairMessageVars + modèle suggéré par statut', () async {
    final l = await AppLocalizations.delegate.load(const Locale('fr'));
    final r = Repair(
      reference: '#R-2026-0007',
      device: 'iPhone 13',
      kind: DeviceKind.phone,
      client: 'Alice',
      status: RepairStatus.completed,
      priority: RepairPriority.normal,
      progress: 1,
      updatedLabel: '',
      hoursAgo: 0,
      services: const [RepairService('Écran', 89)],
      deposit: 20,
    );
    const company = CompanyProfile(name: 'Ma Boutique', phone: '0100');
    final vars = repairMessageVars(r, company, l);
    expect(vars['client'], 'Alice');
    expect(vars['ref'], '#R-2026-0007');
    expect(vars['shop'], 'Ma Boutique');

    // Rendu d'un gabarit réel avec ces variables.
    final tpl = seedMessageTemplates.firstWhere((t) => t.id == 'tpl-ready');
    final msg = renderTemplate(tpl.body, vars);
    expect(msg.contains('Alice'), isTrue);
    expect(msg.contains('#R-2026-0007'), isTrue);
    expect(msg.contains('Ma Boutique'), isTrue);

    expect(suggestedTemplateId(RepairStatus.completed), 'tpl-ready');
    expect(suggestedTemplateId(RepairStatus.awaitingParts), 'tpl-parts');
    expect(suggestedTemplateId(RepairStatus.delivered), isNull);
  });

  test('buildMessageUri : sms / whatsapp / email pré-remplis', () {
    final sms = buildMessageUri(MessageChannel.sms, '0600', 'Prêt !');
    expect(sms.scheme, 'sms');
    expect(sms.toString().contains('body=Pr%C3%AAt'), isTrue);

    final wa = buildMessageUri(MessageChannel.whatsapp, '+33 6 00', 'Hi');
    expect(wa.toString(), 'https://wa.me/33600?text=Hi');

    final mail = buildMessageUri(MessageChannel.email, 'a@b.fr', 'Corps',
        subject: 'Objet');
    expect(mail.scheme, 'mailto');
    expect(mail.toString().contains('subject=Objet'), isTrue);
  });

  test('templates semés + journal (add / forRepair)', () {
    final c = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(c.dispose);

    final tpls = c.read(messageTemplatesProvider);
    expect(tpls.any((t) => t.id == 'tpl-ready'), isTrue);

    final log = c.read(notificationLogProvider.notifier);
    log.add(NotificationLogEntry(
      id: 'n1',
      at: DateTime(2026, 1, 5),
      channel: MessageChannel.sms,
      to: '0600',
      body: 'Prêt',
      repairRef: '#R-2026-0007',
    ));
    expect(log.forRepair('#R-2026-0007').single.body, 'Prêt');
    expect(log.forRepair('#R-2026-9999'), isEmpty);
  });
}
