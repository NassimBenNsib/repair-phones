import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/apple/apple_button.dart';
import '../../shared/widgets/apple/apple_scaffold.dart';
import '../../shared/widgets/apple/apple_search_field.dart';
import '../../shared/widgets/apple/apple_sheet.dart';
import '../../shared/widgets/apple/apple_text_field.dart';
import '../design/apple_tokens.dart';
import 'taxonomy_controller.dart';
import 'taxonomy_node.dart';
import 'taxonomy_picker.dart';

/// Configuration d'une taxonomie pour l'écran/le sélecteur génériques.
class TaxonomyConfig {
  const TaxonomyConfig({
    required this.title,
    required this.provider,
    required this.icons,
    required this.colors,
    required this.countOf,
  });

  final String title;
  final TaxonomyProvider provider;
  final Map<String, IconData> icons;
  final List<int> colors;

  /// Nombre d'entités (produits/prestations) dont la catégorie est dans [ids].
  final int Function(WidgetRef ref, Set<String> ids) countOf;
}

/// Écran de gestion arborescente d'une taxonomie (profondeur illimitée,
/// repli/dépli, code, description, actif, déplacement, fusion).
class TaxonomyTreeScreen extends ConsumerStatefulWidget {
  const TaxonomyTreeScreen({super.key, required this.config});
  final TaxonomyConfig config;

  @override
  ConsumerState<TaxonomyTreeScreen> createState() => _TaxonomyTreeScreenState();
}

class _TaxonomyTreeScreenState extends ConsumerState<TaxonomyTreeScreen> {
  final Set<String> _collapsed = {};
  bool _showArchived = false;
  String _query = '';

  TaxonomyConfig get _cfg => widget.config;

  int _rollup(String id) {
    final ctrl = ref.read(_cfg.provider.notifier);
    return _cfg.countOf(ref, {id, ...ctrl.descendantIds(id)});
  }

  bool _visible(TaxonomyNode n) => n.active || _showArchived;

  bool _matches(TaxonomyNode n, String q) =>
      n.name.toLowerCase().contains(q) ||
      (n.code ?? '').toLowerCase().contains(q);

  /// Replie/déplie tout : si des nœuds sont dépliés, on replie tout, sinon on
  /// déplie tout.
  void _toggleAll(List<TaxonomyNode> nodes) {
    final parents = {
      for (final n in nodes)
        if (nodes.any((c) => c.parentId == n.id)) n.id
    };
    setState(() {
      if (_collapsed.length >= parents.length) {
        _collapsed.clear(); // tout déplier
      } else {
        _collapsed
          ..clear()
          ..addAll(parents); // tout replier
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final nodes = ref.watch(_cfg.provider);
    final q = _query.trim().toLowerCase();
    final ctrl = ref.read(_cfg.provider.notifier);

    final byParent = <String?, List<TaxonomyNode>>{};
    for (final n in nodes) {
      byParent.putIfAbsent(n.parentId, () => []).add(n);
    }
    for (final list in byParent.values) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }

    final rows = <Widget>[];
    if (q.isEmpty) {
      // Arbre normal (repli/dépli).
      void walk(String? parentId, int depth) {
        for (final n in byParent[parentId] ?? const <TaxonomyNode>[]) {
          if (!_visible(n)) continue;
          final children = byParent[n.id] ?? const <TaxonomyNode>[];
          final hasChildren = children.any(_visible);
          final collapsed = _collapsed.contains(n.id);
          rows.add(_TreeRow(
            node: n,
            depth: depth,
            subtitle: n.description,
            icon: _cfg.icons[n.iconKey] ?? Icons.folder_outlined,
            count: _rollup(n.id),
            hasChildren: hasChildren,
            collapsed: collapsed,
            onToggle: hasChildren
                ? () => setState(() => collapsed
                    ? _collapsed.remove(n.id)
                    : _collapsed.add(n.id))
                : null,
            onTap: () => _openForm(node: n),
            onAddChild: () => _openForm(parentId: n.id),
          ));
          if (hasChildren && !collapsed) walk(n.id, depth + 1);
        }
      }

      walk(null, 0);
    } else {
      // Recherche : liste plate des correspondances, avec le chemin complet.
      for (final n in nodes) {
        if (!_visible(n) || !_matches(n, q)) continue;
        rows.add(_TreeRow(
          node: n,
          depth: 0,
          subtitle: ctrl.path(n.id),
          icon: _cfg.icons[n.iconKey] ?? Icons.folder_outlined,
          count: _rollup(n.id),
          hasChildren: false,
          collapsed: false,
          onToggle: null,
          onTap: () => _openForm(node: n),
          onAddChild: () => _openForm(parentId: n.id),
        ));
      }
    }

    return AppleScaffold(
      title: _cfg.title,
      actions: [
        IconButton(
            onPressed: () => _toggleAll(nodes),
            icon: Icon(
                _collapsed.isEmpty ? Icons.unfold_less : Icons.unfold_more,
                color: colors.secondaryLabel),
            tooltip: _collapsed.isEmpty
                ? l.taxonomyCollapseAll
                : l.taxonomyExpandAll),
        IconButton(
            onPressed: () => setState(() => _showArchived = !_showArchived),
            icon: Icon(
                _showArchived ? Icons.visibility : Icons.visibility_off,
                color: _showArchived
                    ? context.accentColor
                    : colors.secondaryLabel),
            tooltip: l.taxonomyShowArchived),
        IconButton(
            onPressed: () => _openForm(),
            icon: Icon(Icons.add, color: context.accentColor),
            tooltip: l.categoryNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.taxonomySearch,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        SliverList.list(children: [
          const SizedBox(height: 4),
          ...rows,
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(q.isEmpty ? l.taxonomyEmpty : l.listNoResults,
                  textAlign: TextAlign.center,
                  style: AppleTypography.subheadline
                      .copyWith(color: colors.secondaryLabel)),
            ),
          const SizedBox(height: 24),
        ]),
      ],
    );
  }

  Future<void> _openForm({TaxonomyNode? node, String? parentId}) {
    final l = AppLocalizations.of(context);
    return showAppleSheet<void>(
      context: context,
      title: node != null
          ? node.name
          : (parentId == null ? l.categoryNew : l.categorySubNew),
      builder: (_) => _NodeForm(config: _cfg, initial: node, parentId: parentId),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.node,
    required this.depth,
    required this.icon,
    required this.count,
    required this.hasChildren,
    required this.collapsed,
    required this.onToggle,
    required this.onTap,
    required this.onAddChild,
    this.subtitle,
  });

  final TaxonomyNode node;
  final int depth;
  final IconData icon;
  final int count;
  final bool hasChildren;
  final bool collapsed;
  final VoidCallback? onToggle;
  final VoidCallback onTap;
  final VoidCallback onAddChild;

  /// Ligne secondaire : description (arbre) ou chemin complet (recherche).
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final dim = !node.active;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.0 + depth * 18, 8, 8, 8),
          child: Row(children: [
            SizedBox(
              width: 24,
              child: hasChildren
                  ? GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                          collapsed ? Icons.chevron_right : Icons.expand_more,
                          size: 20,
                          color: colors.secondaryLabel))
                  : null,
            ),
            Opacity(
              opacity: dim ? 0.4 : 1,
              child: Container(
                width: 30,
                height: 30,
                decoration: ShapeDecoration(
                  color: node.color.withValues(alpha: 0.16),
                  shape: AppleRadii.shape(AppleRadii.sm),
                ),
                child: Icon(icon, size: 17, color: node.color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(node.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppleTypography.body.copyWith(
                              color:
                                  dim ? colors.secondaryLabel : colors.label)),
                    ),
                    if (node.code != null && node.code!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(node.code!,
                          style: AppleTypography.caption1
                              .copyWith(color: colors.tertiaryLabel)),
                    ],
                  ]),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            if (count > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('$count',
                    style: AppleTypography.subheadline
                        .copyWith(color: colors.secondaryLabel)),
              ),
            IconButton(
              onPressed: onAddChild,
              icon: Icon(Icons.add, size: 20, color: context.accentColor),
              tooltip: AppLocalizations.of(context).categoryAddSub,
              visualDensity: VisualDensity.compact,
            ),
          ]),
        ),
      ),
    );
  }
}

/// Formulaire d'un nœud : nom, code, description, icône, couleur, actif, parent
/// (déplacement) ; + sous-catégorie, fusion, déplacement des éléments, suppression.
class _NodeForm extends ConsumerStatefulWidget {
  const _NodeForm({required this.config, this.initial, this.parentId});
  final TaxonomyConfig config;
  final TaxonomyNode? initial;
  final String? parentId;

  @override
  ConsumerState<_NodeForm> createState() => _NodeFormState();
}

class _NodeFormState extends ConsumerState<_NodeForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _code = TextEditingController(text: widget.initial?.code ?? '');
  late final _desc =
      TextEditingController(text: widget.initial?.description ?? '');
  late String _iconKey = widget.initial?.iconKey ?? 'other';
  late int _colorHex = widget.initial?.colorHex ?? widget.config.colors.first;
  late bool _active = widget.initial?.active ?? true;
  late String? _parentId = widget.initial?.parentId ?? widget.parentId;
  String? _codeError;

  TaxonomyController get _ctrl => ref.read(widget.config.provider.notifier);

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _desc.dispose();
    super.dispose();
  }

  Set<String> get _affected {
    final id = widget.initial!.id;
    return {id, ..._ctrl.descendantIds(id)};
  }

  bool get _hasItems =>
      widget.initial != null &&
      widget.config.countOf(ref, _affected) > 0;

  String? _clean(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _save() {
    final code = _code.text.trim();
    if (code.isNotEmpty &&
        !_ctrl.isCodeUnique(code, exceptId: widget.initial?.id)) {
      setState(() => _codeError = AppLocalizations.of(context).taxonomyCodeTaken);
      return;
    }
    final init = widget.initial;
    if (init == null) {
      final siblings = ref
          .read(widget.config.provider)
          .where((n) => n.parentId == _parentId);
      _ctrl.add(TaxonomyNode(
        id: const Uuid().v4(),
        name: _name.text.trim(),
        parentId: _parentId,
        iconKey: _iconKey,
        colorHex: _colorHex,
        code: _clean(_code),
        description: _clean(_desc),
        order: siblings.isEmpty
            ? 0
            : siblings.map((n) => n.order).reduce((a, b) => a > b ? a : b) + 1,
      ));
    } else {
      _ctrl.update(init.copyWith(
        name: _name.text.trim(),
        iconKey: _iconKey,
        colorHex: _colorHex,
        code: _clean(_code),
        clearCode: _clean(_code) == null,
        description: _clean(_desc),
        clearDescription: _clean(_desc) == null,
        active: _active,
      ));
      // Déplacement éventuel du parent.
      if (_parentId != init.parentId) _ctrl.move(init.id, _parentId);
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickParent() async {
    final id = widget.initial?.id;
    final exclude = id == null ? <String>{} : {id, ..._ctrl.descendantIds(id)};
    final picked = await showTaxonomyPicker(
      context,
      provider: widget.config.provider,
      icons: widget.config.icons,
      selectedId: _parentId,
      exclude: exclude,
      includeRoot: true,
      title: AppLocalizations.of(context).taxonomyParent,
    );
    if (picked == null) return;
    setState(() => _parentId = picked == kTaxonomyRoot ? null : picked);
  }

  Future<String?> _pickOther(String title) {
    final id = widget.initial!.id;
    return showTaxonomyPicker(
      context,
      provider: widget.config.provider,
      icons: widget.config.icons,
      selectedId: null,
      exclude: {id, ..._ctrl.descendantIds(id)},
      title: title,
    );
  }

  Future<void> _reassignItems() async {
    final l = AppLocalizations.of(context);
    final target = await _pickOther(l.taxonomyReassign);
    if (target == null || target == kTaxonomyRoot) return;
    for (final id in _affected) {
      _ctrl.reassignEntities(id, target);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _mergeInto() async {
    final l = AppLocalizations.of(context);
    final target = await _pickOther(l.taxonomyMergeInto);
    if (target == null || target == kTaxonomyRoot) return;
    _ctrl.merge(widget.initial!.id, target);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final init = widget.initial!;
    final l = AppLocalizations.of(context);
    if (_hasItems) {
      final target = await _pickOther(l.taxonomyReassign);
      if (target == null || target == kTaxonomyRoot) return;
      for (final id in _affected) {
        _ctrl.reassignEntities(id, target);
      }
    } else {
      final ok = await _confirm();
      if (!ok) return;
    }
    for (final c in _ctrl.descendantIds(init.id)) {
      _ctrl.remove(c);
    }
    _ctrl.remove(init.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool> _confirm() async {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.secondaryGroupedBackground,
        content: Text(l.categoryDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.commonCancel)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.categoryDelete)),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final editing = widget.initial != null;

    Widget label(String t) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(t,
              style: AppleTypography.footnote
                  .copyWith(color: colors.secondaryLabel)),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleTextField(controller: _name, label: l.fieldName),
          const SizedBox(height: 12),
          AppleTextField(controller: _code, label: l.taxonomyCode),
          if (_codeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: label(_codeError!),
            ),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _desc,
              label: l.taxonomyDescription,
              minLines: 1,
              maxLines: 3),
          const SizedBox(height: 16),
          label(l.taxonomyParent),
          const SizedBox(height: 8),
          _ParentTile(
            provider: widget.config.provider,
            icons: widget.config.icons,
            parentId: _parentId,
            onTap: _pickParent,
          ),
          const SizedBox(height: 16),
          label(l.categoryIcon),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final entry in widget.config.icons.entries)
              GestureDetector(
                onTap: () => setState(() => _iconKey = entry.key),
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: _iconKey == entry.key
                        ? Color(_colorHex).withValues(alpha: 0.18)
                        : colors.fill,
                    shape: AppleRadii.shape(AppleRadii.md,
                        side: _iconKey == entry.key
                            ? BorderSide(color: Color(_colorHex), width: 2)
                            : BorderSide.none),
                  ),
                  child: Icon(entry.value,
                      size: 20,
                      color: _iconKey == entry.key
                          ? Color(_colorHex)
                          : colors.secondaryLabel),
                ),
              ),
          ]),
          const SizedBox(height: 16),
          label(l.categoryColor),
          const SizedBox(height: 8),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final hex in widget.config.colors)
              GestureDetector(
                onTap: () => setState(() => _colorHex = hex),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Color(hex),
                    shape: BoxShape.circle,
                    border: _colorHex == hex
                        ? Border.all(color: colors.label, width: 2)
                        : null,
                  ),
                  child: _colorHex == hex
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
          ]),
          if (editing) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Text(l.staffActive,
                      style: AppleTypography.body.copyWith(color: colors.label))),
              Switch.adaptive(
                  value: _active,
                  onChanged: (v) => setState(() => _active = v)),
            ]),
          ],
          const SizedBox(height: 16),
          AppleButton(
            label: l.commonSave,
            icon: Icons.check,
            expand: true,
            onPressed: _name.text.trim().isEmpty ? null : _save,
          ),
          if (editing) ...[
            const SizedBox(height: 8),
            AppleButton(
              label: l.taxonomyMergeInto,
              icon: Icons.merge_type,
              style: AppleButtonStyle.gray,
              expand: true,
              onPressed: _mergeInto,
            ),
            if (_hasItems) ...[
              const SizedBox(height: 8),
              AppleButton(
                label: l.taxonomyMoveItems,
                icon: Icons.drive_file_move_outline,
                style: AppleButtonStyle.gray,
                expand: true,
                onPressed: _reassignItems,
              ),
            ],
            const SizedBox(height: 8),
            AppleButton(
              label: l.categoryDelete,
              icon: Icons.delete_outline,
              style: AppleButtonStyle.destructive,
              expand: true,
              onPressed: _delete,
            ),
          ],
        ],
      ),
    );
  }
}

class _ParentTile extends ConsumerWidget {
  const _ParentTile(
      {required this.provider,
      required this.icons,
      required this.parentId,
      required this.onTap});

  final TaxonomyProvider provider;
  final Map<String, IconData> icons;
  final String? parentId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final ctrl = ref.watch(provider.notifier);
    ref.watch(provider);
    final path = parentId == null ? l.taxonomyRoot : ctrl.path(parentId);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ShapeDecoration(
          color: colors.fill,
          shape: AppleRadii.shape(AppleRadii.md),
        ),
        child: Row(children: [
          Expanded(
            child: Text(path,
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
