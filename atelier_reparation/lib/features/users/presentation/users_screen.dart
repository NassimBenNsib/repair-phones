import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/hashing.dart';
import '../../../core/auth/permissions.dart';
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
import '../../auth/application/session_controller.dart';
import '../../staff/application/employees_controller.dart';
import '../application/account_log_controller.dart';
import '../application/account_rules.dart';
import '../application/users_controller.dart';
import '../domain/account_event.dart';
import '../domain/app_user.dart';
import 'account_log_screen.dart';
import 'user_detail.dart';

/// Gestion des comptes utilisateurs.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  static const String routeName = 'users';
  static const String routePath = '/users';

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _query = '';
  String? _selectedId;
  AppRole? _role; // null = tous

  List<AppUser> _filter(List<AppUser> list) {
    final q = _query.trim().toLowerCase();
    final empNames = {
      for (final e in ref.read(employeesProvider)) e.id: e.name.toLowerCase()
    };
    return list.where((u) {
      final matchQ = q.isEmpty ||
          u.email.toLowerCase().contains(q) ||
          (empNames[u.employeeId]?.contains(q) ?? false);
      final matchRole = _role == null || u.role == _role;
      return matchQ && matchRole;
    }).toList();
  }

  bool get _canManage =>
      ref.read(sessionControllerProvider.notifier).can(Permission.manageUsers);

  void _openLog() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccountLogScreen()),
      );

  Future<void> _add() async {
    final created =
        await _showAddUserSheet(context, ref.read(usersProvider));
    if (created == null) return;
    final user = created.copyWith(createdAt: DateTime.now());
    ref.read(usersProvider.notifier).add(user);
    ref.read(accountLogProvider.notifier).record(AccountEventKind.created,
        targetId: user.id, targetEmail: user.email);
  }

  /// Barre de segments par rôle.
  Widget _segmentBar() {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        AppleChip(
            label: l.repairsFilterAll,
            selected: _role == null,
            onTap: () => setState(() => _role = null)),
        for (final r in AppRole.values)
          AppleChip(
              label: r.label(l),
              selected: _role == r,
              onTap: () => setState(() => _role = _role == r ? null : r)),
      ]),
    );
  }

  /// État vide : CTA si aucun compte, sinon « aucun résultat ».
  Widget _emptyState({required bool collectionEmpty}) {
    final l = AppLocalizations.of(context);
    return collectionEmpty
        ? ListEmptyState(
            icon: Icons.manage_accounts_outlined,
            title: l.userEmpty,
            subtitle: l.userEmptySubtitle,
            actionLabel: l.userNew,
            onAction: _add,
          )
        : ListEmptyState(
            icon: Icons.search_off,
            title: l.listNoResults,
            subtitle: l.listNoResultsSubtitle,
          );
  }

  void _open(AppUser u) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => UserDetailScreen(user: u)),
      );

  ClientsListStyle get _style =>
      ref.watch(settingsControllerProvider.select((s) => s.clientsListStyle));

  Widget _toggle() => DirectoryViewToggle(
        style: _style,
        onChanged: (v) =>
            ref.read(settingsControllerProvider.notifier).setClientsListStyle(v),
      );

  List<DirColumn<AppUser>> _columns(AppLocalizations l) => [
        DirColumn(
            label: l.authModeEmail,
            width: 260,
            leading: true,
            value: (u) => u.email,
            sortKey: (u) => u.email.toLowerCase()),
        DirColumn(
            label: l.userRole,
            width: 140,
            value: (u) => u.role.label(l),
            sortKey: (u) => u.role.label(l)),
        DirColumn(
            label: l.staffActive,
            width: 120,
            value: (u) => u.active ? l.staffActive : l.staffInactive,
            sortKey: (u) => u.active ? 0 : 1,
            color: (u, colors) => u.active ? colors.green : colors.secondaryLabel),
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
    final all = ref.watch(usersProvider);
    final results = _filter(all);
    final style = _style;
    return AppleScaffold(
      title: l.navUsers,
      actions: [
        _toggle(),
        if (_canManage)
          IconButton(
              onPressed: _openLog,
              icon: Icon(Icons.history, color: context.accentColor),
              tooltip: l.accountLog),
        if (_canManage)
          IconButton(
              onPressed: _add,
              icon: Icon(Icons.add, color: context.accentColor),
              tooltip: l.userNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.userSearch,
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
                  name: results[i].email,
                  title: results[i].email,
                  subtitle: results[i].active ? null : l.staffInactive,
                  badge: results[i].role.label(l),
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
              child: DirectoryTable<AppUser>(
                items: results,
                columns: _columns(l),
                avatarName: (u) => u.email,
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
                  for (final u in results)
                    _UserRow(user: u, onTap: () => _open(u)),
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
    final all = ref.watch(usersProvider);
    final results = _filter(all);
    final shown = all.any((u) => u.id == _selectedId) ? _selectedId : null;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.navUsers,
                    style: AppleTypography.title1.copyWith(color: colors.label)),
              ),
              _toggle(),
              if (_canManage)
                IconButton(
                    onPressed: _openLog,
                    icon: Icon(Icons.history, color: context.accentColor),
                    tooltip: l.accountLog),
              if (_canManage)
                IconButton(
                    onPressed: _add,
                    icon: Icon(Icons.add, color: context.accentColor),
                    tooltip: l.userNew),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: AppleSearchField(
            hintText: l.userSearch,
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
                        for (final u in results)
                          _UserRow(
                            user: u,
                            selected: u.id == shown,
                            onTap: () => setState(() => _selectedId = u.id),
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
                    child: UserDetailView(
                      key: ValueKey(shown),
                      userId: shown,
                      onClose: () => setState(() => _selectedId = null),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow(
      {required this.user, required this.onTap, this.selected = false});

  final AppUser user;
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
                AppleAvatar(name: user.email),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(user.email,
                      style:
                          AppleTypography.body.copyWith(color: colors.label)),
                ),
                AppleBadge(label: user.role.label(l), color: colors.secondaryLabel),
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

Future<AppUser?> _showAddUserSheet(
    BuildContext context, List<AppUser> existing) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<AppUser>(
    context: context,
    title: l.userNew,
    builder: (context) => _AddUserForm(existing: existing),
  );
}

class _AddUserForm extends StatefulWidget {
  const _AddUserForm({required this.existing});
  final List<AppUser> existing;

  @override
  State<_AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<_AddUserForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _pin = TextEditingController();
  AppRole _role = AppRole.technician;
  String? _error;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _pin.dispose();
    super.dispose();
  }

  bool get _valid =>
      _email.text.trim().isNotEmpty && _password.text.trim().isNotEmpty;

  void _submit(AppLocalizations l) {
    final pin = _pin.text.trim();
    final candidate = AppUser(
      id: const Uuid().v4(),
      email: _email.text.trim(),
      passwordHash: hashSecret(_password.text.trim()),
      pinHash: pin.isEmpty ? null : hashSecret(pin),
      role: _role,
    );
    final error = AccountRules.validateAdd(widget.existing, candidate);
    if (error != null) {
      setState(() => _error = error.message(l));
      return;
    }
    Navigator.of(context).pop(candidate);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleTextField(
              controller: _email,
              label: l.authModeEmail,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _password, label: l.authPassword, obscureText: true),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _pin,
              label: l.authPin,
              keyboardType: TextInputType.number,
              obscureText: true),
          const SizedBox(height: 14),
          AppleSegmentedControl<AppRole>(
            value: _role,
            onChanged: (r) => setState(() => _role = r),
            segments: {for (final r in AppRole.values) r: r.label(l)},
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style:
                    AppleTypography.footnote.copyWith(color: colors.red)),
          ],
          const SizedBox(height: 16),
          AppleButton(
            label: l.addLabel,
            icon: Icons.check,
            expand: true,
            onPressed: !_valid ? null : () => _submit(l),
          ),
        ],
      ),
    );
  }
}
