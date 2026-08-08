import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Type d'une adresse client (domicile, travail, facturation…).
enum AddressKind { home, work, billing, shipping, other }

extension AddressKindX on AddressKind {
  String label(AppLocalizations l) => switch (this) {
        AddressKind.home => l.addressKindHome,
        AddressKind.work => l.addressKindWork,
        AddressKind.billing => l.addressKindBilling,
        AddressKind.shipping => l.addressKindShipping,
        AddressKind.other => l.addressKindOther,
      };

  IconData get icon => switch (this) {
        AddressKind.home => Icons.home_outlined,
        AddressKind.work => Icons.business_outlined,
        AddressKind.billing => Icons.receipt_long_outlined,
        AddressKind.shipping => Icons.local_shipping_outlined,
        AddressKind.other => Icons.location_on_outlined,
      };
}

/// Une adresse supplémentaire : un type + le texte de l'adresse.
@immutable
class ClientAddress {
  const ClientAddress({required this.kind, required this.value});

  final AddressKind kind;
  final String value;

  ClientAddress copyWith({AddressKind? kind, String? value}) =>
      ClientAddress(kind: kind ?? this.kind, value: value ?? this.value);

  Map<String, Object?> toJson() => {'kind': kind.name, 'value': value};

  factory ClientAddress.fromJson(Map<String, Object?> j) => ClientAddress(
        kind: AddressKind.values.firstWhere(
          (k) => k.name == j['kind'],
          orElse: () => AddressKind.other,
        ),
        value: j['value'] as String? ?? '',
      );
}
