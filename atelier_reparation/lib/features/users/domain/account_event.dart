import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Nature d'un événement du journal des comptes.
enum AccountEventKind {
  login,
  logout,
  failedLogin,
  created,
  updated,
  roleChanged,
  deactivated,
  reactivated,
  passwordReset,
  pinReset,
  invited,
  deleted,
}

extension AccountEventKindX on AccountEventKind {
  String label(AppLocalizations l) => switch (this) {
        AccountEventKind.login => l.accountEventLogin,
        AccountEventKind.logout => l.accountEventLogout,
        AccountEventKind.failedLogin => l.accountEventFailedLogin,
        AccountEventKind.created => l.accountEventCreated,
        AccountEventKind.updated => l.accountEventUpdated,
        AccountEventKind.roleChanged => l.accountEventRoleChanged,
        AccountEventKind.deactivated => l.accountEventDeactivated,
        AccountEventKind.reactivated => l.accountEventReactivated,
        AccountEventKind.passwordReset => l.accountEventPasswordReset,
        AccountEventKind.pinReset => l.accountEventPinReset,
        AccountEventKind.invited => l.accountEventInvited,
        AccountEventKind.deleted => l.accountEventDeleted,
      };

  IconData get icon => switch (this) {
        AccountEventKind.login => Icons.login,
        AccountEventKind.logout => Icons.logout,
        AccountEventKind.failedLogin => Icons.gpp_bad_outlined,
        AccountEventKind.created => Icons.person_add_alt,
        AccountEventKind.updated => Icons.edit_outlined,
        AccountEventKind.roleChanged => Icons.badge_outlined,
        AccountEventKind.deactivated => Icons.block,
        AccountEventKind.reactivated => Icons.check_circle_outline,
        AccountEventKind.passwordReset => Icons.lock_reset,
        AccountEventKind.pinReset => Icons.pin_outlined,
        AccountEventKind.invited => Icons.mail_outline,
        AccountEventKind.deleted => Icons.delete_outline,
      };

  /// Événement sensible (mis en évidence).
  bool get warns =>
      this == AccountEventKind.failedLogin ||
      this == AccountEventKind.deactivated ||
      this == AccountEventKind.deleted;
}

/// Une entrée du journal des comptes (qui a fait quoi, quand).
@immutable
class AccountEvent {
  const AccountEvent({
    required this.id,
    required this.at,
    required this.kind,
    this.actorId,
    this.actorEmail = '',
    this.targetId,
    this.targetEmail,
    this.detail,
  });

  final String id;
  final DateTime at;
  final AccountEventKind kind;
  final String? actorId;
  final String actorEmail;
  final String? targetId;
  final String? targetEmail;
  final String? detail;
}
