import '../../../core/data/local_store.dart';
import '../domain/supplier.dart';

/// (Dé)sérialisation d'un [Supplier] pour le stockage local.
class SupplierMapper implements EntityMapper<Supplier> {
  @override
  String get collection => 'suppliers';

  @override
  String idOf(Supplier s) => s.id;

  @override
  Map<String, Object?> toJson(Supplier s) => {
        'id': s.id,
        'type': s.type.name,
        'name': s.name,
        'contactName': s.contactName,
        'phone': s.phone,
        'email': s.email,
        'address': s.address,
        'city': s.city,
        'vatNumber': s.vatNumber,
        'paymentTerms': s.paymentTerms,
        'notes': s.notes,
      };

  @override
  Supplier fromJson(Map<String, Object?> j) => Supplier(
        id: j['id'] as String,
        type: SupplierType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => SupplierType.company,
        ),
        name: j['name'] as String,
        contactName: j['contactName'] as String?,
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String?,
        address: j['address'] as String?,
        city: j['city'] as String?,
        vatNumber: j['vatNumber'] as String?,
        paymentTerms: j['paymentTerms'] as String?,
        notes: j['notes'] as String?,
      );
}
