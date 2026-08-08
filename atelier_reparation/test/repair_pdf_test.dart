// Fiche Pro (A4) : la génération produit un PDF non vide, avec ou sans
// pièces/prestations, en LTR comme en RTL.

import 'package:atelier_reparation/features/company/domain/company_profile.dart';
import 'package:atelier_reparation/features/repairs/application/repair_pdf.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Repair _repair({List<RepairService> services = const [], List<RepairPart> parts = const []}) =>
    Repair(
      reference: '#R-2026-0001',
      device: 'iPhone 13 — écran',
      kind: DeviceKind.phone,
      client: 'Alice Martin',
      clientPhone: '0600000000',
      status: RepairStatus.inProgress,
      priority: RepairPriority.normal,
      progress: 0.5,
      updatedLabel: '',
      hoursAgo: 2,
      reportedIssue: 'Écran cassé',
      diagnosis: 'Vitre à remplacer',
      brand: 'Apple',
      model: 'iPhone 13',
      serial: 'ABC123',
      services: services,
      parts: parts,
      deposit: 30,
      warrantyMonths: 6,
      createdAt: DateTime(2026, 1, 5),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const company = CompanyProfile(
      name: 'Ma Boutique', phone: '0100000000', address: '12 rue des Lilas');

  test('buildRepairSheet : PDF non vide avec pièces + prestations', () async {
    final l = await AppLocalizations.delegate.load(const Locale('fr'));
    final bytes = await buildRepairSheet(
      repair: _repair(
        services: const [RepairService('Main d\'œuvre', 40)],
        parts: const [RepairPart(label: 'Écran', quantity: 1, unitPrice: 89)],
      ),
      company: company,
      l: l,
    );
    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));
  });

  test('buildRepairSheet : sans lignes ni en RTL, ne lève pas', () async {
    final l = await AppLocalizations.delegate.load(const Locale('ar'));
    final bytes = await buildRepairSheet(
      repair: _repair(),
      company: company,
      l: l,
      rtl: true,
    );
    expect(bytes, isNotEmpty);
  });

  test('buildRepairTicket : ticket 80 mm non vide (LTR + RTL)', () async {
    final fr = await AppLocalizations.delegate.load(const Locale('fr'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    final a = await buildRepairTicket(
        repair: _repair(), company: company, l: fr);
    final b = await buildRepairTicket(
        repair: _repair(), company: company, l: ar, rtl: true);
    expect(a, isNotEmpty);
    expect(b, isNotEmpty);
  });
}
