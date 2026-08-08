import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/hashing.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/list_empty_state.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../auth/application/session_controller.dart';
import '../../staff/application/employees_controller.dart';
import '../../users/application/users_controller.dart';
import '../../users/domain/app_user.dart';

/// Profil de l'utilisateur connecté : identité, compte et sécurité.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String routeName = 'profile';
  static const String routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final userId = ref.watch(sessionControllerProvider);
    final users = ref.watch(usersProvider);

    AppUser? me;
    for (final u in users) {
      if (u.id == userId) {
        me = u;
        break;
      }
    }

    if (me == null) {
      return AppleScaffold(
        title: l.navProfile,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ListEmptyState(
                icon: Icons.person_off_outlined, title: l.listNoResults),
          ),
        ],
      );
    }

    final employees = ref.watch(employeesProvider);
    final empId = me.employeeId;
    final employee = empId == null
        ? null
        : employees.where((e) => e.id == empId).firstOrNull;
    final displayName = employee?.name ?? me.email;
    final user = me; // promotion locale non-nulle pour les closures

    Widget header(String t) => SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 4),
          sliver: SliverToBoxAdapter(child: SectionHeader(title: t)),
        );
    Widget section(Widget child) => SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: child),
        );

    return AppleScaffold(
      title: l.navProfile,
      slivers: [
        // En-tête : avatar, nom, rôle.
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              child: Column(
                children: [
                  AppleAvatar(name: displayName, size: 72),
                  const SizedBox(height: 12),
                  Text(displayName,
                      textAlign: TextAlign.center,
                      style:
                          AppleTypography.title2.copyWith(color: colors.label)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      AppleBadge(
                          label: user.role.label(l), color: context.accentColor),
                      if (!user.active)
                        AppleBadge(
                            label: l.staffInactive,
                            color: colors.secondaryLabel),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Compte.
        header(l.profileAccount),
        section(AppleListSection(children: [
          AppleListRow(
              leadingIcon: Icons.mail_outline,
              leadingTint: colors.blue,
              title: l.fieldEmail,
              trailingText: user.email),
          AppleListRow(
              leadingIcon: Icons.badge_outlined,
              leadingTint: context.accentColor,
              title: l.userRole,
              trailingText: user.role.label(l)),
          if (employee != null)
            AppleListRow(
                leadingIcon: Icons.person_outline,
                leadingTint: colors.green,
                title: l.profileLinkedEmployee,
                subtitle: employee.jobTitle,
                trailingText: employee.name),
        ])),

        // Sécurité.
        header(l.profileSecurity),
        section(AppleListSection(children: [
          AppleListRow(
              leadingIcon: Icons.lock_outline,
              leadingTint: colors.orange,
              title: l.profileChangePassword,
              showChevron: true,
              onTap: () => _changePassword(context, ref, user)),
          AppleListRow(
              leadingIcon: Icons.pin_outlined,
              leadingTint: colors.indigo,
              title: l.profileChangePin,
              showChevron: true,
              onTap: () => _changePin(context, ref, user)),
        ])),

        // Déconnexion.
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 24),
          sliver: SliverToBoxAdapter(
            child: AppleButton(
              label: l.authLogout,
              icon: Icons.logout,
              style: AppleButtonStyle.destructive,
              expand: true,
              onPressed: () {
                Navigator.of(context).popUntil((r) => r.isFirst);
                ref.read(sessionControllerProvider.notifier).logout();
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _changePassword(
      BuildContext context, WidgetRef ref, AppUser me) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _ChangePasswordDialog(expectedHash: me.passwordHash),
    );
    if (result == null) return;
    ref
        .read(usersProvider.notifier)
        .update(me.copyWith(passwordHash: hashSecret(result)));
  }

  Future<void> _changePin(
      BuildContext context, WidgetRef ref, AppUser me) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const _ChangePinDialog(),
    );
    if (result == null) return;
    ref
        .read(usersProvider.notifier)
        .update(me.copyWith(pinHash: hashSecret(result)));
  }
}

/// Dialogue de changement de mot de passe (vérifie l'actuel localement).
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.expectedHash});
  final String expectedHash;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l) {
    if (!verifySecret(_current.text, widget.expectedHash)) {
      setState(() => _error = l.profileWrongPassword);
      return;
    }
    final next = _next.text.trim();
    if (next.isEmpty) return;
    if (next != _confirm.text.trim()) {
      setState(() => _error = l.profilePasswordMismatch);
      return;
    }
    Navigator.of(context).pop(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return AlertDialog(
      backgroundColor: colors.secondaryGroupedBackground,
      title: Text(l.profileChangePassword),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        AppleTextField(
            controller: _current,
            label: l.profileCurrentPassword,
            obscureText: true),
        const SizedBox(height: 12),
        AppleTextField(
            controller: _next,
            label: l.profileNewPassword,
            obscureText: true),
        const SizedBox(height: 12),
        AppleTextField(
            controller: _confirm, label: l.profileConfirm, obscureText: true),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!,
              style: AppleTypography.footnote.copyWith(color: colors.red)),
        ],
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.commonCancel)),
        TextButton(onPressed: () => _submit(l), child: Text(l.commonSave)),
      ],
    );
  }
}

/// Dialogue de changement de code PIN.
class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog();

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l) {
    final pin = _pin.text.trim();
    if (pin.isEmpty) return;
    if (pin != _confirm.text.trim()) {
      setState(() => _error = l.profilePasswordMismatch);
      return;
    }
    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return AlertDialog(
      backgroundColor: colors.secondaryGroupedBackground,
      title: Text(l.profileChangePin),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        AppleTextField(
            controller: _pin,
            label: l.profileNewPin,
            keyboardType: TextInputType.number,
            obscureText: true),
        const SizedBox(height: 12),
        AppleTextField(
            controller: _confirm,
            label: l.profileConfirm,
            keyboardType: TextInputType.number,
            obscureText: true),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!,
              style: AppleTypography.footnote.copyWith(color: colors.red)),
        ],
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.commonCancel)),
        TextButton(onPressed: () => _submit(l), child: Text(l.commonSave)),
      ],
    );
  }
}
