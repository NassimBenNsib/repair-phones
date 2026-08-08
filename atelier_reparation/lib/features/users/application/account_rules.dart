import '../../../core/auth/permissions.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_user.dart';

/// Motif de refus d'un enregistrement de compte.
enum AccountError { emailTaken, pinTaken, lastAdmin }

extension AccountErrorX on AccountError {
  String message(AppLocalizations l) => switch (this) {
        AccountError.emailTaken => l.accountEmailTaken,
        AccountError.pinTaken => l.accountPinTaken,
        AccountError.lastAdmin => l.accountLastAdmin,
      };
}

/// Règles métier des comptes : unicité (e-mail / PIN) et invariant « au moins
/// un administrateur actif ». Fonctions pures, testables sans Riverpod.
class AccountRules {
  const AccountRules._();

  static bool emailTaken(List<AppUser> users, String email, {String? exceptId}) {
    final e = email.trim().toLowerCase();
    return users
        .any((u) => u.id != exceptId && u.email.trim().toLowerCase() == e);
  }

  static bool pinTaken(List<AppUser> users, String pinHash, {String? exceptId}) =>
      users.any(
          (u) => u.id != exceptId && u.pinHash != null && u.pinHash == pinHash);

  /// Applique [edited] (remplace par id, sinon ajoute) puis indique s'il ne
  /// resterait **aucun** administrateur actif. Couvre la rétrogradation et la
  /// désactivation du dernier admin (y compris soi-même).
  static bool wouldOrphanAdmins(List<AppUser> users, AppUser edited) {
    var replaced = false;
    final next = <AppUser>[];
    for (final u in users) {
      if (u.id == edited.id) {
        next.add(edited);
        replaced = true;
      } else {
        next.add(u);
      }
    }
    if (!replaced) next.add(edited);
    return !next.any((u) => u.active && u.role == AppRole.admin);
  }

  /// Validation d'un **nouveau** compte : unicité e-mail + PIN.
  static AccountError? validateAdd(List<AppUser> users, AppUser candidate) {
    if (emailTaken(users, candidate.email, exceptId: candidate.id)) {
      return AccountError.emailTaken;
    }
    final pin = candidate.pinHash;
    if (pin != null && pinTaken(users, pin, exceptId: candidate.id)) {
      return AccountError.pinTaken;
    }
    return null;
  }

  /// Validation d'une **modification** : unicité + invariant admin.
  static AccountError? validateEdit(List<AppUser> users, AppUser edited) {
    final base = validateAdd(users, edited);
    if (base != null) return base;
    if (wouldOrphanAdmins(users, edited)) return AccountError.lastAdmin;
    return null;
  }
}
