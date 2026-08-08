import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../invoices/application/invoices_controller.dart';
import '../data/cheque_mapper.dart';
import '../domain/cheque.dart';

final chequeStoreProvider = Provider<CollectionStore<Cheque>>(
  (ref) => CollectionStore<Cheque>(ref.watch(localStoreProvider), ChequeMapper()),
);

/// Registre des chèques + cycle de vie. Un rejet annule le paiement de facture
/// correspondant (le solde se rouvre).
class ChequesController extends Notifier<List<Cheque>> {
  CollectionStore<Cheque> get _store => ref.read(chequeStoreProvider);

  @override
  List<Cheque> build() => _store.loadAll();

  Cheque? byId(String id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }

  void add(Cheque cheque) {
    _store.upsert(cheque);
    state = [cheque, ...state];
  }

  void _update(Cheque cheque) {
    _store.upsert(cheque);
    state = [for (final c in state) if (c.id == cheque.id) cheque else c];
  }

  void setStatus(String id, ChequeStatus status) {
    final c = byId(id);
    if (c == null) return;
    if (status == ChequeStatus.bounced) {
      bounce(id);
      return;
    }
    _update(c.copyWith(
      status: status,
      depositDate: status == ChequeStatus.deposited && c.depositDate == null
          ? DateTime.now()
          : null,
    ));
  }

  /// Rejette un chèque : statut « rejeté » **et** annulation du paiement de
  /// facture qu'il avait créé (le solde se rouvre).
  void bounce(String id) {
    final c = byId(id);
    if (c == null) return;
    if (c.invoiceId != null && c.paymentId != null) {
      ref
          .read(invoicesProvider.notifier)
          .removePayment(c.invoiceId!, c.paymentId!);
    }
    _update(c.copyWith(status: ChequeStatus.bounced));
  }
}

final chequesProvider =
    NotifierProvider<ChequesController, List<Cheque>>(ChequesController.new);
