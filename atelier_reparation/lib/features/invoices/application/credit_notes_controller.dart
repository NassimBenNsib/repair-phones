import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/numbering.dart';
import '../data/credit_note_mapper.dart';
import '../domain/credit_note.dart';

final creditNoteStoreProvider = Provider<CollectionStore<CreditNote>>(
  (ref) =>
      CollectionStore<CreditNote>(ref.watch(localStoreProvider), CreditNoteMapper()),
);

/// Avoirs (notes de crédit) : brouillon → émission (numéro légal `AVOIR-…`).
class CreditNotesController extends Notifier<List<CreditNote>> {
  CollectionStore<CreditNote> get _store => ref.read(creditNoteStoreProvider);
  int _seq = 0;

  @override
  List<CreditNote> build() => _store.loadAll();

  String _id() => 'av-${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  /// Crée un avoir brouillon (numéro attribué à l'émission).
  CreditNote createFrom({
    required String clientId,
    required String clientName,
    String? invoiceId,
    List<LineItem> lines = const [],
    double taxRate = 0.20,
    String? reason,
  }) {
    final cn = CreditNote(
      id: _id(),
      clientId: clientId,
      clientName: clientName,
      invoiceId: invoiceId,
      date: DateTime.now(),
      lines: lines,
      taxRate: taxRate,
      reason: reason,
    );
    _store.upsert(cn);
    state = [cn, ...state];
    return cn;
  }

  void update(CreditNote c) {
    _store.upsert(c);
    state = [for (final x in state) if (x.id == c.id) c else x];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final x in state) if (x.id != id) x];
  }

  CreditNote? byId(String id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Émet l'avoir : numéro légal séquentiel immuable (`AVOIR-<année>-####`).
  void issue(String id, {DateTime? now}) {
    final c = byId(id);
    if (c == null || c.isIssued) return;
    final ts = now ?? DateTime.now();
    final number = ref.read(numberingProvider).next('AVOIR', ts.year);
    update(c.copyWith(
        number: number, status: CreditNoteStatus.issued, issueDate: ts));
  }

  List<CreditNote> forClient(String clientId) =>
      state.where((c) => c.clientId == clientId).toList();
}

final creditNotesProvider =
    NotifierProvider<CreditNotesController, List<CreditNote>>(
        CreditNotesController.new);
