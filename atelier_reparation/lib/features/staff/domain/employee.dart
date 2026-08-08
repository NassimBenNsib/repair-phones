import 'package:flutter/foundation.dart';

/// Employé de l'atelier (la personne — distincte d'un compte utilisateur).
@immutable
class Employee {
  const Employee({
    required this.id,
    required this.name,
    this.jobTitle,
    required this.phone,
    this.email,
    this.hireDate,
    this.commissionRate = 0,
    this.active = true,
    this.userId,
  });

  final String id;
  final String name;
  final String? jobTitle;
  final String phone;
  final String? email;
  final DateTime? hireDate;

  /// Taux de commission 0..1.
  final double commissionRate;
  final bool active;

  /// Lien facultatif vers un compte utilisateur (module Users).
  final String? userId;

  Employee copyWith({
    String? name,
    String? jobTitle,
    String? phone,
    String? email,
    DateTime? hireDate,
    double? commissionRate,
    bool? active,
    String? userId,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hireDate: hireDate ?? this.hireDate,
      commissionRate: commissionRate ?? this.commissionRate,
      active: active ?? this.active,
      userId: userId ?? this.userId,
    );
  }
}

final List<Employee> sampleEmployees = [
  Employee(
    id: 'seed-karim',
    name: 'Karim B.',
    jobTitle: 'Technicien senior',
    phone: '+33 6 45 12 78 90',
    email: 'karim@atelier.fr',
    hireDate: DateTime(2022, 3, 14),
    commissionRate: 0.10,
  ),
  Employee(
    id: 'seed-lea',
    name: 'Léa M.',
    jobTitle: 'Accueil / Caisse',
    phone: '+33 6 78 90 12 34',
    email: 'lea@atelier.fr',
    hireDate: DateTime(2023, 9, 1),
    commissionRate: 0.05,
  ),
  Employee(
    id: 'seed-yanis',
    name: 'Yanis T.',
    jobTitle: 'Technicien',
    phone: '+33 6 11 22 33 44',
    hireDate: DateTime(2024, 1, 8),
    active: false,
  ),
];
