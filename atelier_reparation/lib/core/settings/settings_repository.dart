import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design/app_accent.dart';
import '../format/app_formats.dart';
import 'app_settings.dart';
import 'layout_prefs.dart';
import 'vat_basis.dart';

/// Persiste [AppSettings] via `shared_preferences`.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'settings.themeMode';
  static const _kAccent = 'settings.accent';
  static const _kLocale = 'settings.locale'; // '' = système
  static const _kContentWidth = 'settings.contentWidth';
  static const _kSidebarMode = 'settings.sidebarMode';
  static const _kDetailLayout = 'settings.detailLayout';
  static const _kClientsListStyle = 'settings.clientsListStyle';
  static const _kCurrency = 'settings.currency';
  static const _kDateFormat = 'settings.dateFormat';
  static const _kVatBasis = 'settings.vatBasis';

  AppSettings load() {
    return AppSettings(
      themeMode: _themeModeFrom(_prefs.getString(_kThemeMode)),
      accent: _accentFrom(_prefs.getString(_kAccent)),
      locale: _localeFrom(_prefs.getString(_kLocale)),
      contentWidth: _enumFrom(
          ContentWidth.values, _prefs.getString(_kContentWidth), ContentWidth.normal),
      sidebarMode: _enumFrom(
          SidebarMode.values, _prefs.getString(_kSidebarMode), SidebarMode.adaptive),
      detailLayout: _enumFrom(
          DetailLayout.values, _prefs.getString(_kDetailLayout), DetailLayout.adaptive),
      clientsListStyle: _enumFrom(ClientsListStyle.values,
          _prefs.getString(_kClientsListStyle), ClientsListStyle.list),
      currency: _prefs.getString(_kCurrency) ?? 'EUR',
      dateFormat: _enumFrom(AppDateFormat.values,
          _prefs.getString(_kDateFormat), AppDateFormat.dmy),
      vatBasis: _enumFrom(
          VatBasis.values, _prefs.getString(_kVatBasis), VatBasis.accrual),
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);

  Future<void> saveAccent(AppAccent accent) =>
      _prefs.setString(_kAccent, accent.name);

  Future<void> saveLocale(Locale? locale) =>
      _prefs.setString(_kLocale, locale?.languageCode ?? '');

  Future<void> saveContentWidth(ContentWidth v) =>
      _prefs.setString(_kContentWidth, v.name);

  Future<void> saveSidebarMode(SidebarMode v) =>
      _prefs.setString(_kSidebarMode, v.name);

  Future<void> saveDetailLayout(DetailLayout v) =>
      _prefs.setString(_kDetailLayout, v.name);

  Future<void> saveClientsListStyle(ClientsListStyle v) =>
      _prefs.setString(_kClientsListStyle, v.name);

  Future<void> saveCurrency(String code) => _prefs.setString(_kCurrency, code);

  Future<void> saveDateFormat(AppDateFormat v) =>
      _prefs.setString(_kDateFormat, v.name);

  Future<void> saveVatBasis(VatBasis v) =>
      _prefs.setString(_kVatBasis, v.name);

  // --- Décodage ---

  ThemeMode _themeModeFrom(String? v) => ThemeMode.values.firstWhere(
        (m) => m.name == v,
        orElse: () => ThemeMode.system,
      );

  AppAccent _accentFrom(String? v) => AppAccent.values.firstWhere(
        (a) => a.name == v,
        orElse: () => AppAccent.blue,
      );

  Locale? _localeFrom(String? v) =>
      (v == null || v.isEmpty) ? null : Locale(v);

  T _enumFrom<T extends Enum>(List<T> values, String? v, T fallback) =>
      values.firstWhere((e) => e.name == v, orElse: () => fallback);
}
