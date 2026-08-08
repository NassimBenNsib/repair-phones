import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/format/app_formats.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_menu_button.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../clients/domain/client.dart';
import '../../clients/presentation/client_picker_sheet.dart';
import '../application/repairs_controller.dart';
import '../domain/repair.dart';
import 'repair_card.dart';
import 'repair_detail.dart';
import 'repair_filters.dart';
import 'repair_scan_screen.dart';

/// Écran des réparations : recherche, filtres avec compteurs, flux de cartes et
/// vue maître/détail sur grand écran.
class RepairsScreen extends ConsumerStatefulWidget {
  const RepairsScreen({super.key});

  static const String routeName = 'repairs';
  static const String routePath = '/repairs';

  @override
  ConsumerState<RepairsScreen> createState() => _RepairsScreenState();
}

class _RepairsScreenState extends ConsumerState<RepairsScreen> {
  String _query = '';
  RepairStatus? _filter;
  RepairFilters _filters = const RepairFilters();
  RepairSort _sort = RepairSort.recent;
  String? _selectedRef;

  List<Repair> get _filtered {
    final q = _query.trim().toLowerCase();
    final list = ref.watch(repairsProvider).where((r) {
      final matchesStatus = _filter == null || r.status == _filter;
      final matchesPriority =
          _filters.priority == null || r.priority == _filters.priority;
      final matchesDevice =
          _filters.device == null || r.kind == _filters.device;
      final matchesActive =
          !_filters.activeOnly || r.status.isActive;
      final matchesQuery = q.isEmpty ||
          r.device.toLowerCase().contains(q) ||
          r.client.toLowerCase().contains(q) ||
          r.reference.toLowerCase().contains(q);
      return matchesStatus &&
          matchesPriority &&
          matchesDevice &&
          matchesActive &&
          matchesQuery;
    }).toList()
      ..sort(_sort.compare);
    return list;
  }

  int _count(RepairStatus? s) {
    final all = ref.watch(repairsProvider);
    return s == null ? all.length : all.where((r) => r.status == s).length;
  }

  Future<void> _openFilters() async {
    final result =
        await showRepairFilterSheet(context: context, current: _filters);
    if (result != null) setState(() => _filters = result);
  }

  Widget _searchActions() => _SearchActions(
        l: AppLocalizations.of(context),
        sort: _sort,
        onSortSelected: (s) => setState(() => _sort = s),
        filterCount: _filters.activeCount,
        onFilters: _openFilters,
      );

  @override
  Widget build(BuildContext context) {
    // Mode maître/détail selon la préférence utilisateur et la largeur
    // réellement disponible (après le rail de navigation).
    final detailLayout =
        ref.watch(settingsControllerProvider.select((s) => s.detailLayout));
    return LayoutBuilder(
      builder: (context, constraints) =>
          detailLayout.useTwoPane(constraints.maxWidth)
              ? _buildTwoPane(context)
              : _buildSinglePane(context),
    );
  }

  // --- Petit / moyen écran : liste plein écran, détail poussé ---

  Widget _buildSinglePane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final results = _filtered;

    return AppleScaffold(
      title: l.repairsTitle,
      actions: [
        IconButton(
          onPressed: _scanPushed,
          icon: Icon(Icons.qr_code_scanner, color: context.accentColor),
          tooltip: l.repairScan,
        ),
        IconButton(
          onPressed: _addPushed,
          icon: Icon(Icons.add, color: context.accentColor),
          tooltip: l.repairsNew,
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.repairsSearch,
              onChanged: (v) => setState(() => _query = v),
              trailing: _searchActions(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _FilterBar(
            l: l,
            selected: _filter,
            count: _count,
            onSelect: (f) => setState(() => _filter = f),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
          sliver: results.isEmpty
              ? SliverToBoxAdapter(child: _Empty(l: l))
              : SliverList.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _animated(
                    i,
                    RepairCard(
                      repair: results[i],
                      onTap: () => _openDetail(results[i].reference),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // --- Grand écran : maître / détail ---

  Widget _buildTwoPane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final results = _filtered;
    // Résout la sélection depuis le magasin (reflète les modifications live).
    Repair? shown;
    if (_selectedRef != null) {
      for (final r in ref.watch(repairsProvider)) {
        if (r.reference == _selectedRef) {
          shown = r;
          break;
        }
      }
    }

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.repairsTitle,
                    style: AppleTypography.title1.copyWith(color: colors.label)),
              ),
              IconButton(
                onPressed: _scanSelected,
                icon: Icon(Icons.qr_code_scanner, color: context.accentColor),
                tooltip: l.repairScan,
              ),
              IconButton(
                onPressed: _addSelected,
                icon: Icon(Icons.add, color: context.accentColor),
                tooltip: l.repairsNew,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: AppleSearchField(
            hintText: l.repairsSearch,
            onChanged: (v) => setState(() => _query = v),
            trailing: _searchActions(),
          ),
        ),
        _FilterBar(
          l: l,
          selected: _filter,
          count: _count,
          onSelect: (f) => setState(() => _filter = f),
        ),
        Expanded(
          child: results.isEmpty
              ? _Empty(l: l)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => RepairCard(
                    repair: results[i],
                    selected: results[i].reference == _selectedRef,
                    onTap: () =>
                        setState(() => _selectedRef = results[i].reference),
                  ),
                ),
        ),
      ],
    );

    return ColoredBox(
      color: colors.groupedBackground,
      child: SafeArea(
        // Fermé → la liste occupe toute la largeur ; ouvert → maître/détail.
        child: shown == null
            ? list
            : Row(
                children: [
                  SizedBox(width: 380, child: list),
                  VerticalDivider(
                      width: 0.5, thickness: 0.5, color: colors.separator),
                  Expanded(
                    child: RepairDetailView(
                      key: ValueKey(shown.reference),
                      reference: shown.reference,
                      onClose: () => setState(() => _selectedRef = null),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _animated(int i, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = (40 * i).ms;
    return child
        .animate()
        .fadeIn(duration: 300.ms, delay: delay)
        .slideY(begin: 0.06, end: 0, duration: 300.ms, delay: delay);
  }

  void _openDetail(String reference) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => RepairDetailScreen(reference: reference)),
    );
  }

  /// Ouvre la fiche d'admission ; renvoie la référence créée (ou `null`).
  Future<String?> _createRepair() => showAppleSheet<String>(
        context: context,
        title: AppLocalizations.of(context).repairsNew,
        builder: (_) => const _RepairIntakeSheet(),
      );

  // Plein écran : on pousse le détail après création.
  Future<void> _addPushed() async {
    final ref = await _createRepair();
    if (ref != null && mounted) _openDetail(ref);
  }

  // Maître/détail : on sélectionne la nouvelle réparation dans le volet.
  Future<void> _addSelected() async {
    final ref = await _createRepair();
    if (ref != null && mounted) setState(() => _selectedRef = ref);
  }

  /// Ouvre le scanner ; renvoie la référence trouvée (ou `null`).
  Future<String?> _scan() => Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const RepairScanScreen()),
      );

  Future<void> _scanPushed() async {
    final ref = await _scan();
    if (ref != null && mounted) _openDetail(ref);
  }

  Future<void> _scanSelected() async {
    final ref = await _scan();
    if (ref != null && mounted) setState(() => _selectedRef = ref);
  }
}

/// Actions en fin de champ de recherche : tri (menu déroulant sur icône) et
/// filtres (feuille), avec teinte active et pastille de compteur.
class _SearchActions extends StatelessWidget {
  const _SearchActions({
    required this.l,
    required this.sort,
    required this.onSortSelected,
    required this.filterCount,
    required this.onFilters,
  });

  final AppLocalizations l;
  final RepairSort sort;
  final ValueChanged<RepairSort> onSortSelected;
  final int filterCount;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final accent = context.accentColor;
    final sortActive = sort != RepairSort.recent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tri : menu déroulant ancré sur l'icône.
        AppleMenuButton<RepairSort>(
          label: l.repairSort,
          icon: Icons.swap_vert,
          value: sort,
          options: {for (final s in RepairSort.values) s: s.label(l)},
          onSelected: onSortSelected,
          anchorBuilder: (context, controller) => _ActionIcon(
            icon: Icons.swap_vert,
            tooltip: l.repairSort,
            tint: sortActive ? accent : colors.secondaryLabel,
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        ),
        // Filtres : feuille + pastille de compteur.
        Stack(
          clipBehavior: Clip.none,
          children: [
            _ActionIcon(
              icon: Icons.tune,
              tooltip: l.repairFilters,
              tint: filterCount > 0 ? accent : colors.secondaryLabel,
              onTap: onFilters,
            ),
            if (filterCount > 0)
              PositionedDirectional(
                end: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints:
                      const BoxConstraints(minWidth: 15, minHeight: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$filterCount',
                    style: AppleTypography.caption2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Bouton-icône compact avec info-bulle et retour tactile.
class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: tint),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}

/// Barre de filtres horizontale avec compteurs.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.l,
    required this.selected,
    required this.count,
    required this.onSelect,
  });

  final AppLocalizations l;
  final RepairStatus? selected;
  final int Function(RepairStatus?) count;
  final ValueChanged<RepairStatus?> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    // Wrap → les puces s'ajustent et passent à la ligne selon la largeur.
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppleChip(
            label: l.repairsFilterAll,
            count: count(null),
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final s in RepairStatus.values)
            AppleChip(
              label: s.label(l),
              count: count(s),
              dotColor: s.color(colors),
              selectedColor: s.color(colors),
              selected: selected == s,
              onTap: () => onSelect(s),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.build_outlined, size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.repairsEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          const SizedBox(height: 4),
          Text(l.repairsEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
        ],
      ),
    );
  }
}

/// Fiche d'admission : crée une nouvelle réparation (client + appareil + panne).
class _RepairIntakeSheet extends ConsumerStatefulWidget {
  const _RepairIntakeSheet();

  @override
  ConsumerState<_RepairIntakeSheet> createState() => _RepairIntakeSheetState();
}

class _RepairIntakeSheetState extends ConsumerState<_RepairIntakeSheet> {
  final _device = TextEditingController();
  final _issue = TextEditingController();
  final _deposit = TextEditingController();
  DeviceKind _kind = DeviceKind.phone;
  RepairPriority _priority = RepairPriority.normal;
  Client? _client;

  @override
  void initState() {
    super.initState();
    _device.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _device.dispose();
    _issue.dispose();
    _deposit.dispose();
    super.dispose();
  }

  bool get _valid => _device.text.trim().isNotEmpty && _client != null;

  Future<void> _pickClient() async {
    final c = await showClientPickerSheet(context);
    if (c != null && mounted) setState(() => _client = c);
  }

  void _save() {
    final l = AppLocalizations.of(context);
    final client = _client!;
    final deposit =
        double.tryParse(_deposit.text.trim().replaceAll(',', '.')) ?? 0;
    final created = ref.read(repairsProvider.notifier).add(
          device: _device.text.trim(),
          kind: _kind,
          clientId: client.id,
          client: client.displayName,
          clientPhone: client.phone,
          clientEmail: client.email,
          reportedIssue: _issue.text.trim(),
          priority: _priority,
          deposit: deposit,
          openingEventLabel: l.repairEventCreated,
        );
    Navigator.of(context).pop(created.reference);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(l.repairSectionClient),
          const SizedBox(height: 8),
          _ClientSelectTile(client: _client, onTap: _pickClient),
          const SizedBox(height: 12),
          AppleTextField(controller: _device, label: l.repairSectionDevice),
          const SizedBox(height: 12),
          _FieldLabel(l.repairFilterDeviceTitle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in DeviceKind.values)
                AppleChip(
                  label: k.label(l),
                  selected: _kind == k,
                  onTap: () => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _issue,
              label: l.repairReported,
              minLines: 1,
              maxLines: 3),
          const SizedBox(height: 12),
          _FieldLabel(l.repairPriority),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in RepairPriority.values)
                AppleChip(
                  label: p.label(l),
                  selected: _priority == p,
                  selectedColor: p.color(context.appleColors),
                  onTap: () => setState(() => _priority = p),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _deposit,
              label: l.financeDeposit,
              suffix: AppFormats.symbol,
              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
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

/// Petit intitulé de champ (façon iOS, en gris).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(text,
            style: AppleTypography.footnote
                .copyWith(color: context.appleColors.secondaryLabel)),
      );
}

/// Ligne « choisir un client » : nom sélectionné ou invite, avec chevron.
class _ClientSelectTile extends StatelessWidget {
  const _ClientSelectTile({required this.client, required this.onTap});
  final Client? client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final has = client != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ShapeDecoration(
          color: colors.fill,
          shape: AppleRadii.shape(AppleRadii.md),
        ),
        child: Row(
          children: [
            Icon(has ? Icons.person : Icons.person_add_alt,
                size: 20, color: context.accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                has ? client!.displayName : l.clientSelect,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppleTypography.body.copyWith(
                    color: has ? colors.label : colors.secondaryLabel),
              ),
            ),
            Icon(context.chevronForward,
                size: 18, color: colors.tertiaryLabel),
          ],
        ),
      ),
    );
  }
}
