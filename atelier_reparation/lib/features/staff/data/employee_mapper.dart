import '../../../core/data/local_store.dart';
import '../domain/employee.dart';

/// (Dé)sérialisation d'un [Employee] pour le stockage local.
class EmployeeMapper implements EntityMapper<Employee> {
  @override
  String get collection => 'employees';

  @override
  String idOf(Employee e) => e.id;

  @override
  Map<String, Object?> toJson(Employee e) => {
        'id': e.id,
        'name': e.name,
        'jobTitle': e.jobTitle,
        'phone': e.phone,
        'email': e.email,
        'hireDate': e.hireDate?.toIso8601String(),
        'commissionRate': e.commissionRate,
        'active': e.active,
        'userId': e.userId,
      };

  @override
  Employee fromJson(Map<String, Object?> j) => Employee(
        id: j['id'] as String,
        name: j['name'] as String,
        jobTitle: j['jobTitle'] as String?,
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String?,
        hireDate: j['hireDate'] == null
            ? null
            : DateTime.tryParse(j['hireDate'] as String),
        commissionRate: (j['commissionRate'] as num?)?.toDouble() ?? 0,
        active: (j['active'] as bool?) ?? true,
        userId: j['userId'] as String?,
      );
}
