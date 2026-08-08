import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/layout_prefs.dart';
import '../../../l10n/app_localizations.dart';
import 'apple_avatar.dart';
import 'apple_badge.dart';
import 'apple_card.dart';

/// Bascule liste ↔ grille ↔ tableau (barre d'outils) — affiche l'icône du mode
/// *suivant* ; un tap avance dans le cycle. Partagée par tous les répertoires.
class DirectoryViewToggle extends StatelessWidget {
  const DirectoryViewToggle(
      {super.key, required this.style, required this.onChanged});

  final ClientsListStyle style;
  final ValueChanged<ClientsListStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const values = ClientsListStyle.values;
    final next = values[(style.index + 1) % values.length];
    return IconButton(
      onPressed: () => onChanged(next),
      icon: Icon(next.icon, color: context.accentColor),
      tooltip: next.label(l),
    );
  }
}

/// Carte de répertoire (mode grille) : avatar, badge optionnel, titre, sous-titre.
class DirectoryCard extends StatelessWidget {
  const DirectoryCard({
    super.key,
    required this.name,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.badgeColor,
  });

  final String name;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return AppleCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            AppleAvatar(name: name, size: 40),
            const SizedBox(width: 10),
            if (badge != null)
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: AppleBadge(
                        label: badge!,
                        color: badgeColor ?? context.accentColor),
                  ),
                ),
              ),
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppleTypography.subheadline
                      .copyWith(color: colors.label, fontWeight: FontWeight.w600)),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Définition d'une colonne de [DirectoryTable].
class DirColumn<T> {
  const DirColumn({
    required this.label,
    required this.width,
    required this.value,
    this.sortKey,
    this.leading = false,
    this.color,
  });

  final String label;
  final double width;

  /// Texte de la cellule.
  final String Function(T item) value;

  /// Clé de tri (null = colonne non triable).
  final Comparable Function(T item)? sortKey;

  /// Colonne « principale » : préfixée d'un avatar.
  final bool leading;

  /// Couleur optionnelle du texte de la cellule.
  final Color? Function(T item, AppleColors colors)? color;
}

/// Tableau générique de répertoire, aligné sur le design system : tri sur toute
/// colonne pourvue d'une [DirColumn.sortKey] (3 états : asc → desc → aucun),
/// colonnes qui s'étirent pour remplir la largeur (défilement horizontal si trop
/// étroit), séparateurs « hairline », et pied nombre + pagination.
class DirectoryTable<T> extends StatefulWidget {
  const DirectoryTable({
    super.key,
    required this.items,
    required this.columns,
    required this.avatarName,
    required this.onTap,
    this.pageSize = 25,
  });

  final List<T> items;
  final List<DirColumn<T>> columns;
  final String Function(T item) avatarName;
  final void Function(T item) onTap;
  final int pageSize;

  @override
  State<DirectoryTable<T>> createState() => _DirectoryTableState<T>();
}

class _DirectoryTableState<T> extends State<DirectoryTable<T>> {
  int? _sortCol;
  bool _asc = true;
  int _page = 0;

  @override
  void didUpdateWidget(covariant DirectoryTable<T> old) {
    super.didUpdateWidget(old);
    if (old.items.length != widget.items.length) _page = 0;
  }

  void _tapHeader(int col) => setState(() {
        _page = 0;
        if (_sortCol != col) {
          _sortCol = col;
          _asc = true;
        } else if (_asc) {
          _asc = false;
        } else {
          _sortCol = null;
        }
      });

  List<T> get _sorted {
    final col = _sortCol;
    if (col == null) return widget.items;
    final key = widget.columns[col].sortKey;
    if (key == null) return widget.items;
    final list = [...widget.items]
      ..sort((a, b) => Comparable.compare(key(a), key(b)));
    return _asc ? list : list.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final cols = widget.columns;
    final baseTotal = cols.fold<double>(0, (s, c) => s + c.width);
    final sorted = _sorted;

    // Pagination.
    final paginated = sorted.length > widget.pageSize;
    final pageCount = paginated ? (sorted.length / widget.pageSize).ceil() : 1;
    final page = _page.clamp(0, pageCount - 1);
    final start = page * widget.pageSize;
    final end = (start + widget.pageSize) < sorted.length
        ? start + widget.pageSize
        : sorted.length;
    final visible = paginated ? sorted.sublist(start, end) : sorted;

    Widget hair([double indent = 16]) => Divider(
        height: 0.5, thickness: 0.5, indent: indent, color: colors.separator);

    Widget navBtn(IconData icon, bool enabled, VoidCallback onTap) => InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon,
                size: 18,
                color: enabled ? context.accentColor : colors.tertiaryLabel),
          ),
        );

    final prevIcon = context.isRtl ? Icons.chevron_right : Icons.chevron_left;

    return LayoutBuilder(builder: (context, constraints) {
      final minRow = baseTotal + 32;
      final avail = constraints.maxWidth;
      final k = avail > minRow ? (avail - 32) / baseTotal : 1.0;
      double w(double base) => base * k;
      final rowWidth = baseTotal * k + 32;

      Widget cell(String text, double width, {Color? color}) => SizedBox(
            width: width,
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppleTypography.subheadline
                    .copyWith(color: color ?? colors.label)),
          );

      Widget head(DirColumn<T> c, int i) {
        final active = _sortCol == i;
        final child = Row(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            child: Text(c.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppleTypography.caption1.copyWith(
                    color: active ? context.accentColor : colors.secondaryLabel,
                    fontWeight: FontWeight.w600)),
          ),
          if (active)
            Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12, color: context.accentColor),
        ]);
        return SizedBox(
          width: w(c.width),
          child: c.sortKey == null
              ? child
              : InkWell(onTap: () => _tapHeader(i), child: child),
        );
      }

      final headerRow = Padding(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          for (var i = 0; i < cols.length; i++) head(cols[i], i),
        ]),
      );

      final rows = <Widget>[headerRow, hair(0)];
      for (var r = 0; r < visible.length; r++) {
        final item = visible[r];
        if (r > 0) rows.add(hair());
        rows.add(Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => widget.onTap(item),
            splashColor: colors.fill,
            highlightColor: colors.fill,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(children: [
                for (final c in cols)
                  if (c.leading)
                    SizedBox(
                      width: w(c.width),
                      child: Row(children: [
                        AppleAvatar(name: widget.avatarName(item), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c.value(item),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppleTypography.subheadline
                                  .copyWith(color: colors.label)),
                        ),
                      ]),
                    )
                  else
                    cell(c.value(item), w(c.width),
                        color: c.color?.call(item, colors) ??
                            colors.secondaryLabel),
              ]),
            ),
          ),
        ));
      }

      final countText = paginated
          ? '${start + 1}–$end / ${sorted.length}'
          : '${sorted.length}';
      final footer = Padding(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Expanded(
            child: Text(countText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppleTypography.caption1.copyWith(
                    color: colors.secondaryLabel, fontWeight: FontWeight.w600)),
          ),
          if (paginated) ...[
            navBtn(prevIcon, page > 0, () => setState(() => _page = page - 1)),
            Text('${page + 1}/$pageCount',
                style: AppleTypography.caption1
                    .copyWith(color: colors.secondaryLabel)),
            navBtn(context.chevronForward, page < pageCount - 1,
                () => setState(() => _page = page + 1)),
          ],
        ]),
      );
      rows.add(hair(0));
      rows.add(footer);

      return AppleCard(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: rowWidth,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows),
          ),
        ),
      );
    });
  }
}
