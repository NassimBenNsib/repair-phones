import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/hashing.dart';
import '../../../core/auth/permissions.dart';
import '../../users/application/account_log_controller.dart';
import '../../users/application/users_controller.dart';
import '../../users/domain/account_event.dart';
import '../../users/domain/app_user.dart';
import '../data/session_repository.dart';

/// Fournit le [SessionRepository] (surchargé au démarrage).
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => throw UnimplementedError('sessionRepositoryProvider non initialisé'),
);

/// Session courante : `null` = déconnecté, sinon l'identifiant utilisateur.
class SessionController extends Notifier<String?> {
  SessionRepository get _repo => ref.read(sessionRepositoryProvider);

  @override
  String? build() => _repo.load();

  bool get isLoggedIn => state != null;

  AppUser? get currentUser =>
      state == null ? null : ref.read(usersProvider.notifier).byId(state!);

  /// Vérifie une permission de l'utilisateur courant.
  bool can(Permission p) => currentUser?.can(p) ?? false;

  /// Connexion par e-mail + mot de passe.
  bool loginEmail(String email, String password) {
    final user = ref.read(usersProvider.notifier).byEmail(email);
    if (user == null || !user.active || !verifySecret(password, user.passwordHash)) {
      ref.read(accountLogProvider.notifier).record(AccountEventKind.failedLogin,
          targetEmail: email, detail: 'email');
      return false;
    }
    _onLoggedIn(user);
    return true;
  }

  /// Connexion rapide par code PIN (comptoir).
  bool loginPin(String pin) {
    for (final user in ref.read(usersProvider)) {
      if (user.active && verifySecret(pin, user.pinHash)) {
        _onLoggedIn(user);
        return true;
      }
    }
    ref.read(accountLogProvider.notifier).record(AccountEventKind.failedLogin,
        detail: 'pin');
    return false;
  }

  void _onLoggedIn(AppUser user) {
    _setSession(user.id);
    ref.read(usersProvider.notifier).touchLastLogin(user.id);
    ref.read(accountLogProvider.notifier).record(AccountEventKind.login,
        targetId: user.id, targetEmail: user.email);
  }

  void logout() {
    // Journalisé avant l'effacement pour connaître l'acteur.
    ref.read(accountLogProvider.notifier).record(AccountEventKind.logout);
    _repo.clear();
    state = null;
  }

  void _setSession(String userId) {
    _repo.save(userId);
    state = userId;
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, String?>(SessionController.new);
