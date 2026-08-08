// États vides « intelligents » et segments des répertoires Fournisseurs & Comptes :
// - collection vide → état avec bouton de création (CTA) ;
// - recherche sans résultat → état « Aucun résultat » sans CTA ;
// - barre de segments présente, filtrage sans débordement.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/auth/application/session_controller.dart';
import 'package:atelier_reparation/features/auth/data/session_repository.dart';
import 'package:atelier_reparation/features/staff/presentation/employees_screen.dart';
import 'package:atelier_reparation/features/suppliers/application/suppliers_controller.dart';
import 'package:atelier_reparation/features/suppliers/presentation/suppliers_screen.dart';
import 'package:atelier_reparation/features/users/application/users_controller.dart';
import 'package:atelier_reparation/features/users/presentation/users_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget screen, {
  String style = 'list',
  Size size = const Size(390, 780),
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

  final scope = ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
      localStoreProvider.overrideWithValue(InMemoryStore()),
      sessionRepositoryProvider.overrideWithValue(SessionRepository(prefs)),
    ],
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(child: screen),
    ),
  );
  await tester.pumpWidget(scope);
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(screen.runtimeType)));
}

void main() {
  testWidgets('Fournisseurs : segment, aucun résultat, CTA si vide',
      (tester) async {
    final container = await _pump(tester, const SuppliersScreen());

    // Barre de segments présente.
    expect(find.text('Toutes'), findsWidgets);

    // Recherche sans résultat → « Aucun résultat », pas de CTA.
    await tester.enterText(find.byType(TextField).first, 'zzzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('Aucun résultat'), findsOneWidget);
    expect(find.text('Nouveau fournisseur'), findsNothing);

    // Vider le répertoire → état vide avec CTA de création.
    await tester.enterText(find.byType(TextField).first, '');
    for (final s in [...container.read(suppliersProvider)]) {
      container.read(suppliersProvider.notifier).remove(s.id);
    }
    await tester.pumpAndSettle();
    expect(find.text('Aucun fournisseur'), findsOneWidget);
    expect(find.text('Nouveau fournisseur'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Comptes : segment, aucun résultat, CTA si vide', (tester) async {
    final container = await _pump(tester, const UsersScreen());

    expect(find.text('Toutes'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'zzzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('Aucun résultat'), findsOneWidget);
    expect(find.text('Nouvel utilisateur'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '');
    for (final u in [...container.read(usersProvider)]) {
      container.read(usersProvider.notifier).remove(u.id);
    }
    await tester.pumpAndSettle();
    expect(find.text('Aucun utilisateur'), findsOneWidget);
    expect(find.text('Nouvel utilisateur'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Modes grille & tableau (données d'exemple) : rendu sans débordement, en
  // écran étroit (390) et large (1200), sur les trois répertoires.
  Widget screenFor(String key) => switch (key) {
        'suppliers' => const SuppliersScreen(),
        'users' => const UsersScreen(),
        _ => const EmployeesScreen(),
      };

  for (final key in const ['suppliers', 'users', 'employees']) {
    for (final style in const ['grid', 'table']) {
      for (final w in const [390.0, 1200.0]) {
        testWidgets('$key « $style » ne déborde pas en ${w.toInt()}px',
            (tester) async {
          await _pump(tester, screenFor(key),
              style: style, size: Size(w, 900));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
