import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/format/app_formats.dart';
import '../../../core/settings/layout_prefs.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/taxonomy/taxonomy_controller.dart';
import '../../../core/taxonomy/taxonomy_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/directory_views.dart';
import '../../../shared/widgets/apple/list_empty_state.dart';
import '../application/categories_controller.dart';
import '../application/service_catalog_controller.dart';
import '../domain/service_category_node.dart';
import '../domain/service_template.dart';
import 'categories_screen.dart';

/// Catalogue des prestations : recherche, catégories (taxonomie), activation, et
/// affichage liste / grille / tableau (réglage partagé).
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  static const String routeName = 'services';
  static const String routePath = '/services';

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _query = '';
  String? _categoryId;
  bool? _active; // null = tous, true = actifs, false = inactifs

  ClientsListStyle get _style =>
      ref.watch(settingsControllerProvider.select((s) => s.clientsListStyle));

  Widget _toggle() => DirectoryViewToggle(
        style: _style,
        onChanged: (v) =>
            ref.read(settingsControllerProvider.notifier).setClientsListStyle(v),
      );

  /// Ensemble d'ids couvert par le filtre : un nœud inclut **tous** ses
  /// descendants (rollup à profondeur illimitée).
  Set<String>? _catIds(TaxonomyController catCtrl) {
    if (_categoryId == null) return null;
    return {_categoryId!, ...catCtrl.descendantIds(_categoryId!)};
  }

  List<ServiceTemplate> _filter(List<ServiceTemplate> list, Set<String>? catIds) {
    final q = _query.trim().toLowerCase();
    return list.where((s) {
      final matchQ = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q);
      final matchCat = catIds == null || catIds.contains(s.categoryId);
      final matchActive = _active == null || s.active == _active;
      return matchQ && matchCat && matchActive;
    }).toList();
  }

  Widget _segmentBar(List<ServiceCategoryNode> cats) {
    final l = AppLocalizations.of(context);
    final byId = {for (final c in cats) c.id: c};
    final top = cats.where((c) => c.parentId == null && c.active).toList();
    // Catégorie de premier niveau active (via sélection directe ou d'une sous-cat).
    final selNode = _categoryId == null ? null : byId[_categoryId];
    final activeTop = selNode?.parentId ?? selNode?.id;
    final subs = activeTop == null
        ? const <ServiceCategoryNode>[]
        : cats.where((c) => c.parentId == activeTop && c.active).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          AppleChip(
              label: l.repairsFilterAll,
              selected: _categoryId == null && _active == null,
              onTap: () => setState(() {
                    _categoryId = null;
                    _active = null;
                  })),
          for (final c in top)
            AppleChip(
                label: c.name,
                selected: activeTop == c.id,
                onTap: () => setState(
                    () => _categoryId = activeTop == c.id ? null : c.id)),
          AppleChip(
              label: l.staffActive,
              selected: _active == true,
              onTap: () =>
                  setState(() => _active = _active == true ? null : true)),
          AppleChip(
              label: l.staffInactive,
              selected: _active == false,
              onTap: () =>
                  setState(() => _active = _active == false ? null : false)),
        ]),
      ),
      // Drill-down : sous-catégories de la catégorie active.
      if (subs.isNotEmpty)
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            AppleChip(
                label: l.repairsFilterAll,
                selected: _categoryId == activeTop,
                onTap: () => setState(() => _categoryId = activeTop)),
            for (final s in subs)
              AppleChip(
                  label: s.name,
                  selected: _categoryId == s.id,
                  onTap: () => setState(() => _categoryId = s.id)),
          ]),
        ),
    ]);
  }

  List<DirColumn<ServiceTemplate>> _columns(
          AppLocalizations l, TaxonomyController cats) =>
      [
        DirColumn(
            label: l.fieldName,
            width: 220,
            leading: true,
            value: (s) => s.name,
            sortKey: (s) => s.name.toLowerCase()),
        DirColumn(
            label: l.serviceCategoryHeader,
            width: 150,
            value: (s) => cats.path(s.categoryId),
            sortKey: (s) => cats.nameOf(s.categoryId).toLowerCase()),
        DirColumn(
            label: l.serviceDurationLabel,
            width: 100,
            value: (s) =>
                s.durationMinutes == null ? '—' : '${s.durationMinutes} min',
            sortKey: (s) => s.durationMinutes ?? 0),
        DirColumn(
            label: l.priceLabel,
            width: 110,
            value: (s) => AppFormats.money(s.price),
            sortKey: (s) => s.price),
        DirColumn(
            label: l.accountingVat,
            width: 90,
            value: (s) => s.vatRate == null
                ? '—'
                : '${(s.vatRate! * 100).toStringAsFixed(0)} %'),
        DirColumn(
            label: l.staffActive,
            width: 90,
            value: (s) => s.active ? l.staffActive : l.staffInactive,
            sortKey: (s) => s.active ? 0 : 1,
            color: (s, c) => s.active ? c.green : c.secondaryLabel),
      ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(serviceCatalogProvider);
    final cats = ref.watch(categoriesProvider);
    final catCtrl = ref.read(categoriesProvider.notifier);
    final byId = {for (final c in cats) c.id: c};
    final results = _filter(all, _catIds(catCtrl));
    final style = _style;

    return AppleScaffold(
      title: l.navServices,
      actions: [
        _toggle(),
        IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CategoriesScreen())),
            icon: Icon(Icons.category_outlined, color: context.accentColor),
            tooltip: l.navCategories),
        IconButton(
            onPressed: () => _showForm(null),
            icon: Icon(Icons.add, color: context.accentColor),
            tooltip: l.serviceNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.servicesSearch,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _segmentBar(cats)),
        if (results.isEmpty)
          SliverToBoxAdapter(
            child: ListEmptyState(
              icon: all.isEmpty ? Icons.handyman : Icons.search_off,
              title: all.isEmpty ? l.servicesEmpty : l.listNoResults,
              subtitle: all.isEmpty
                  ? l.servicesEmptySubtitle
                  : l.listNoResultsSubtitle,
            ),
          )
        else if (style == ClientsListStyle.grid)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 132,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => DirectoryCard(
                  name: results[i].name,
                  title: results[i].name,
                  subtitle: AppFormats.money(results[i].price),
                  badge: byId[results[i].categoryId]?.name,
                  badgeColor: byId[results[i].categoryId]?.color,
                  onTap: () => _showDetails(results[i]),
                ),
                childCount: results.length,
              ),
            ),
          )
        else if (style == ClientsListStyle.table)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: DirectoryTable<ServiceTemplate>(
                items: results,
                columns: _columns(l, catCtrl),
                avatarName: (s) => s.name,
                onTap: _showDetails,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(
                children: [
                  for (final s in results)
                    _ServiceRow(
                        service: s,
                        node: byId[s.categoryId],
                        onTap: () => _showDetails(s)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showDetails(ServiceTemplate s) async {
    await showAppleSheet<void>(
      context: context,
      title: s.name,
      builder: (context) {
        final l = AppLocalizations.of(context);
        final colors = context.appleColors;
        final cats = ref.read(categoriesProvider.notifier);
        Widget kv(String k, String v) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(
                    width: 130,
                    child: Text(k,
                        style: AppleTypography.subheadline
                            .copyWith(color: colors.secondaryLabel))),
                Expanded(
                    child: Text(v,
                        style: AppleTypography.body
                            .copyWith(color: colors.label))),
              ]),
            );
        final live = ref
            .watch(serviceCatalogProvider)
            .firstWhere((x) => x.id == s.id, orElse: () => s);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (live.description.isNotEmpty) ...[
                Text(live.description,
                    style: AppleTypography.subheadline
                        .copyWith(color: colors.secondaryLabel)),
                const SizedBox(height: 12),
              ],
              kv(l.serviceCategoryHeader, cats.path(live.categoryId)),
              kv(l.priceLabel, AppFormats.money(live.price)),
              if (live.durationMinutes != null)
                kv(l.serviceDurationLabel, '${live.durationMinutes} min'),
              if (live.vatRate != null)
                kv(l.accountingVat,
                    '${(live.vatRate! * 100).toStringAsFixed(0)} %'),
              if (live.margin != null)
                kv(l.serviceMargin, AppFormats.money(live.margin!)),
              const SizedBox(height: 16),
              AppleButton(
                label: l.actionEdit,
                icon: Icons.edit_outlined,
                style: AppleButtonStyle.tinted,
                expand: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showForm(live);
                },
              ),
              const SizedBox(height: 8),
              AppleButton(
                label: live.active ? l.staffInactive : l.staffActive,
                icon: live.active ? Icons.block : Icons.check_circle_outline,
                style: AppleButtonStyle.gray,
                expand: true,
                onPressed: () => ref
                    .read(serviceCatalogProvider.notifier)
                    .toggleActive(live.id),
              ),
              const SizedBox(height: 8),
              AppleButton(
                label: l.serviceDuplicate,
                icon: Icons.copy_outlined,
                style: AppleButtonStyle.gray,
                expand: true,
                onPressed: () {
                  ref.read(serviceCatalogProvider.notifier).add(
                        name: '${live.name} ${l.serviceCopySuffix}',
                        description: live.description,
                        price: live.price,
                        categoryId: live.categoryId,
                        durationMinutes: live.durationMinutes,
                        vatRate: live.vatRate,
                        cost: live.cost,
                      );
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              AppleButton(
                label: l.actionDelete,
                icon: Icons.delete_outline,
                style: AppleButtonStyle.destructive,
                expand: true,
                onPressed: () async {
                  final ok = await _confirmDelete();
                  if (!ok) return;
                  ref.read(serviceCatalogProvider.notifier).remove(live.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete() async {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.secondaryGroupedBackground,
        content: Text(l.serviceDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.commonCancel)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.serviceDelete)),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _showForm(ServiceTemplate? initial) {
    final l = AppLocalizations.of(context);
    return showAppleSheet<void>(
      context: context,
      title: initial == null ? l.serviceNew : l.serviceEdit,
      builder: (_) => _ServiceFormSheet(initial: initial),
    );
  }
}

/// Formulaire de création / édition d'une prestation.
class _ServiceFormSheet extends ConsumerStatefulWidget {
  const _ServiceFormSheet({this.initial});
  final ServiceTemplate? initial;

  @override
  ConsumerState<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<_ServiceFormSheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _desc =
      TextEditingController(text: widget.initial?.description ?? '');
  late final _price = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.price.toStringAsFixed(0));
  late final _duration = TextEditingController(
      text: widget.initial?.durationMinutes?.toString() ?? '');
  late final _vat = TextEditingController(
      text: widget.initial?.vatRate == null
          ? ''
          : (widget.initial!.vatRate! * 100).toStringAsFixed(0));
  late final _cost = TextEditingController(
      text: widget.initial?.cost?.toStringAsFixed(0) ?? '');
  late String _categoryId = widget.initial?.categoryId ?? 'other';
  late bool _active = widget.initial?.active ?? true;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _price.addListener(() => setState(() {}));
    _cost.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _price, _duration, _vat, _cost]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) => c.text.trim().isEmpty
      ? null
      : double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool get _valid => _name.text.trim().isNotEmpty && (_num(_price) ?? -1) >= 0;

  void _save() {
    final ctrl = ref.read(serviceCatalogProvider.notifier);
    final name = _name.text.trim();
    final price = _num(_price) ?? 0;
    final desc = _desc.text.trim();
    final duration = int.tryParse(_duration.text.trim());
    final vat = _num(_vat);
    final cost = _num(_cost);
    final init = widget.initial;
    if (init == null) {
      ctrl.add(
        name: name,
        description: desc,
        price: price,
        categoryId: _categoryId,
        durationMinutes: duration,
        vatRate: vat == null ? null : vat / 100,
        cost: cost,
      );
    } else {
      ctrl.update(init.copyWith(
        name: name,
        description: desc,
        price: price,
        categoryId: _categoryId,
        durationMinutes: duration,
        clearDuration: duration == null,
        vatRate: vat == null ? null : vat / 100,
        clearVat: vat == null,
        cost: cost,
        clearCost: cost == null,
        active: _active,
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final margin = (_num(_price) != null && _num(_cost) != null)
        ? _num(_price)! - _num(_cost)!
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleTextField(controller: _name, label: l.fieldName),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _desc,
              label: l.serviceDescription,
              minLines: 1,
              maxLines: 3),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l.serviceCategoryHeader,
                style: AppleTypography.footnote
                    .copyWith(color: colors.secondaryLabel)),
          ),
          const SizedBox(height: 8),
          TaxonomySelectField(
            provider: categoriesProvider,
            icons: kServiceCategoryIcons,
            selectedId: _categoryId,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: AppleTextField(
                  controller: _price,
                  label: l.priceLabel,
                  suffix: AppFormats.symbol,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppleTextField(
                  controller: _duration,
                  label: l.serviceDurationLabel,
                  suffix: 'min',
                  keyboardType: TextInputType.number),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: AppleTextField(
                  controller: _vat,
                  label: l.accountingVat,
                  suffix: '%',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppleTextField(
                  controller: _cost,
                  label: l.serviceCost,
                  suffix: AppFormats.symbol,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ),
          ]),
          if (margin != null) ...[
            const SizedBox(height: 10),
            Text('${l.serviceMargin} : ${AppFormats.money(margin)}',
                style: AppleTypography.footnote.copyWith(
                    color: margin >= 0 ? colors.green : colors.red)),
          ],
          if (widget.initial != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Text(l.staffActive,
                    style:
                        AppleTypography.body.copyWith(color: colors.label)),
              ),
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
            onPressed: _valid ? _save : null,
          ),
        ],
      ),
    );
  }
}


class _ServiceRow extends StatelessWidget {
  const _ServiceRow(
      {required this.service, required this.node, required this.onTap});

  final ServiceTemplate service;
  final ServiceCategoryNode? node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final s = service;
    final tint = node?.color ?? colors.secondaryLabel;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: ShapeDecoration(
                color: tint.withValues(alpha: 0.16),
                shape: AppleRadii.shape(AppleRadii.sm),
              ),
              child: Icon(node?.icon ?? Icons.handyman, size: 18, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.body.copyWith(color: colors.label)),
                  if (s.description.isNotEmpty)
                    Text(s.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!s.active)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: AppleBadge(
                    label: l.staffInactive, color: colors.secondaryLabel),
              ),
            Text(AppFormats.money(s.price),
                style: AppleTypography.subheadline.copyWith(
                    color: colors.label, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(context.chevronForward, size: 20, color: colors.tertiaryLabel),
          ]),
        ),
      ),
    );
  }
}
