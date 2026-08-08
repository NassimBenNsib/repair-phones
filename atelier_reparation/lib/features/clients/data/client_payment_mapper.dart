import '../../../core/data/local_store.dart';
import '../domain/client_payment.dart';

/// (Dé)sérialisation d'une écriture de compte client.
class ClientPaymentMapper implements EntityMapper<ClientPayment> {
  @override
  String get collection => 'client_payments';

  @override
  String idOf(ClientPayment p) => p.id;

  @override
  Map<String, Object?> toJson(ClientPayment p) => p.toJson();

  @override
  ClientPayment fromJson(Map<String, Object?> j) => ClientPayment.fromJson(j);
}
