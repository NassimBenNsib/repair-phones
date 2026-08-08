import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/permissions.dart';
import '../../../core/design/apple_tokens.dart';
import '../../../core/format/app_formats.dart';
import '../../../core/settings/layout_prefs.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/session_controller.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../company/presentation/company_screen.dart';
import '../../integrations/presentation/integrations_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../staff/application/employees_controller.dart';
import '../../users/application/users_controller.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/section_header.dart';

/// Paramètres : apparence (thème + accent), langue et informations.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    // Utilisateur connecté (carte Profil en tête).
    final userId = ref.watch(sessionControllerProvider);
    final me = userId == null
        ? null
        : ref.watch(usersProvider).where((u) => u.id == userId).firstOrNull;
    final employees = ref.watch(employeesProvider);
    final meName = me == null
        ? null
        : (me.employeeId == null
                ? null
                : employees.where((e) => e.id == me.employeeId).firstOrNull?.name) ??
            me.email;

    Widget section(Widget child) => SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: child),
        );
    Widget header(String t, {double top = 20}) => SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(16, top, 16, 4),
          sliver: SliverToBoxAdapter(child: SectionHeader(title: t)),
        );

    return AppleScaffold(
      title: l.settingsTitle,
      slivers: [
        if (me != null)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(
              child: AppleCard(
                padding: const EdgeInsets.all(12),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Row(children: [
                  AppleAvatar(name: meName ?? me.email, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meName ?? me.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppleTypography.headline
                                .copyWith(color: context.appleColors.label)),
                        Text(l.profileSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppleTypography.footnote.copyWith(
                                color: context.appleColors.secondaryLabel)),
                      ],
                    ),
                  ),
                  AppleBadge(
                      label: me.role.label(l), color: context.accentColor),
                  const SizedBox(width: 8),
                  Icon(context.chevronForward,
                      size: 20, color: context.appleColors.tertiaryLabel),
                ]),
              ),
            ),
          ),
        header(l.settingsAppearance, top: 8),
        section(
          AppleCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.settingsThemeMode,
                    style: AppleTypography.subheadline
                        .copyWith(color: context.appleColors.secondaryLabel)),
                const SizedBox(height: 8),
                AppleSegmentedControl<ThemeMode>(
                  value: settings.themeMode,
                  onChanged: controller.setThemeMode,
                  segments: {
                    ThemeMode.system: l.settingsThemeSystem,
                    ThemeMode.light: l.settingsThemeLight,
                    ThemeMode.dark: l.settingsThemeDark,
                  },
                ),
                const SizedBox(height: 20),
                Text(l.settingsAccent,
                    style: AppleTypography.subheadline
                        .copyWith(color: context.appleColors.secondaryLabel)),
                const SizedBox(height: 12),
                _AccentPicker(
                  selected: settings.accent,
                  onSelect: controller.setAccent,
                ),
              ],
            ),
          ),
        ),

        header(l.settingsSectionLayout),
        section(
          AppleCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LayoutLabel(l.settingsContentWidth),
                AppleSegmentedControl<ContentWidth>(
                  value: settings.contentWidth,
                  onChanged: controller.setContentWidth,
                  segments: {
                    for (final v in ContentWidth.values) v: v.label(l),
                  },
                ),
                const SizedBox(height: 20),
                _LayoutLabel(l.settingsSidebar),
                AppleSegmentedControl<SidebarMode>(
                  value: settings.sidebarMode,
                  onChanged: controller.setSidebarMode,
                  segments: {
                    for (final v in SidebarMode.values) v: v.label(l),
                  },
                ),
                const SizedBox(height: 20),
                _LayoutLabel(l.settingsDetailView),
                AppleSegmentedControl<DetailLayout>(
                  value: settings.detailLayout,
                  onChanged: controller.setDetailLayout,
                  segments: {
                    for (final v in DetailLayout.values) v: v.label(l),
                  },
                ),
                const SizedBox(height: 20),
                _LayoutLabel(l.settingsClientsView),
                AppleSegmentedControl<ClientsListStyle>(
                  value: settings.clientsListStyle,
                  onChanged: controller.setClientsListStyle,
                  segments: {
                    for (final v in ClientsListStyle.values) v: v.label(l),
                  },
                ),
              ],
            ),
          ),
        ),

        header(l.settingsRegional),
        section(
          AppleListSection(
            children: [
              AppleListRow(
                leadingIcon: Icons.language,
                leadingTint: context.accentColor,
                title: l.settingsLanguage,
                trailingText: _localeLabel(l, settings.locale),
                showChevron: true,
                onTap: () => _pickLanguage(context, ref, l, settings.locale),
              ),
              AppleListRow(
                leadingIcon: Icons.payments_outlined,
                leadingTint: context.appleColors.green,
                title: l.settingsCurrency,
                trailingText:
                    '${settings.currency} · ${currencyByCode(settings.currency).symbol}',
                showChevron: true,
                onTap: () => _pickCurrency(context, ref, l, settings.currency),
              ),
              AppleListRow(
                leadingIcon: Icons.event_outlined,
                leadingTint: context.appleColors.orange,
                title: l.settingsDateFormat,
                trailingText: settings.dateFormat.sample,
                showChevron: true,
                onTap: () =>
                    _pickDateFormat(context, ref, l, settings.dateFormat),
              ),
            ],
          ),
        ),

        header(l.settingsGeneral),
        section(
          AppleListSection(
            children: [
              AppleListRow(
                leadingIcon: Icons.store,
                leadingTint: context.appleColors.green,
                title: l.settingsWorkshopInfo,
                subtitle: l.settingsWorkshopInfoSubtitle,
                showChevron: true,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CompanyScreen())),
              ),
              AppleListRow(
                leadingIcon: Icons.backup_outlined,
                leadingTint: context.appleColors.blue,
                title: l.settingsBackup,
                subtitle: l.settingsBackupSubtitle,
                showChevron: true,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BackupScreen())),
              ),
              AppleListRow(
                leadingIcon: Icons.extension_outlined,
                leadingTint: context.appleColors.indigo,
                title: l.navIntegrations,
                subtitle: l.integrationsSubtitle,
                showChevron: true,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const IntegrationsScreen())),
              ),
              AppleListRow(
                leadingIcon: Icons.cloud_off_outlined,
                leadingTint: context.appleColors.secondaryLabel,
                title: l.settingsStorage,
                trailingText: l.settingsStorageLocal,
              ),
            ],
          ),
        ),

        header(l.settingsAbout),
        section(
          AppleListSection(
            children: [
              AppleListRow(
                leadingIcon: Icons.info_outline,
                leadingTint: context.appleColors.indigo,
                title: l.appTitle,
                subtitle: l.settingsAboutDescription,
                trailingText: '1.0.0',
              ),
              AppleListRow(
                leadingIcon: Icons.logout,
                leadingTint: context.appleColors.red,
                title: l.authLogout,
                onTap: () =>
                    ref.read(sessionControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _localeLabel(AppLocalizations l, Locale? locale) {
    switch (locale?.languageCode) {
      case 'fr':
        return l.languageFrench;
      case 'en':
        return l.languageEnglish;
      case 'ar':
        return l.languageArabic;
      case 'es':
        return l.languageSpanish;
      default:
        return l.languageSystem;
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    Locale? current,
  ) async {
    final choice = await showAppleSelectionSheet<String>(
      context: context,
      title: l.settingsLanguage,
      selected: current?.languageCode ?? '',
      options: [
        AppleSheetOption('', l.languageSystem),
        AppleSheetOption('fr', l.languageFrench),
        AppleSheetOption('en', l.languageEnglish),
        AppleSheetOption('ar', l.languageArabic),
        AppleSheetOption('es', l.languageSpanish),
      ],
    );
    if (choice == null) return;
    ref.read(settingsControllerProvider.notifier).setLocale(
          choice.isEmpty ? null : Locale(choice),
        );
  }

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref,
      AppLocalizations l, String current) async {
    final choice = await showAppleSelectionSheet<String>(
      context: context,
      title: l.settingsCurrency,
      selected: current,
      options: [
        for (final c in kCurrencies)
          AppleSheetOption(c.code, '${c.code} · ${c.symbol}'),
      ],
    );
    if (choice == null) return;
    ref.read(settingsControllerProvider.notifier).setCurrency(choice);
  }

  Future<void> _pickDateFormat(BuildContext context, WidgetRef ref,
      AppLocalizations l, AppDateFormat current) async {
    final choice = await showAppleSelectionSheet<AppDateFormat>(
      context: context,
      title: l.settingsDateFormat,
      selected: current,
      options: [
        for (final f in AppDateFormat.values) AppleSheetOption(f, f.sample),
      ],
    );
    if (choice == null) return;
    ref.read(settingsControllerProvider.notifier).setDateFormat(choice);
  }
}

/// Libellé de réglage de disposition.
class _LayoutLabel extends StatelessWidget {
  const _LayoutLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(text,
            style: AppleTypography.subheadline
                .copyWith(color: context.appleColors.secondaryLabel)),
      ),
    );
  }
}

/// Rangée d'échantillons de couleur d'accent, avec coche sur l'actif.
class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.selected, required this.onSelect});

  final AppAccent selected;
  final ValueChanged<AppAccent> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final accent in AppAccent.values)
          GestureDetector(
            onTap: () => onSelect(accent),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.resolve(colors),
                shape: BoxShape.circle,
                border: accent == selected
                    ? Border.all(color: colors.label, width: 2.5)
                    : null,
              ),
              child: accent == selected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
      ],
    );
  }
}
