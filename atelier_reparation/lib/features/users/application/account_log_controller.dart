import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../auth/application/session_controller.dart';
import '../data/account_event_mapper.dart';
import '../domain/account_event.dart';

final accountEventStoreProvider = Provider<CollectionStore<AccountEvent>>(
  (ref) => CollectionStore<AccountEvent>(
      ref.watch(localStoreProvider), AccountEventMapper()),
);

/// Journal des comptes : trace « qui a fait quoi » (connexions, créations,
/// modifications, réinitialisations…). Persisté localement, semé de données de
/// démonstration au premier lancement.
class AccountLogController extends Notifier<List<AccountEvent>> {
  CollectionStore<AccountEvent> get _store => ref.read(accountEventStoreProvider);

  @override
  List<AccountEvent> build() {
    _store.seedIfEmpty(_seed());
    final all = _store.loadAll()..sort((a, b) => b.at.compareTo(a.at));
    return all;
  }

  /// Ajoute une entrée (acteur = utilisateur de la session courante).
  void record(AccountEventKind kind,
      {String? targetId, String? targetEmail, String? detail}) {
    final actor = ref.read(sessionControllerProvider.notifier).currentUser;
    final e = AccountEvent(
      id: const Uuid().v4(),
      at: DateTime.now(),
      kind: kind,
      actorId: actor?.id,
      actorEmail: actor?.email ?? '',
      targetId: targetId,
      targetEmail: targetEmail,
      detail: detail,
    );
    _store.upsert(e);
    state = [e, ...state];
  }

  /// Événements concernant [userId] (comme cible ou acteur), du plus récent.
  List<AccountEvent> forUser(String userId) =>
      state.where((e) => e.targetId == userId || e.actorId == userId).toList();

  /// Données de démonstration (journal non vide dès le premier lancement).
  List<AccountEvent> _seed() {
    final now = DateTime.now();
    AccountEvent ev(int minsAgo, AccountEventKind k, {String? detail}) =>
        AccountEvent(
          id: const Uuid().v4(),
          at: now.subtract(Duration(minutes: minsAgo)),
          kind: k,
          actorId: 'seed-admin',
          actorEmail: 'admin@atelier.fr',
          targetId: 'seed-admin',
          targetEmail: 'admin@atelier.fr',
          detail: detail,
        );
    return [
      ev(3, AccountEventKind.login),
      ev(60 * 5, AccountEventKind.updated),
      ev(60 * 26, AccountEventKind.login),
      ev(60 * 27, AccountEventKind.failedLogin),
      ev(60 * 24 * 3, AccountEventKind.passwordReset),
      ev(60 * 24 * 7, AccountEventKind.created),
    ];
  }
}

final accountLogProvider =
    NotifierProvider<AccountLogController, List<AccountEvent>>(
        AccountLogController.new);
