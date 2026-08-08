// Règles de comptes : unicité e-mail/PIN, invariant « au moins un admin actif »,
// et permission requise par route.

import 'package:atelier_reparation/core/auth/permissions.dart';
import 'package:atelier_reparation/core/navigation/app_sections.dart';
import 'package:atelier_reparation/features/users/application/account_rules.dart';
import 'package:atelier_reparation/features/users/domain/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

AppUser _u(String id,
        {String email = '',
        AppRole role = AppRole.technician,
        bool active = true,
        String? pinHash}) =>
    AppUser(
      id: id,
      email: email.isEmpty ? '$id@atelier.fr' : email,
      passwordHash: 'pw',
      pinHash: pinHash,
      role: role,
      active: active,
    );

void main() {
  test('emailTaken est insensible à la casse et exclut exceptId', () {
    final users = [_u('a', email: 'Admin@Atelier.FR')];
    expect(AccountRules.emailTaken(users, 'admin@atelier.fr'), isTrue);
    expect(AccountRules.emailTaken(users, 'admin@atelier.fr', exceptId: 'a'),
        isFalse);
    expect(AccountRules.emailTaken(users, 'other@x.fr'), isFalse);
  });

  test('pinTaken compare les empreintes et ignore les PIN nuls', () {
    final users = [_u('a', pinHash: 'h1'), _u('b')];
    expect(AccountRules.pinTaken(users, 'h1'), isTrue);
    expect(AccountRules.pinTaken(users, 'h1', exceptId: 'a'), isFalse);
    expect(AccountRules.pinTaken(users, 'h2'), isFalse);
  });

  group('wouldOrphanAdmins', () {
    test('rétrograder le seul admin → orphelin', () {
      final users = [_u('a', role: AppRole.admin), _u('b')];
      expect(
          AccountRules.wouldOrphanAdmins(
              users, _u('a', role: AppRole.technician)),
          isTrue);
    });
    test('désactiver le seul admin → orphelin', () {
      final users = [_u('a', role: AppRole.admin)];
      expect(
          AccountRules.wouldOrphanAdmins(
              users, _u('a', role: AppRole.admin, active: false)),
          isTrue);
    });
    test('un second admin actif protège', () {
      final users = [
        _u('a', role: AppRole.admin),
        _u('b', role: AppRole.admin)
      ];
      expect(
          AccountRules.wouldOrphanAdmins(
              users, _u('a', role: AppRole.technician)),
          isFalse);
    });
    test('éditer un non-admin ne change rien', () {
      final users = [_u('a', role: AppRole.admin), _u('b')];
      expect(
          AccountRules.wouldOrphanAdmins(
              users, _u('b', role: AppRole.cashier)),
          isFalse);
    });
  });

  test('validateAdd / validateEdit', () {
    final users = [
      _u('a', email: 'admin@atelier.fr', role: AppRole.admin, pinHash: 'h1'),
    ];
    // Add : e-mail déjà pris.
    expect(AccountRules.validateAdd(users, _u('n', email: 'admin@atelier.fr')),
        AccountError.emailTaken);
    // Add : PIN déjà pris.
    expect(AccountRules.validateAdd(users, _u('n', pinHash: 'h1')),
        AccountError.pinTaken);
    // Add : OK.
    expect(AccountRules.validateAdd(users, _u('n', email: 'new@x.fr')), isNull);
    // Edit : rétrograder le dernier admin.
    expect(
        AccountRules.validateEdit(
            users, _u('a', email: 'admin@atelier.fr', role: AppRole.cashier)),
        AccountError.lastAdmin);
  });

  test('requiredPermissionFor applique la permission de la route', () {
    expect(requiredPermissionFor('/users'), Permission.manageUsers);
    expect(requiredPermissionFor('/users/anything'), Permission.manageUsers);
    expect(requiredPermissionFor('/no-such-route'), isNull);
  });
}
