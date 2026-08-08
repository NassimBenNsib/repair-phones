import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/layout_prefs.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/directory_views.dart';
import '../../../shared/widgets/apple/list_empty_state.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../catalog/application/product_categories_controller.dart';
import '../application/suppliers_controller.dart';
import '../domain/supplier.dart';
import 'supplier_detail.dart';

/// Répertoire des fournisseurs : recherche, liste et vue maître/détail.
class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  static const String routeName = 'suppliers';
  static const String routePath = '/suppliers';

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _query = '';
  String? _selectedId;
  SupplierType? _type; // null = tous
  String? _catFilter; // catégorie racine fournie ; null = toutes

  /// Catégories racine des produits fournis par ce fournisseur.
  Set<String> _suppliedRoots(String supplierId) {
    final cats = ref.read(productCategoriesProvider.notifier);
    final out = <String>{};
    for (final p in ref.read(catalogProvider)) {
      if (!p.supplierIds.contains(supplierId)) continue;
      final chain = cats.pathNodes(p.categoryId);
      if (chain.isNotEmpty) out.add(chain.first.id);
    }
    return out;
  }

  List<Supplier> _filter(List<Supplier> list) {
    final q = _query.trim().toLowerCase();
    return list.where((s) {
      final matchQ = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          (s.contactName ?? '').toLowerCase().contains(q) ||
          s.phone.contains(q);
      final matchType = _type == null || s.type == _type;
      final matchCat =
          _catFilter == null || _suppliedRoots(s.id).contains(_catFilter);
      return matchQ && matchType && matchCat;
    }).toList();
  }

  Future<void> _add() async {
    final created = await _showAddSupplierSheet(context);
    if (created != null) ref.read(suppliersProvider.notifier).add(created);
  }

  /// Barre de segments : type de fournisseur + catégorie fournie.
  Widget _segmentBar() {
    final l = AppLocalizations.of(context);
    final topCats = ref
        .watch(productCategoriesProvider)
        .where((c) => c.parentId == null && c.active)
        .toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          AppleChip(
              label: l.repairsFilterAll,
              selected: _type == null,
              onTap: () => setState(() => _type = null)),
          for (final t in SupplierType.values)
            AppleChip(
                label: t.label(l),
                selected: _type == t,
                onTap: () => setState(() => _type = _type == t ? null : t)),
        ]),
      ),
      // Catégorie fournie (dérivée des produits liés).
      if (topCats.isNotEmpty)
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in topCats)
              AppleChip(
                  label: c.name,
                  selected: _catFilter == c.id,
                  selectedColor: c.color,
                  onTap: () => setState(
                      () => _catFilter = _catFilter == c.id ? null : c.id)),
          ]),
        ),
    ]);
  }

  /// État vide : CTA si le répertoire est vide, sinon « aucun résultat ».
  Widget _emptyState({required bool collectionEmpty}) {
    final l = AppLocalizations.of(context);
    return collectionEmpty
        ? ListEmptyState(
            icon: Icons.local_shipping_outlined,
            title: l.supplierEmpty,
            subtitle: l.supplierEmptySubtitle,
            actionLabel: l.supplierNew,
            onAction: _add,
          )
        : ListEmptyState(
            icon: Icons.search_off,
            title: l.listNoResults,
            subtitle: l.listNoResultsSubtitle,
          );
  }

  void _open(Supplier s) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: s)),
      );

  ClientsListStyle get _style =>
      ref.watch(settingsControllerProvider.select((s) => s.clientsListStyle));

  Widget _toggle() => DirectoryViewToggle(
        style: _style,
        onChanged: (v) =>
            ref.read(settingsControllerProvider.notifier).setClientsListStyle(v),
      );

  List<DirColumn<Supplier>> _columns(AppLocalizations l) => [
        DirColumn(
            label: l.supplierName,
            width: 200,
            leading: true,
            value: (s) => s.name,
            sortKey: (s) => s.name.toLowerCase()),
        DirColumn(
            label: l.fieldType,
            width: 110,
            value: (s) => s.type.label(l),
            sortKey: (s) => s.type.label(l)),
        DirColumn(
            label: l.supplierCity,
            width: 150,
            value: (s) => s.city ?? '—',
            sortKey: (s) => (s.city ?? '').toLowerCase()),
        DirColumn(
            label: l.fieldPhone,
            width: 150,
            value: (s) => s.phone.isEmpty ? '—' : s.phone),
        DirColumn(label: l.fieldEmail, width: 200, value: (s) => s.email ?? '—'),
      ];

  @override
  Widget build(BuildContext context) {
    final detailLayout =
        ref.watch(settingsControllerProvider.select((s) => s.detailLayout));
    final style = _style;
    return LayoutBuilder(
      builder: (context, c) {
        // Grille/tableau : modes pleine largeur (pas de maître/détail).
        final twoPane = style == ClientsListStyle.list &&
            detailLayout.useTwoPane(c.maxWidth);
        return twoPane ? _twoPane(context) : _singlePane(context);
      },
    );
  }

  Widget _singlePane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(suppliersProvider);
    final results = _filter(all);
    final style = _style;
    return AppleScaffold(
      title: l.navSuppliers,
      actions: [
        _toggle(),
        IconButton(
            onPressed: _add,
            icon: Icon(Icons.add, color: context.accentColor),
            tooltip: l.supplierNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.supplierSearch,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _segmentBar()),
        if (results.isEmpty)
          SliverToBoxAdapter(child: _emptyState(collectionEmpty: all.isEmpty))
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
                  subtitle: results[i].city ?? results[i].phone,
                  badge: results[i].type.label(l),
                  badgeColor: context.appleColors.secondaryLabel,
                  onTap: () => _open(results[i]),
                ),
                childCount: results.length,
              ),
            ),
          )
        else if (style == ClientsListStyle.table)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: DirectoryTable<Supplier>(
                items: results,
                columns: _columns(l),
                avatarName: (s) => s.name,
                onTap: _open,
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
                    _SupplierRow(supplier: s, onTap: () => _open(s)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _twoPane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final all = ref.watch(suppliersProvider);
    final results = _filter(all);
    final shown = all.any((s) => s.id == _selectedId) ? _selectedId : null;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.navSuppliers,
                    style: AppleTypography.title1.copyWith(color: colors.label)),
              ),
              _toggle(),
              IconButton(
                  onPressed: _add,
                  icon: Icon(Icons.add, color: context.accentColor),
                  tooltip: l.supplierNew),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: AppleSearchField(
            hintText: l.supplierSearch,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 8),
        _segmentBar(),
        Expanded(
          child: results.isEmpty
              ? _emptyState(collectionEmpty: all.isEmpty)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    AppleListSection(
                      children: [
                        for (final s in results)
                          _SupplierRow(
                            supplier: s,
                            selected: s.id == shown,
                            onTap: () => setState(() => _selectedId = s.id),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );

    return ColoredBox(
      color: colors.groupedBackground,
      child: SafeArea(
        child: shown == null
            ? list
            : Row(
                children: [
                  SizedBox(width: 380, child: list),
                  VerticalDivider(
                      width: 0.5, thickness: 0.5, color: colors.separator),
                  Expanded(
                    child: SupplierDetailView(
                      key: ValueKey(shown),
                      supplierId: shown,
                      onClose: () => setState(() => _selectedId = null),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SupplierRow extends StatelessWidget {
  const _SupplierRow(
      {required this.supplier, required this.onTap, this.selected = false});

  final Supplier supplier;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? context.accentColor.withValues(alpha: 0.10)
            : Colors.transparent,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.fill,
          highlightColor: colors.fill,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                AppleAvatar(name: supplier.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier.name,
                          style: AppleTypography.body
                              .copyWith(color: colors.label)),
                      Text(supplier.city ?? supplier.phone,
                          style: AppleTypography.footnote
                              .copyWith(color: colors.secondaryLabel)),
                    ],
                  ),
                ),
                AppleBadge(
                    label: supplier.type.label(l), color: colors.secondaryLabel),
                const SizedBox(width: 8),
                Icon(context.chevronForward,
                    size: 20, color: colors.tertiaryLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feuille de création d'un fournisseur.
Future<Supplier?> _showAddSupplierSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<Supplier>(
    context: context,
    title: l.supplierNew,
    builder: (context) => const _AddSupplierForm(),
  );
}

class _AddSupplierForm extends StatefulWidget {
  const _AddSupplierForm();

  @override
  State<_AddSupplierForm> createState() => _AddSupplierFormState();
}

class _AddSupplierFormState extends State<_AddSupplierForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  SupplierType _type = SupplierType.company;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  String? _opt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleSegmentedControl<SupplierType>(
            value: _type,
            onChanged: (t) => setState(() => _type = t),
            segments: {for (final t in SupplierType.values) t: t.label(l)},
          ),
          const SizedBox(height: 14),
          AppleTextField(controller: _name, label: l.supplierName),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _phone,
              label: l.fieldPhone,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _email,
              label: l.fieldEmail,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          AppleTextField(controller: _city, label: l.supplierCity),
          const SizedBox(height: 16),
          AppleButton(
            label: l.addLabel,
            icon: Icons.check,
            expand: true,
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(Supplier(
                      id: const Uuid().v4(),
                      type: _type,
                      name: _name.text.trim(),
                      phone: _phone.text.trim(),
                      email: _opt(_email),
                      city: _opt(_city),
                    )),
          ),
        ],
      ),
    );
  }
}
