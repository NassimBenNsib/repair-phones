import '../../../core/data/local_store.dart';
import '../domain/client.dart';
import '../domain/client_address.dart';
import '../domain/contact_channel.dart';

/// (Dé)sérialisation d'un [Client] pour le stockage local.
class ClientMapper implements EntityMapper<Client> {
  @override
  String get collection => 'clients';

  @override
  String idOf(Client c) => c.id;

  @override
  Map<String, Object?> toJson(Client c) => {
        'id': c.id,
        'type': c.type.name,
        'name': c.name,
        'companyName': c.companyName,
        'vatNumber': c.vatNumber,
        'phone': c.phone,
        'email': c.email,
        'address': c.address,
        'city': c.city,
        'notes': c.notes,
        'channels': [for (final ch in c.channels) ch.toJson()],
        'addresses': [for (final a in c.addresses) a.toJson()],
        'createdAt': c.createdAt?.toIso8601String(),
        'tags': c.tags,
        'marketingConsent': c.marketingConsent,
        'siret': c.siret,
        'billingContact': c.billingContact,
        'paymentTerms': c.paymentTerms,
        'discountRate': c.discountRate,
        'creditLimit': c.creditLimit,
      };

  @override
  Client fromJson(Map<String, Object?> j) => Client(
        id: j['id'] as String,
        type: ClientType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => ClientType.individual,
        ),
        name: j['name'] as String,
        companyName: j['companyName'] as String?,
        vatNumber: j['vatNumber'] as String?,
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String?,
        address: j['address'] as String?,
        city: j['city'] as String?,
        notes: j['notes'] as String?,
        channels: _channels(j),
        addresses: [
          for (final a in (j['addresses'] as List? ?? const []))
            ClientAddress.fromJson(Map<String, Object?>.from(a as Map)),
        ],
        createdAt: j['createdAt'] == null
            ? null
            : DateTime.tryParse(j['createdAt'] as String),
        tags: [for (final t in (j['tags'] as List? ?? const [])) t.toString()],
        marketingConsent: (j['marketingConsent'] as bool?) ?? false,
        siret: j['siret'] as String?,
        billingContact: j['billingContact'] as String?,
        paymentTerms: j['paymentTerms'] as String?,
        discountRate: (j['discountRate'] as num?)?.toDouble() ?? 0,
        creditLimit: (j['creditLimit'] as num?)?.toDouble(),
      );

  /// Lit la liste `channels` et absorbe d'éventuels champs hérités
  /// (whatsapp/telegram/…) sauvegardés par une version antérieure.
  static List<ContactChannel> _channels(Map<String, Object?> j) {
    final out = [
      for (final c in (j['channels'] as List? ?? const []))
        ContactChannel.fromJson(Map<String, Object?>.from(c as Map)),
    ];
    void legacy(String key, ContactKind kind) {
      final v = j[key] as String?;
      if (v != null && v.isNotEmpty) out.add(ContactChannel(kind: kind, value: v));
    }

    legacy('secondaryPhone', ContactKind.mobile);
    legacy('whatsapp', ContactKind.whatsapp);
    legacy('telegram', ContactKind.telegram);
    legacy('website', ContactKind.website);
    legacy('instagram', ContactKind.instagram);
    return out;
  }
}
