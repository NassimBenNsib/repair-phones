import 'package:flutter/foundation.dart';

import '../../../l10n/app_localizations.dart';
import 'client_address.dart';
import 'contact_channel.dart';

/// Type de client.
enum ClientType { individual, company }

extension ClientTypeX on ClientType {
  String label(AppLocalizations l) => this == ClientType.company
      ? l.clientTypeCompany
      : l.clientTypeIndividual;
}

/// Client de l'atelier.
@immutable
class Client {
  const Client({
    required this.id,
    this.type = ClientType.individual,
    required this.name,
    this.companyName,
    this.vatNumber,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.notes,
    this.channels = const [],
    this.addresses = const [],
    this.createdAt,
    this.tags = const [],
    this.marketingConsent = false,
    this.siret,
    this.billingContact,
    this.paymentTerms,
    this.discountRate = 0,
    this.creditLimit,
  });

  final String id;
  final ClientType type;
  final String name;
  final String? companyName;
  final String? vatNumber;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? notes;

  /// Canaux de contact additionnels et typés (numéros, WhatsApp, Telegram,
  /// site web…), choisis par l'utilisateur.
  final List<ContactChannel> channels;

  /// Adresses supplémentaires typées (domicile, travail, facturation…) en plus
  /// de l'[address] principale.
  final List<ClientAddress> addresses;

  /// Date de création de la fiche (client depuis…).
  final DateTime? createdAt;

  /// Étiquettes libres pour segmenter (VIP, pro, garantie…).
  final List<String> tags;

  /// Consentement marketing (RGPD).
  final bool marketingConsent;

  // Conditions commerciales B2B (clients « société »).
  final String? siret;
  final String? billingContact;
  final String? paymentTerms; // ex. « 30 jours net »
  final double discountRate; // remise habituelle (0..1)
  final double? creditLimit;

  bool get isCompany => type == ClientType.company;

  String get displayName =>
      (companyName != null && companyName!.isNotEmpty) ? companyName! : name;

  /// Vrai si [label] correspond au nom affiché ou au nom civil du client.
  ///
  /// Sert de repli pour relier les réparations liées par libellé (données
  /// héritées sans `clientId`), en couvrant les clients « société ».
  bool matchesLabel(String label) => label == displayName || label == name;

  Client copyWith({
    ClientType? type,
    String? name,
    String? companyName,
    String? vatNumber,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? notes,
    List<ContactChannel>? channels,
    List<ClientAddress>? addresses,
    List<String>? tags,
    bool? marketingConsent,
    String? siret,
    String? billingContact,
    String? paymentTerms,
    double? discountRate,
    double? creditLimit,
  }) {
    return Client(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      vatNumber: vatNumber ?? this.vatNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      channels: channels ?? this.channels,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt,
      tags: tags ?? this.tags,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      siret: siret ?? this.siret,
      billingContact: billingContact ?? this.billingContact,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      discountRate: discountRate ?? this.discountRate,
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }
}

const sampleClients = <Client>[
  Client(
    id: 'seed-sofia',
    name: 'Sofia Haddad',
    phone: '+33 6 12 34 56 78',
    email: 'sofia.haddad@email.fr',
    address: '12 rue des Lilas, 75011 Paris',
    city: 'Paris',
  ),
  Client(
    id: 'seed-lucas',
    name: 'Lucas Martin',
    phone: '+33 6 98 76 54 32',
    email: 'lucas.martin@email.fr',
    address: '5 avenue Victor Hugo, 69002 Lyon',
    city: 'Lyon',
  ),
  Client(
    id: 'seed-emma',
    type: ClientType.company,
    name: 'Emma Dubois',
    companyName: 'Dubois Informatique',
    vatNumber: 'FR12345678901',
    phone: '+33 7 11 22 33 44',
    email: 'contact@dubois-info.fr',
    address: '28 boulevard Gambetta, 33000 Bordeaux',
    city: 'Bordeaux',
    channels: [
      ContactChannel(kind: ContactKind.landline, value: '+33 5 56 00 11 22'),
      ContactChannel(kind: ContactKind.telegram, value: '@dubois_info'),
      ContactChannel(kind: ContactKind.website, value: 'dubois-info.fr'),
      ContactChannel(kind: ContactKind.instagram, value: '@dubois.informatique'),
    ],
  ),
  Client(
    id: 'seed-noah',
    name: 'Noah Bernard',
    phone: '+33 6 55 44 33 22',
    email: 'noah.bernard@email.fr',
    address: '3 place de la République, 44000 Nantes',
    city: 'Nantes',
  ),
  Client(
    id: 'seed-chloe',
    name: 'Chloé Petit',
    phone: '+33 7 66 77 88 99',
    email: 'chloe.petit@email.fr',
    address: '17 rue Sainte-Catherine, 31000 Toulouse',
    city: 'Toulouse',
  ),
];
