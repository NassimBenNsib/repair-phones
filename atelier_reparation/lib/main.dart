import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/data/open_local_store.dart';
import 'core/data/storage.dart';
import 'core/settings/settings_controller.dart';
import 'core/settings/settings_repository.dart';
import 'features/auth/application/session_controller.dart';
import 'features/auth/data/session_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données de localisation des dates pour toutes les langues.
  await initializeDateFormatting();

  // Charge les préférences persistées avant le premier rendu.
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);

  // Ouvre le stockage local (SQLite sur natif, mémoire sur le Web).
  final localStore = await openLocalStore();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        localStoreProvider.overrideWithValue(localStore),
        sessionRepositoryProvider
            .overrideWithValue(SessionRepository(prefs)),
      ],
      child: const AtelierReparationApp(),
    ),
  );
}
