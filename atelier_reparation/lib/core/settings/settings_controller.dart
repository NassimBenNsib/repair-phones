import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/app_accent.dart';
import '../format/app_formats.dart';
import 'app_settings.dart';
import 'layout_prefs.dart';
import 'settings_repository.dart';
import 'vat_basis.dart';

/// Fournit l'instance de [SettingsRepository].
///
/// Surchargé au démarrage ([main]) avec un dépôt adossé à `SharedPreferences`.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('settingsRepositoryProvider non initialisé'),
);

/// État réactif des préférences ; persiste chaque changement.
class SettingsController extends Notifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() {
    final s = _repo.load();
    // Synchronise les formats globaux (devise + date + locale) au démarrage.
    AppFormats.currency = currencyByCode(s.currency);
    AppFormats.dateStyle = s.dateFormat;
    AppFormats.localeName = s.locale?.languageCode ?? 'fr';
    return s;
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _repo.saveThemeMode(mode);
  }

  void setAccent(AppAccent accent) {
    state = state.copyWith(accent: accent);
    _repo.saveAccent(accent);
  }

  /// `locale == null` → suivre la langue du système.
  void setLocale(Locale? locale) {
    AppFormats.localeName = locale?.languageCode ?? 'fr';
    state = locale == null
        ? state.copyWith(clearLocale: true)
        : state.copyWith(locale: locale);
    _repo.saveLocale(locale);
  }

  void setContentWidth(ContentWidth v) {
    state = state.copyWith(contentWidth: v);
    _repo.saveContentWidth(v);
  }

  void setSidebarMode(SidebarMode v) {
    state = state.copyWith(sidebarMode: v);
    _repo.saveSidebarMode(v);
  }

  void setDetailLayout(DetailLayout v) {
    state = state.copyWith(detailLayout: v);
    _repo.saveDetailLayout(v);
  }

  void setClientsListStyle(ClientsListStyle v) {
    state = state.copyWith(clientsListStyle: v);
    _repo.saveClientsListStyle(v);
  }

  void setCurrency(String code) {
    AppFormats.currency = currencyByCode(code);
    state = state.copyWith(currency: code);
    _repo.saveCurrency(code);
  }

  void setDateFormat(AppDateFormat v) {
    AppFormats.dateStyle = v;
    state = state.copyWith(dateFormat: v);
    _repo.saveDateFormat(v);
  }

  void setVatBasis(VatBasis v) {
    state = state.copyWith(vatBasis: v);
    _repo.saveVatBasis(v);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
