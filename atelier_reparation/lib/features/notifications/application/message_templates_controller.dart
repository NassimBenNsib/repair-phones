import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/message_template_mapper.dart';
import '../domain/message_template.dart';

final messageTemplateStoreProvider =
    Provider<CollectionStore<MessageTemplate>>(
  (ref) => CollectionStore<MessageTemplate>(
      ref.watch(localStoreProvider), MessageTemplateMapper()),
);

/// Modèles de messages, adossés au stockage local.
class MessageTemplatesController extends Notifier<List<MessageTemplate>> {
  CollectionStore<MessageTemplate> get _store =>
      ref.read(messageTemplateStoreProvider);

  @override
  List<MessageTemplate> build() {
    _store.seedIfEmpty(seedMessageTemplates);
    return _store.loadAll()..sort((a, b) => a.order.compareTo(b.order));
  }

  MessageTemplate? byId(String id) {
    for (final t in state) {
      if (t.id == id) return t;
    }
    return null;
  }

  void add(MessageTemplate t) {
    _store.upsert(t);
    state = [...state, t]..sort((a, b) => a.order.compareTo(b.order));
  }

  void update(MessageTemplate t) {
    _store.upsert(t);
    state = [for (final x in state) if (x.id == t.id) t else x]
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final t in state) if (t.id != id) t];
  }
}

final messageTemplatesProvider =
    NotifierProvider<MessageTemplatesController, List<MessageTemplate>>(
        MessageTemplatesController.new);
