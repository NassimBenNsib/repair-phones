// Vérifie que la liste des clients (Liste / Grille / Tableau) se construit sans
// débordement (overflow) sur plusieurs largeurs d'écran.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/auth/application/session_controller.dart';
import 'package:atelier_reparation/features/auth/data/session_repository.dart';
import 'package:atelier_reparation/features/clients/application/clients_controller.dart';
import 'package:atelier_reparation/features/clients/domain/client.dart';
import 'package:atelier_reparation/features/clients/presentation/clients_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpClients(
  WidgetTester tester, {
  required String style,
  required Size size,
}) async {
  SharedPreferences.setMockInitialValues({
    'settings.locale': 'fr',
    'settings.clientsListStyle': style,
    'session.userId': 'seed-admin',
  });
  final prefs = await SharedPreferences.getInstance();

  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        localStoreProvider.overrideWithValue(InMemoryStore()),
        sessionRepositoryProvider.overrideWithValue(SessionRepository(prefs)),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Material(child: ClientsScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // Étroit (téléphone), moyen (une colonne large), large (maître/détail).
  const sizes = <Size>[
    Size(360, 720),
    Size(800, 1000),
    Size(1200, 900),
  ];

  for (final style in const ['list', 'grid', 'table']) {
    for (final size in sizes) {
      testWidgets('clients « $style » ne déborde pas en ${size.width.toInt()}px',
          (tester) async {
        await _pumpClients(tester, style: style, size: size);
        expect(find.byType(ClientsScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  // Chaque segment filtre sans erreur ni débordement (mode tableau, écran étroit).
  for (final segment in const [
    'Débiteurs',
    'Avec crédit',
    'Inactifs',
    'Professionnels',
    'Nouveaux',
  ]) {
    testWidgets('segment « $segment » filtre sans déborder', (tester) async {
      await _pumpClients(tester, style: 'table', size: const Size(400, 800));
      await tester.tap(find.text(segment));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tableau : pagination au-delà de 25 clients', (tester) async {
    await _pumpClients(tester, style: 'table', size: const Size(800, 1000));
    final container = ProviderScope.containerOf(
        tester.element(find.byType(ClientsScreen)));
    // Ajoute assez de clients pour dépasser une page (25).
    for (var i = 0; i < 30; i++) {
      container.read(clientsProvider.notifier).add(
          Client(id: 'p$i', name: 'Paginé $i', phone: '060000$i'));
    }
    await tester.pumpAndSettle();
    // 35 clients (5 échantillons + 30) → page 1 = « 1–25 / 35 ».
    expect(find.textContaining('1–25 / 35'), findsOneWidget);
    // Le contrôle « page suivante » est à droite : l'amener dans la vue puis cliquer.
    final next = find.byIcon(Icons.chevron_right).first;
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.textContaining('26–35 / 35'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tableau : tri par en-tête sans erreur', (tester) async {
    // Largeur < 840 → une seule colonne (le tableau s'affiche). L'en-tête « Nom »
    // est à gauche, donc visible sans défilement horizontal.
    await _pumpClients(tester, style: 'table', size: const Size(800, 900));
    await tester.tap(find.text('Nom')); // tri ascendant
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nom')); // tri descendant
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
