import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _t(int s) => DateTime(2026, 1, 1, 0, 0, s);

SyncDoc _doc(String id, String name, int ts, {bool deleted = false}) =>
    SyncDoc(id, {'id': id, 'name': name}, _t(ts), deleted ? _t(ts) : null);

void main() {
  const cols = ['clients'];

  test('two stores converge through a shared remote (LWW + tombstones)', () {
    final server = InMemoryStore();
    final a = InMemoryStore();
    final b = InMemoryStore();

    SyncEngine engine(LocalStore local) =>
        SyncEngine(local: local, remote: server, collections: cols);

    // A creates c1 (t1), pushes; B pulls.
    a.applyRemote('clients', _doc('c1', 'Sofia', 1));
    engine(a).sync();
    engine(b).sync();
    expect(b.all('clients').single['name'], 'Sofia');

    // Conflicting edits: B at t3 (newer) vs A at t2 (older) → B wins everywhere.
    b.applyRemote('clients', _doc('c1', 'B-edit', 3));
    a.applyRemote('clients', _doc('c1', 'A-edit', 2));
    engine(a).sync();
    engine(b).sync();
    engine(a).sync();
    expect(server.all('clients').single['name'], 'B-edit');
    expect(a.all('clients').single['name'], 'B-edit');
    expect(b.all('clients').single['name'], 'B-edit');

    // A tombstones c1 at t4 → deletion propagates to B and server.
    a.applyRemote('clients', _doc('c1', 'B-edit', 4, deleted: true));
    engine(a).sync();
    engine(b).sync();
    expect(a.all('clients'), isEmpty);
    expect(b.all('clients'), isEmpty);
    expect(server.changesSince('clients', null).single.isDeleted, isTrue);
  });

  test('older remote edit does not overwrite a newer local one', () {
    final server = InMemoryStore();
    final local = InMemoryStore();
    server.applyRemote('clients', _doc('c1', 'old', 1));
    local.applyRemote('clients', _doc('c1', 'new', 5));

    SyncEngine(local: local, remote: server, collections: cols).sync();

    expect(local.all('clients').single['name'], 'new');
    expect(server.all('clients').single['name'], 'new');
  });

  test('NoopRemoteStore leaves local data untouched', () {
    final local = InMemoryStore()..put('clients', 'c1', {'id': 'c1'});
    final res = SyncEngine(
      local: local,
      remote: const NoopRemoteStore(),
      collections: cols,
    ).sync();
    expect(res.pulled, 0);
    expect(local.all('clients').length, 1);
  });
}
