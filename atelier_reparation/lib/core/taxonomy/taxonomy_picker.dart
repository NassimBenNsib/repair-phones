import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/apple/apple_sheet.dart';
import '../design/apple_tokens.dart';
import 'taxonomy_controller.dart';
import 'taxonomy_node.dart';

/// Valeur renvoyée par le sélecteur pour « racine » (parent nul).
const String kTaxonomyRoot = '__root__';

typedef TaxonomyProvider
    = NotifierProvider<TaxonomyController, List<TaxonomyNode>>;

/// Sélecteur hiérarchique (arbre repliable, profondeur illimitée). Renvoie l'id
/// choisi, [kTaxonomyRoot] si l'option racine est retenue, ou `null` si annulé.
Future<String?> showTaxonomyPicker(
  BuildContext context, {
  required TaxonomyProvider provider,
  required Map<String, IconData> icons,
  String? selectedId,
  Set<String> exclude = const {},
  bool includeRoot = false,
  String? title,
}) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<String>(
    context: context,
    title: title ?? l.categorySelect,
    builder: (_) => _TaxonomyPicker(
      provider: provider,
      icons: icons,
      selectedId: selectedId,
      exclude: exclude,
      includeRoot: includeRoot,
    ),
  );
}

class _TaxonomyPicker extends ConsumerStatefulWidget {
  const _TaxonomyPicker({
    required this.provider,
    required this.icons,
    required this.selectedId,
    required this.exclude,
    required this.includeRoot,
  });

  final TaxonomyProvider provider;
  final Map<String, IconData> icons;
  final String? selectedId;
  final Set<String> exclude;
  final bool includeRoot;

  @override
  ConsumerState<_TaxonomyPicker> createState() => _TaxonomyPickerState();
}

class _TaxonomyPickerState extends ConsumerState<_TaxonomyPicker> {
  final Set<String> _collapsed = {};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final nodes = ref.watch(widget.provider);
    final byParent = <String?, List<TaxonomyNode>>{};
    for (final n in nodes) {
      if (!n.active) continue;
      byParent.putIfAbsent(n.parentId, () => []).add(n);
    }
    for (final list in byParent.values) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }

    final rows = <Widget>[];

    void walk(String? parentId, int depth) {
      for (final n in byParent[parentId] ?? const <TaxonomyNode>[]) {
        if (widget.exclude.contains(n.id)) continue;
        final children = byParent[n.id] ?? const <TaxonomyNode>[];
        final hasChildren = children.isNotEmpty;
        final collapsed = _collapsed.contains(n.id);
        rows.add(_row(
          depth: depth,
          icon: widget.icons[n.iconKey] ?? Icons.folder_outlined,
          color: n.color,
          label: n.name,
          selected: n.id == widget.selectedId,
          hasChildren: hasChildren,
          collapsed: collapsed,
          onToggle: hasChildren
              ? () => setState(() => collapsed
                  ? _collapsed.remove(n.id)
                  : _collapsed.add(n.id))
              : null,
          onTap: () => Navigator.of(context).pop(n.id),
        ));
        if (hasChildren && !collapsed) walk(n.id, depth + 1);
      }
    }

    if (widget.includeRoot) {
      rows.add(_row(
        depth: 0,
        icon: Icons.north_west,
        color: colors.secondaryLabel,
        label: l.taxonomyRoot,
        selected: false,
        hasChildren: false,
        collapsed: false,
        onToggle: null,
        onTap: () => Navigator.of(context).pop(kTaxonomyRoot),
      ));
    }
    walk(null, 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  Widget _row({
    required int depth,
    required IconData icon,
    required Color color,
    required String label,
    required bool selected,
    required bool hasChildren,
    required bool collapsed,
    required VoidCallback? onToggle,
    required VoidCallback onTap,
  }) {
    final colors = context.appleColors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.0 + depth * 18, 10, 12, 10),
          child: Row(children: [
            SizedBox(
              width: 24,
              child: hasChildren
                  ? GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                          collapsed
                              ? Icons.chevron_right
                              : Icons.expand_more,
                          size: 20,
                          color: colors.secondaryLabel),
                    )
                  : null,
            ),
            Container(
              width: 28,
              height: 28,
              decoration: ShapeDecoration(
                color: color.withValues(alpha: 0.16),
                shape: AppleRadii.shape(AppleRadii.sm),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: AppleTypography.body.copyWith(color: colors.label)),
            ),
            if (selected) Icon(Icons.check, color: context.accentColor, size: 20),
          ]),
        ),
      ),
    );
  }
}

/// Champ de formulaire : affiche le chemin de la catégorie choisie et ouvre le
/// sélecteur hiérarchique au tap.
class TaxonomySelectField extends ConsumerWidget {
  const TaxonomySelectField({
    super.key,
    required this.provider,
    required this.icons,
    required this.selectedId,
    required this.onChanged,
  });

  final TaxonomyProvider provider;
  final Map<String, IconData> icons;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appleColors;
    final ctrl = ref.watch(provider.notifier);
    ref.watch(provider);
    final node = ctrl.byId(selectedId);
    final path = ctrl.path(selectedId);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final picked = await showTaxonomyPicker(context,
            provider: provider, icons: icons, selectedId: selectedId);
        if (picked != null && picked != kTaxonomyRoot) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ShapeDecoration(
          color: colors.fill,
          shape: AppleRadii.shape(AppleRadii.md),
        ),
        child: Row(children: [
          Icon(icons[node?.iconKey] ?? Icons.folder_outlined,
              size: 20, color: node?.color ?? colors.secondaryLabel),
          const SizedBox(width: 10),
          Expanded(
            child: Text(path.isEmpty ? '—' : path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppleTypography.body.copyWith(color: colors.label)),
          ),
          Icon(context.chevronForward, size: 18, color: colors.tertiaryLabel),
        ]),
      ),
    );
  }
}
