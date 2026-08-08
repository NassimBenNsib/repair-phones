import 'package:flutter/foundation.dart';

import '../../../core/auth/hashing.dart';
import '../../../core/auth/permissions.dart';

/// Compte utilisateur (identité de connexion) — distinct de l'employé.
@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.passwordHash,
    this.pinHash,
    this.role = AppRole.technician,
    this.employeeId,
    this.active = true,
    this.createdAt,
    this.lastLogin,
    this.invitePending = false,
  });

  final String id;
  final String email;
  final String passwordHash;
  final String? pinHash;
  final AppRole role;
  final String? employeeId;
  final bool active;

  /// Date de création du compte (traçabilité).
  final DateTime? createdAt;

  /// Dernière connexion réussie.
  final DateTime? lastLogin;

  /// Invitation envoyée mais compte pas encore activé (démo).
  final bool invitePending;

  bool can(Permission p) => role.can(p);

  AppUser copyWith({
    String? email,
    String? passwordHash,
    String? pinHash,
    AppRole? role,
    String? employeeId,
    bool? active,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? invitePending,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      pinHash: pinHash ?? this.pinHash,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      invitePending: invitePending ?? this.invitePending,
    );
  }
}

/// Compte administrateur par défaut (première exécution).
/// Identifiants : admin@atelier.fr / mot de passe « admin » / PIN « 0000 ».
final List<AppUser> seedUsers = [
  AppUser(
    id: 'seed-admin',
    email: 'admin@atelier.fr',
    passwordHash: hashSecret('admin'),
    pinHash: hashSecret('0000'),
    role: AppRole.admin,
  ),
];
