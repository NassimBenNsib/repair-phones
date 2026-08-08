import '../../../core/data/local_store.dart';
import '../domain/cheque.dart';

/// (Dé)sérialisation d'un [Cheque] pour le stockage local.
class ChequeMapper implements EntityMapper<Cheque> {
  @override
  String get collection => 'cheques';

  @override
  String idOf(Cheque c) => c.id;

  @override
  Map<String, Object?> toJson(Cheque c) => c.toJson();

  @override
  Cheque fromJson(Map<String, Object?> j) => Cheque.fromJson(j);
}
