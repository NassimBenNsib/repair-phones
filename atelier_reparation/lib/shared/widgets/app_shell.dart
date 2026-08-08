import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/permissions.dart';
import '../../core/design/apple_tokens.dart';
import '../../core/navigation/app_sections.dart';
import '../../core/settings/layout_prefs.dart';
import '../../core/settings/settings_controller.dart';
import '../../features/auth/application/session_controller.dart';
import '../../l10n/app_localizations.dart';
import 'apple/apple_avatar.dart';
import 'apple/apple_sheet.dart';

/// Coquille de navigation adaptative et direction-aware (LTR/RTL).
///
/// - Mobile : barre inférieure en verre (sections principales) + « Plus ».
/// - Tablette / iPad / desktop : barre latérale personnalisée, groupée et
///   défilante, listant toutes les sections.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final accent = context.accentColor;
    final location = state.uri.path;

    // Filtre les sections selon les permissions de l'utilisateur.
    ref.watch(sessionControllerProvider);
    bool can(Permission p) =>
        ref.read(sessionControllerProvider.notifier).can(p);
    final visible = [
      for (final s in appSections)
        if (s.permission == null || can(s.permission!)) s,
    ];

    // Compact → barre inférieure : principales + « Plus ».
    if (context.isCompact) {
      final primary = [for (final s in visible) if (s.primary) s];
      final selected = primary.indexWhere((s) => s.matches(location));
      final selectedIndex = selected < 0 ? primary.length : selected;

      return Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: GlassSurface(
          colors: colors,
          border: Border(top: BorderSide(color: colors.separator, width: 0.5)),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: accent.withValues(alpha: 0.16),
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) {
              if (i < primary.length) {
                context.go(primary[i].path);
              } else {
                _showAllSectionsSheet(context, l, location, visible);
              }
            },
            destinations: [
              for (final s in primary)
                NavigationDestination(
                  icon: Icon(s.icon, color: colors.secondaryLabel),
                  selectedIcon: Icon(s.selectedIcon, color: accent),
                  label: s.label(l),
                ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz, color: colors.secondaryLabel),
                label: l.navMore,
              ),
            ],
          ),
        ),
      );
    }

    // Medium / expanded → barre latérale personnalisée.
    final sidebarMode =
        ref.watch(settingsControllerProvider.select((s) => s.sidebarMode));
    final extended =
        sidebarMode == SidebarMode.expanded ? true : context.isExpanded;
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
              extended: extended, location: location, l: l, sections: visible),
          VerticalDivider(width: 0.5, thickness: 0.5, color: colors.separator),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Feuille listant toutes les sections (accès mobile aux sections secondaires).
Future<void> _showAllSectionsSheet(
  BuildContext context,
  AppLocalizations l,
  String location,
  List<AppSection> visible,
) {
  return showAppleSheet<void>(
    context: context,
    title: l.navMore,
    builder: (context) {
      final colors = context.appleColors;
      return ListView(
        children: [
          for (final group in NavGroup.values)
            ..._groupBlock(context, l, group, location, colors, visible),
          const SizedBox(height: 8),
        ],
      );
    },
  );
}

List<Widget> _groupBlock(
  BuildContext context,
  AppLocalizations l,
  NavGroup group,
  String location,
  AppleColors colors,
  List<AppSection> visible,
) {
  final sections = visible.where((s) => s.group == group).toList();
  if (sections.isEmpty) return const [];
  return [
    Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 6),
      child: Text(
        group.label(l).toUpperCase(),
        style: AppleTypography.caption1.copyWith(
          color: colors.secondaryLabel,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    ),
    for (final s in sections)
      ListTile(
        leading: _IconTile(
          icon: s.selectedIcon,
          tint: context.accentColor,
          selected: s.matches(location),
        ),
        title: Text(s.label(l),
            style: AppleTypography.body.copyWith(color: colors.label)),
        trailing: Icon(context.chevronForward,
            size: 18, color: colors.tertiaryLabel),
        onTap: () {
          Navigator.of(context).pop();
          context.go(s.path);
        },
      ),
  ];
}

/// Barre latérale personnalisée façon Apple : marque, sections groupées
/// défilantes, pied de compte.
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.extended,
    required this.location,
    required this.l,
    required this.sections,
  });

  final bool extended;
  final String location;
  final AppLocalizations l;
  final List<AppSection> sections;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final width = extended ? 252.0 : 76.0;

    // Construit les entrées groupées.
    final children = <Widget>[];
    var firstGroup = true;
    for (final group in NavGroup.values) {
      final groupSections =
          sections.where((s) => s.group == group).toList();
      if (groupSections.isEmpty) continue;
      if (extended) {
        children.add(_GroupHeader(label: group.label(l)));
      } else if (!firstGroup) {
        children.add(const _SidebarDivider());
      }
      for (final s in groupSections) {
        children.add(_SidebarItem(
          section: s,
          selected: s.matches(location),
          extended: extended,
          label: s.label(l),
          onTap: () => context.go(s.path),
        ));
      }
      firstGroup = false;
    }

    return Container(
      width: width,
      color: colors.secondaryGroupedBackground,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Brand(extended: extended, l: l),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: children,
              ),
            ),
            const _SidebarDivider(),
            _AccountFooter(
              extended: extended,
              name: l.appTitle,
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(22, 16, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: AppleTypography.caption1.copyWith(
          color: colors.secondaryLabel,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// En-tête de marque de la barre latérale.
class _Brand extends StatelessWidget {
  const _Brand({required this.extended, required this.l});

  final bool extended;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final accent = context.accentColor;

    final tile = Container(
      width: 38,
      height: 38,
      decoration: ShapeDecoration(
        color: accent.withValues(alpha: 0.16),
        shape: AppleRadii.shape(AppleRadii.md),
      ),
      child: Icon(Icons.handyman, color: accent, size: 22),
    );

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(extended ? 16 : 0, 16, 16, 8),
      child: extended
          ? Row(
              children: [
                tile,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.appTitle,
                    maxLines: 2,
                    style:
                        AppleTypography.headline.copyWith(color: colors.label),
                  ),
                ),
              ],
            )
          : Center(child: tile),
    );
  }
}

/// Pastille d'icône (survol / sélection) réutilisable.
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.tint,
    required this.selected,
  });

  final IconData icon;
  final Color tint;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Container(
      width: 30,
      height: 30,
      decoration: ShapeDecoration(
        color: selected ? tint : colors.fill,
        shape: AppleRadii.shape(AppleRadii.sm),
      ),
      child: Icon(icon, size: 17, color: selected ? Colors.white : tint),
    );
  }
}

/// Élément de navigation : pastille squircle sélectionnée, survol et pression.
class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.section,
    required this.selected,
    required this.extended,
    required this.label,
    required this.onTap,
  });

  final AppSection section;
  final bool selected;
  final bool extended;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final accent = context.accentColor;
    final selected = widget.selected;

    final bg = selected
        ? accent.withValues(alpha: 0.14)
        : (_hover ? colors.fill : Colors.transparent);
    final fg = selected ? accent : colors.label;
    final iconColor = selected ? accent : colors.secondaryLabel;
    final icon =
        selected ? widget.section.selectedIcon : widget.section.icon;

    final content = widget.extended
        ? Row(
            children: [
              Icon(icon, size: 21, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppleTypography.body.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          )
        : Center(child: Icon(icon, size: 22, color: iconColor));

    final item = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: AppleMotion.fast,
          curve: AppleMotion.standard,
          child: AnimatedContainer(
            duration: AppleMotion.fast,
            height: 44,
            margin: EdgeInsetsDirectional.symmetric(
              horizontal: widget.extended ? 10 : 16,
              vertical: 2,
            ),
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: widget.extended ? 12 : 0,
            ),
            decoration: ShapeDecoration(
              color: bg,
              shape: AppleRadii.shape(AppleRadii.md),
            ),
            child: content,
          ),
        ),
      ),
    );

    if (widget.extended) return item;
    return Tooltip(message: widget.label, child: item);
  }
}

class _SidebarDivider extends StatelessWidget {
  const _SidebarDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Container(
      height: 0.5,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
      color: colors.separator,
    );
  }
}

/// Pied de barre : chip de compte / atelier.
class _AccountFooter extends StatefulWidget {
  const _AccountFooter({
    required this.extended,
    required this.name,
    required this.onTap,
  });

  final bool extended;
  final String name;
  final VoidCallback onTap;

  @override
  State<_AccountFooter> createState() => _AccountFooterState();
}

class _AccountFooterState extends State<_AccountFooter> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;

    final child = widget.extended
        ? Row(
            children: [
              AppleAvatar(name: widget.name, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppleTypography.subheadline.copyWith(
                      color: colors.label, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(context.chevronForward,
                  size: 18, color: colors.tertiaryLabel),
            ],
          )
        : Center(child: AppleAvatar(name: widget.name, size: 32));

    return Padding(
      padding: const EdgeInsets.all(10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppleMotion.fast,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: widget.extended ? 8 : 0,
              vertical: 6,
            ),
            decoration: ShapeDecoration(
              color: _hover ? colors.fill : Colors.transparent,
              shape: AppleRadii.shape(AppleRadii.md),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
