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
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../application/employees_controller.dart';
import '../domain/employee.dart';
import 'employee_detail.dart';

/// Répertoire des employés : recherche, liste et vue maître/détail.
class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  static const String routeName = 'staff';
  static const String routePath = '/staff';

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  String _query = '';
  String? _selectedId;
  bool? _active; // null = tous, true = actifs, false = inactifs

  List<Employee> _filter(List<Employee> list) {
    final q = _query.trim().toLowerCase();
    return list.where((e) {
      final matchQ = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          (e.jobTitle ?? '').toLowerCase().contains(q) ||
          e.phone.contains(q);
      final matchActive = _active == null || e.active == _active;
      return matchQ && matchActive;
    }).toList();
  }

  Future<void> _add() async {
    final created = await _showAddEmployeeSheet(context);
    if (created != null) ref.read(employeesProvider.notifier).add(created);
  }

  void _open(Employee e) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EmployeeDetailScreen(employee: e)),
      );

  ClientsListStyle get _style =>
      ref.watch(settingsControllerProvider.select((s) => s.clientsListStyle));

  Widget _toggle() => DirectoryViewToggle(
        style: _style,
        onChanged: (v) =>
            ref.read(settingsControllerProvider.notifier).setClientsListStyle(v),
      );

  /// Barre de segments : tous / actifs / inactifs.
  Widget _segmentBar() {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        AppleChip(
            label: l.repairsFilterAll,
            selected: _active == null,
            onTap: () => setState(() => _active = null)),
        AppleChip(
            label: l.staffActive,
            selected: _active == true,
            onTap: () => setState(() => _active = _active == true ? null : true)),
        AppleChip(
            label: l.staffInactive,
            selected: _active == false,
            onTap: () =>
                setState(() => _active = _active == false ? null : false)),
      ]),
    );
  }

  Widget _emptyState({required bool collectionEmpty}) {
    final l = AppLocalizations.of(context);
    return collectionEmpty
        ? ListEmptyState(
            icon: Icons.badge_outlined,
            title: l.staffEmpty,
            subtitle: l.staffEmptySubtitle,
            actionLabel: l.staffNew,
            onAction: _add,
          )
        : ListEmptyState(
            icon: Icons.search_off,
            title: l.listNoResults,
            subtitle: l.listNoResultsSubtitle,
          );
  }

  List<DirColumn<Employee>> _columns(AppLocalizations l) => [
        DirColumn(
            label: l.fieldName,
            width: 200,
            leading: true,
            value: (e) => e.name,
            sortKey: (e) => e.name.toLowerCase()),
        DirColumn(
            label: l.staffJobTitle,
            width: 160,
            value: (e) => e.jobTitle ?? '—',
            sortKey: (e) => (e.jobTitle ?? '').toLowerCase()),
        DirColumn(
            label: l.fieldPhone,
            width: 150,
            value: (e) => e.phone.isEmpty ? '—' : e.phone),
        DirColumn(label: l.fieldEmail, width: 200, value: (e) => e.email ?? '—'),
        DirColumn(
            label: l.staffCommission,
            width: 130,
            value: (e) => '${(e.commissionRate * 100).toStringAsFixed(0)} %',
            sortKey: (e) => e.commissionRate),
        DirColumn(
            label: l.staffActive,
            width: 110,
            value: (e) => e.active ? l.staffActive : l.staffInactive,
            sortKey: (e) => e.active ? 0 : 1,
            color: (e, colors) =>
                e.active ? colors.green : colors.secondaryLabel),
      ];

  @override
  Widget build(BuildContext context) {
    final detailLayout =
        ref.watch(settingsControllerProvider.select((s) => s.detailLayout));
    final style = _style;
    return LayoutBuilder(
      builder: (context, c) {
        final twoPane = style == ClientsListStyle.list &&
            detailLayout.useTwoPane(c.maxWidth);
        return twoPane ? _twoPane(context) : _singlePane(context);
      },
    );
  }

  Widget _singlePane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(employeesProvider);
    final results = _filter(all);
    final style = _style;
    return AppleScaffold(
      title: l.navStaff,
      actions: [
        _toggle(),
        IconButton(
            onPressed: _add,
            icon: Icon(Icons.add, color: context.accentColor),
            tooltip: l.staffNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.staffSearch,
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
                  subtitle: results[i].jobTitle ?? results[i].phone,
                  badge: results[i].active ? null : l.staffInactive,
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
              child: DirectoryTable<Employee>(
                items: results,
                columns: _columns(l),
                avatarName: (e) => e.name,
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
                  for (final e in results)
                    _EmployeeRow(employee: e, onTap: () => _open(e)),
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
    final all = ref.watch(employeesProvider);
    final results = _filter(all);
    final shown = all.any((e) => e.id == _selectedId) ? _selectedId : null;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.navStaff,
                    style: AppleTypography.title1.copyWith(color: colors.label)),
              ),
              _toggle(),
              IconButton(
                  onPressed: _add,
                  icon: Icon(Icons.add, color: context.accentColor),
                  tooltip: l.staffNew),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: AppleSearchField(
            hintText: l.staffSearch,
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
                        for (final e in results)
                          _EmployeeRow(
                            employee: e,
                            selected: e.id == shown,
                            onTap: () => setState(() => _selectedId = e.id),
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
                    child: EmployeeDetailView(
                      key: ValueKey(shown),
                      employeeId: shown,
                      onClose: () => setState(() => _selectedId = null),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow(
      {required this.employee, required this.onTap, this.selected = false});

  final Employee employee;
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
                AppleAvatar(name: employee.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.name,
                          style: AppleTypography.body
                              .copyWith(color: colors.label)),
                      Text(employee.jobTitle ?? employee.phone,
                          style: AppleTypography.footnote
                              .copyWith(color: colors.secondaryLabel)),
                    ],
                  ),
                ),
                if (!employee.active)
                  AppleBadge(
                      label: l.staffInactive, color: colors.secondaryLabel),
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

/// Feuille de création d'un employé.
Future<Employee?> _showAddEmployeeSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<Employee>(
    context: context,
    title: l.staffNew,
    builder: (context) => const _AddEmployeeForm(),
  );
}

class _AddEmployeeForm extends StatefulWidget {
  const _AddEmployeeForm();

  @override
  State<_AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<_AddEmployeeForm> {
  final _name = TextEditingController();
  final _job = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _job.dispose();
    _phone.dispose();
    _email.dispose();
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
          AppleTextField(controller: _name, label: l.fieldName),
          const SizedBox(height: 12),
          AppleTextField(controller: _job, label: l.staffJobTitle),
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
          const SizedBox(height: 16),
          AppleButton(
            label: l.addLabel,
            icon: Icons.check,
            expand: true,
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(Employee(
                      id: const Uuid().v4(),
                      name: _name.text.trim(),
                      jobTitle: _opt(_job),
                      phone: _phone.text.trim(),
                      email: _opt(_email),
                    )),
          ),
        ],
      ),
    );
  }
}
