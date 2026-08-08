import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/hashing.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/design/apple_tokens.dart';
import '../../../core/format/app_formats.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../auth/application/session_controller.dart';
import '../../staff/application/employees_controller.dart';
import '../application/account_log_controller.dart';
import '../application/account_rules.dart';
import '../application/users_controller.dart';
import '../domain/account_event.dart';
import '../domain/app_user.dart';
import 'account_log_screen.dart';

/// Placeholder du volet (deux colonnes, rien de sélectionné).
class UserDetailEmpty extends StatelessWidget {
  const UserDetailEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return ColoredBox(
      color: colors.groupedBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.manage_accounts_outlined,
                size: 64, color: colors.tertiaryLabel),
            const SizedBox(height: 16),
            Text(l.userEmpty,
                style: AppleTypography.title3.copyWith(color: colors.label)),
          ],
        ),
      ),
    );
  }
}

/// Écran de détail utilisateur (page poussée).
class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(context.backIcon, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(user.email),
      ),
      body: UserDetailView(userId: user.id),
    );
  }
}

/// Contenu réutilisable (volet ou écran) — vue + édition inline.
class UserDetailView extends ConsumerStatefulWidget {
  const UserDetailView({super.key, required this.userId, this.onClose});

  final String userId;
  final VoidCallback? onClose;

  @override
  ConsumerState<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends ConsumerState<UserDetailView> {
  bool _editing = false;
  final _email = TextEditingController();
  final _newPassword = TextEditingController();
  final _newPin = TextEditingController();
  AppRole _role = AppRole.technician;
  String? _employeeId;
  bool _active = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = _current();
    if (u != null) _fill(u);
  }

  AppUser? _current() {
    for (final u in ref.read(usersProvider)) {
      if (u.id == widget.userId) return u;
    }
    return null;
  }

  void _fill(AppUser u) {
    _email.text = u.email;
    _newPassword.clear();
    _newPin.clear();
    _role = u.role;
    _employeeId = u.employeeId;
    _active = u.active;
  }

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _newPin.dispose();
    super.dispose();
  }

  void _save() {
    final u = _current();
    if (u == null) return;
    final l = AppLocalizations.of(context);
    final pw = _newPassword.text.trim();
    final pin = _newPin.text.trim();
    final candidate = AppUser(
      id: u.id,
      email: _email.text.trim(),
      passwordHash: pw.isEmpty ? u.passwordHash : hashSecret(pw),
      pinHash: pin.isEmpty ? u.pinHash : hashSecret(pin),
      role: _role,
      employeeId: _employeeId,
      active: _active,
    );
    final error = AccountRules.validateEdit(ref.read(usersProvider), candidate);
    if (error != null) {
      setState(() => _error = error.message(l));
      return;
    }
    ref.read(usersProvider.notifier).update(candidate);
    _audit(u, candidate, pwChanged: pw.isNotEmpty, pinChanged: pin.isNotEmpty);
    setState(() {
      _editing = false;
      _error = null;
    });
  }

  /// Journalise les changements significatifs d'un enregistrement.
  void _audit(AppUser before, AppUser after,
      {bool pwChanged = false, bool pinChanged = false}) {
    final log = ref.read(accountLogProvider.notifier);
    void rec(AccountEventKind k) =>
        log.record(k, targetId: after.id, targetEmail: after.email);
    var any = false;
    if (after.role != before.role) {
      rec(AccountEventKind.roleChanged);
      any = true;
    }
    if (after.active != before.active) {
      rec(after.active
          ? AccountEventKind.reactivated
          : AccountEventKind.deactivated);
      any = true;
    }
    if (pwChanged) {
      rec(AccountEventKind.passwordReset);
      any = true;
    }
    if (pinChanged) {
      rec(AccountEventKind.pinReset);
      any = true;
    }
    if (!any) rec(AccountEventKind.updated);
  }

  void _cancel() {
    final u = _current();
    if (u != null) _fill(u);
    setState(() {
      _editing = false;
      _error = null;
    });
  }

  String _tempSecret([int len = 8]) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String _uniquePin() {
    final users = ref.read(usersProvider);
    final r = Random();
    while (true) {
      final pin = (1000 + r.nextInt(9000)).toString();
      if (!AccountRules.pinTaken(users, hashSecret(pin))) return pin;
    }
  }

  Future<void> _showSecret(String secret) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.secondaryGroupedBackground,
        title: Text(l.accountTempSecret),
        content: SelectableText(secret,
            style: AppleTypography.title2.copyWith(color: colors.label)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    final u = _current();
    if (u == null) return;
    final secret = _tempSecret();
    ref
        .read(usersProvider.notifier)
        .update(u.copyWith(passwordHash: hashSecret(secret)));
    ref.read(accountLogProvider.notifier).record(
        AccountEventKind.passwordReset,
        targetId: u.id,
        targetEmail: u.email);
    await _showSecret(secret);
    if (mounted) setState(() {});
  }

  Future<void> _resetPin() async {
    final u = _current();
    if (u == null) return;
    final pin = _uniquePin();
    ref.read(usersProvider.notifier).update(u.copyWith(pinHash: hashSecret(pin)));
    ref.read(accountLogProvider.notifier).record(AccountEventKind.pinReset,
        targetId: u.id, targetEmail: u.email);
    await _showSecret(pin);
    if (mounted) setState(() {});
  }

  Future<void> _invite() async {
    final u = _current();
    if (u == null) return;
    final secret = _tempSecret();
    ref.read(usersProvider.notifier).update(
        u.copyWith(invitePending: true, passwordHash: hashSecret(secret)));
    ref.read(accountLogProvider.notifier).record(AccountEventKind.invited,
        targetId: u.id, targetEmail: u.email);
    await _showSecret(secret);
    if (mounted) setState(() {});
  }

  Future<void> _delete() async {
    final u = _current();
    if (u == null) return;
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    // Ne jamais supprimer le dernier administrateur actif.
    final otherAdmin = ref.read(usersProvider).any(
        (x) => x.id != u.id && x.active && x.role == AppRole.admin);
    if (u.active && u.role == AppRole.admin && !otherAdmin) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: colors.secondaryGroupedBackground,
          content: Text(l.accountLastAdmin),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.secondaryGroupedBackground,
        content: Text(l.accountDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.commonCancel)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.accountDelete)),
        ],
      ),
    );
    if (ok != true) return;
    ref.read(accountLogProvider.notifier).record(AccountEventKind.deleted,
        targetId: u.id, targetEmail: u.email);
    ref.read(usersProvider.notifier).remove(u.id);
    if (!mounted) return;
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _pickEmployee() async {
    final l = AppLocalizations.of(context);
    final employees = ref.read(employeesProvider);
    final choice = await showAppleSelectionSheet<String>(
      context: context,
      title: l.userLinkedEmployee,
      selected: _employeeId ?? '',
      options: [
        AppleSheetOption('', l.userNoEmployee),
        for (final e in employees) AppleSheetOption(e.id, e.name),
      ],
    );
    if (choice != null) setState(() => _employeeId = choice.isEmpty ? null : choice);
  }

  String _employeeName(AppLocalizations l) {
    if (_employeeId == null) return l.userNoEmployee;
    for (final e in ref.read(employeesProvider)) {
      if (e.id == _employeeId) return e.name;
    }
    return l.userNoEmployee;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final u = _current();
    if (u == null) return const UserDetailEmpty();
    final canManage =
        ref.read(sessionControllerProvider.notifier).can(Permission.manageUsers);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          children: [
            if (widget.onClose != null)
              IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(Icons.close, color: colors.secondaryLabel)),
            const Spacer(),
            if (_editing) ...[
              AppleButton(
                  label: l.commonCancel,
                  style: AppleButtonStyle.gray,
                  onPressed: _cancel),
              const SizedBox(width: 8),
              AppleButton(label: l.commonSave, onPressed: _save),
            ] else if (canManage)
              AppleButton(
                  label: l.actionEdit,
                  icon: Icons.edit_outlined,
                  style: AppleButtonStyle.tinted,
                  onPressed: () => setState(() => _editing = true)),
          ],
        ),

        // En-tête.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              AppleAvatar(name: u.email, size: 72),
              const SizedBox(height: 12),
              if (_editing)
                AppleTextField(controller: _email, label: l.authModeEmail)
              else ...[
                Text(u.email,
                    textAlign: TextAlign.center,
                    style: AppleTypography.title3.copyWith(color: colors.label)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    AppleBadge(
                        label: u.role.label(l), color: context.accentColor),
                    if (!u.active)
                      AppleBadge(
                          label: l.staffInactive, color: colors.secondaryLabel),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Compte.
        SectionHeader(
            title: l.navUsers,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        AppleCard(
          child: _editing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.userRole,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                    const SizedBox(height: 6),
                    AppleSegmentedControl<AppRole>(
                      value: _role,
                      onChanged: (r) => setState(() => _role = r),
                      segments: {
                        for (final r in AppRole.values) r: r.label(l),
                      },
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickEmployee,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          Expanded(
                            child: Text(l.userLinkedEmployee,
                                style: AppleTypography.body
                                    .copyWith(color: colors.label)),
                          ),
                          Text(_employeeName(l),
                              style: AppleTypography.body
                                  .copyWith(color: context.accentColor)),
                          Icon(context.chevronForward,
                              size: 18, color: colors.tertiaryLabel),
                        ]),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(l.staffActive,
                                style: AppleTypography.body
                                    .copyWith(color: colors.label))),
                        Switch.adaptive(
                            value: _active,
                            onChanged: (v) => setState(() => _active = v)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppleTextField(
                        controller: _newPassword,
                        label: l.userNewPassword,
                        obscureText: true),
                    const SizedBox(height: 12),
                    AppleTextField(
                        controller: _newPin,
                        label: l.userNewPin,
                        keyboardType: TextInputType.number,
                        obscureText: true),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          style: AppleTypography.footnote
                              .copyWith(color: colors.red)),
                    ],
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(l.userRole, u.role.label(l), colors),
                    _kv(l.userLinkedEmployee, _employeeName(l), colors),
                    _kv(l.accountCreatedAt,
                        u.createdAt == null ? '—' : AppFormats.date(u.createdAt!),
                        colors),
                    _kv(
                        l.accountLastLogin,
                        u.lastLogin == null
                            ? l.accountNeverLoggedIn
                            : AppFormats.date(u.lastLogin!),
                        colors),
                  ],
                ),
        ),

        // Actions (vue seule, réservé à la gestion des comptes).
        if (!_editing && canManage) ...[
          SectionHeader(
              title: l.accountActionsTitle,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleListSection(children: [
            AppleListRow(
                leadingIcon: Icons.lock_reset,
                leadingTint: colors.orange,
                title: l.accountResetPassword,
                showChevron: true,
                onTap: _resetPassword),
            AppleListRow(
                leadingIcon: Icons.pin_outlined,
                leadingTint: colors.indigo,
                title: l.accountResetPin,
                showChevron: true,
                onTap: _resetPin),
            AppleListRow(
                leadingIcon: Icons.mail_outline,
                leadingTint: colors.blue,
                title: l.accountInvite,
                subtitle: u.invitePending ? l.accountInvitePending : null,
                showChevron: true,
                onTap: _invite),
            AppleListRow(
                leadingIcon: Icons.delete_outline,
                leadingTint: colors.red,
                title: l.accountDelete,
                showChevron: true,
                onTap: _delete),
          ]),
        ],

        // Activité récente de ce compte.
        if (!_editing) ...[
          SectionHeader(
              title: l.accountActivity,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          Builder(builder: (_) {
            final events = ref
                .watch(accountLogProvider)
                .where((e) => e.targetId == u.id || e.actorId == u.id)
                .take(12)
                .toList();
            if (events.isEmpty) {
              return AppleCard(
                child: Text(l.listNoResults,
                    style: AppleTypography.body
                        .copyWith(color: colors.secondaryLabel)),
              );
            }
            return AppleListSection(children: [
              for (final e in events)
                AccountEventTile(event: e, showActor: false),
            ]);
          }),
        ],
      ],
    );
  }

  Widget _kv(String label, String value, AppleColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
          ),
          Expanded(
            child: Text(value,
                style: AppleTypography.body.copyWith(color: colors.label)),
          ),
        ],
      ),
    );
  }
}
