import 'package:flutter/foundation.dart';

/// Identité de l'établissement, imprimée en en-tête des documents légaux
/// (devis, factures).
@immutable
class CompanyProfile {
  const CompanyProfile({
    this.name = '',
    this.address = '',
    this.postalCode = '',
    this.city = '',
    this.phone = '',
    this.email = '',
    this.vatNumber = '',
    this.siret = '',
    this.logo = '',
  });

  static const String docId = 'default';

  final String name;
  final String address;
  final String postalCode;
  final String city;
  final String phone;
  final String email;
  final String vatNumber;
  final String siret;

  /// Logo encodé en base64 (PNG/JPG) ; vide si absent.
  final String logo;

  bool get hasLogo => logo.isNotEmpty;

  bool get isEmpty => name.isEmpty && address.isEmpty && phone.isEmpty;

  /// Lignes secondaires (adresse, contact, identifiants) pour l'en-tête PDF.
  List<String> get headerLines {
    final cityLine = [postalCode, city].where((s) => s.isNotEmpty).join(' ');
    return [
      if (address.isNotEmpty) address,
      if (cityLine.isNotEmpty) cityLine,
      if (phone.isNotEmpty) phone,
      if (email.isNotEmpty) email,
      if (vatNumber.isNotEmpty) 'TVA $vatNumber',
      if (siret.isNotEmpty) 'SIRET $siret',
    ];
  }

  CompanyProfile copyWith({
    String? name,
    String? address,
    String? postalCode,
    String? city,
    String? phone,
    String? email,
    String? vatNumber,
    String? siret,
    String? logo,
  }) =>
      CompanyProfile(
        name: name ?? this.name,
        address: address ?? this.address,
        postalCode: postalCode ?? this.postalCode,
        city: city ?? this.city,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        vatNumber: vatNumber ?? this.vatNumber,
        siret: siret ?? this.siret,
        logo: logo ?? this.logo,
      );

  Map<String, Object?> toJson() => {
        'id': docId,
        'name': name,
        'address': address,
        'postalCode': postalCode,
        'city': city,
        'phone': phone,
        'email': email,
        'vatNumber': vatNumber,
        'siret': siret,
        'logo': logo,
      };

  factory CompanyProfile.fromJson(Map<String, Object?> j) => CompanyProfile(
        name: j['name'] as String? ?? '',
        address: j['address'] as String? ?? '',
        postalCode: j['postalCode'] as String? ?? '',
        city: j['city'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String? ?? '',
        vatNumber: j['vatNumber'] as String? ?? '',
        siret: j['siret'] as String? ?? '',
        logo: j['logo'] as String? ?? '',
      );
}
