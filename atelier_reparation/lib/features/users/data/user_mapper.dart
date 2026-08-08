import '../../../core/auth/permissions.dart';
import '../../../core/data/local_store.dart';
import '../domain/app_user.dart';

/// (Dé)sérialisation d'un [AppUser] pour le stockage local.
class UserMapper implements EntityMapper<AppUser> {
  @override
  String get collection => 'users';

  @override
  String idOf(AppUser u) => u.id;

  @override
  Map<String, Object?> toJson(AppUser u) => {
        'id': u.id,
        'email': u.email,
        'passwordHash': u.passwordHash,
        'pinHash': u.pinHash,
        'role': u.role.name,
        'employeeId': u.employeeId,
        'active': u.active,
        'createdAt': u.createdAt?.toIso8601String(),
        'lastLogin': u.lastLogin?.toIso8601String(),
        'invitePending': u.invitePending,
      };

  @override
  AppUser fromJson(Map<String, Object?> j) => AppUser(
        id: j['id'] as String,
        email: j['email'] as String,
        passwordHash: j['passwordHash'] as String? ?? '',
        pinHash: j['pinHash'] as String?,
        role: AppRole.values.firstWhere(
          (r) => r.name == j['role'],
          orElse: () => AppRole.technician,
        ),
        employeeId: j['employeeId'] as String?,
        active: (j['active'] as bool?) ?? true,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
        lastLogin: DateTime.tryParse(j['lastLogin'] as String? ?? ''),
        invitePending: (j['invitePending'] as bool?) ?? false,
      );
}
