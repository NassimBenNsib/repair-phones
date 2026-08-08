import 'package:flutter/foundation.dart';

import '../../../l10n/app_localizations.dart';

/// Type de fournisseur.
enum SupplierType { company, individual }

extension SupplierTypeX on SupplierType {
  String label(AppLocalizations l) => this == SupplierType.company
      ? l.supplierTypeCompany
      : l.supplierTypeIndividual;
}

/// Fournisseur de pièces / services.
@immutable
class Supplier {
  const Supplier({
    required this.id,
    this.type = SupplierType.company,
    required this.name,
    this.contactName,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.vatNumber,
    this.paymentTerms,
    this.notes,
  });

  final String id;
  final SupplierType type;
  final String name;
  final String? contactName;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? vatNumber;
  final String? paymentTerms;
  final String? notes;

  bool get isCompany => type == SupplierType.company;

  Supplier copyWith({
    SupplierType? type,
    String? name,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? vatNumber,
    String? paymentTerms,
    String? notes,
  }) {
    return Supplier(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      vatNumber: vatNumber ?? this.vatNumber,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
    );
  }
}

const sampleSuppliers = <Supplier>[
  Supplier(
    id: 'seed-mobileparts',
    name: 'MobileParts Pro',
    contactName: 'Julien Faure',
    phone: '+33 1 84 25 36 47',
    email: 'contact@mobileparts.fr',
    address: '14 rue de l\'Industrie, 93100 Montreuil',
    city: 'Montreuil',
    vatNumber: 'FR40123456789',
    paymentTerms: '30 jours net',
  ),
  Supplier(
    id: 'seed-ifixfr',
    name: 'iFix France',
    contactName: 'Sarah Benali',
    phone: '+33 4 72 10 20 30',
    email: 'pro@ifix.fr',
    address: '8 quai Perrache, 69002 Lyon',
    city: 'Lyon',
    vatNumber: 'FR60987654321',
    paymentTerms: '45 jours',
  ),
  Supplier(
    id: 'seed-accessoires',
    type: SupplierType.individual,
    name: 'Accessoires Express',
    phone: '+33 6 22 33 44 55',
    email: 'accessoires.express@email.fr',
    city: 'Marseille',
    paymentTerms: 'Comptant',
  ),
];
