import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/domain/numbering.dart';
import '../data/quote_mapper.dart';
import '../domain/quote.dart';

final quoteStoreProvider = Provider<CollectionStore<Quote>>(
  (ref) => CollectionStore<Quote>(ref.watch(localStoreProvider), QuoteMapper()),
);

/// Devis, adossés au stockage local.
class QuotesController extends Notifier<List<Quote>> {
  CollectionStore<Quote> get _store => ref.read(quoteStoreProvider);
  int _seq = 0;

  @override
  List<Quote> build() => _store.loadAll();

  String _id() => 'q-${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  Quote create({required String clientId, required String clientName}) {
    final number =
        ref.read(numberingProvider).next('DEVIS', DateTime.now().year);
    final q = Quote(
      id: _id(),
      number: number,
      clientId: clientId,
      clientName: clientName,
      date: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 30)),
    );
    _store.upsert(q);
    state = [q, ...state];
    return q;
  }

  void update(Quote q) {
    _store.upsert(q);
    state = [for (final x in state) if (x.id == q.id) q else x];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final x in state) if (x.id != id) x];
  }

  Quote? byId(String id) {
    for (final q in state) {
      if (q.id == id) return q;
    }
    return null;
  }

  void addLine(String id, LineItem line) {
    final q = byId(id);
    if (q != null) update(q.copyWith(lines: [...q.lines, line]));
  }

  void updateLine(String id, LineItem line) {
    final q = byId(id);
    if (q == null) return;
    update(q.copyWith(
        lines: [for (final l in q.lines) if (l.id == line.id) line else l]));
  }

  void removeLine(String id, String lineId) {
    final q = byId(id);
    if (q == null) return;
    update(q.copyWith(lines: [for (final l in q.lines) if (l.id != lineId) l]));
  }

  void setStatus(String id, QuoteStatus status) {
    final q = byId(id);
    if (q != null) update(q.copyWith(status: status));
  }
}

final quotesProvider =
    NotifierProvider<QuotesController, List<Quote>>(QuotesController.new);
