import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/notification_log_mapper.dart';
import '../domain/notification_log.dart';

final notificationLogStoreProvider =
    Provider<CollectionStore<NotificationLogEntry>>(
  (ref) => CollectionStore<NotificationLogEntry>(
      ref.watch(localStoreProvider), NotificationLogMapper()),
);

/// Journal de communication (messages assistés envoyés aux clients).
class NotificationLogController extends Notifier<List<NotificationLogEntry>> {
  CollectionStore<NotificationLogEntry> get _store =>
      ref.read(notificationLogStoreProvider);

  @override
  List<NotificationLogEntry> build() =>
      _store.loadAll()..sort((a, b) => b.at.compareTo(a.at));

  void add(NotificationLogEntry e) {
    _store.upsert(e);
    state = [e, ...state];
  }

  List<NotificationLogEntry> forRepair(String repairRef) =>
      state.where((e) => e.repairRef == repairRef).toList();

  List<NotificationLogEntry> forClient(String clientId) =>
      state.where((e) => e.clientId == clientId).toList();
}

final notificationLogProvider =
    NotifierProvider<NotificationLogController, List<NotificationLogEntry>>(
        NotificationLogController.new);
