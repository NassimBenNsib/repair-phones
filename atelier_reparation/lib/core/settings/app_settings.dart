import 'package:flutter/material.dart';

import '../design/app_accent.dart';
import '../format/app_formats.dart';
import 'layout_prefs.dart';
import 'vat_basis.dart';

/// Préférences d'apparence, de langue et de disposition de l'application.
///
/// `locale == null` signifie « suivre la langue du système ».
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.accent = AppAccent.blue,
    this.locale,
    this.contentWidth = ContentWidth.normal,
    this.sidebarMode = SidebarMode.adaptive,
    this.detailLayout = DetailLayout.adaptive,
    this.clientsListStyle = ClientsListStyle.list,
    this.currency = 'EUR',
    this.dateFormat = AppDateFormat.dmy,
    this.vatBasis = VatBasis.accrual,
  });

  final ThemeMode themeMode;
  final AppAccent accent;
  final Locale? locale;
  final ContentWidth contentWidth;
  final SidebarMode sidebarMode;
  final DetailLayout detailLayout;
  final ClientsListStyle clientsListStyle;
  final String currency; // code ISO (EUR, TND…)
  final AppDateFormat dateFormat;
  final VatBasis vatBasis;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppAccent? accent,
    Locale? locale,
    bool clearLocale = false,
    ContentWidth? contentWidth,
    SidebarMode? sidebarMode,
    DetailLayout? detailLayout,
    ClientsListStyle? clientsListStyle,
    String? currency,
    AppDateFormat? dateFormat,
    VatBasis? vatBasis,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      locale: clearLocale ? null : (locale ?? this.locale),
      contentWidth: contentWidth ?? this.contentWidth,
      sidebarMode: sidebarMode ?? this.sidebarMode,
      detailLayout: detailLayout ?? this.detailLayout,
      clientsListStyle: clientsListStyle ?? this.clientsListStyle,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      vatBasis: vatBasis ?? this.vatBasis,
    );
  }
}
