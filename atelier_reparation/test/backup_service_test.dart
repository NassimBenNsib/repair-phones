import 'package:atelier_reparation/core/backup/backup_service.dart';
import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backup export → import round-trips into a fresh store', () {
    final source = InMemoryStore();
    // Clients keyed by 'id', repairs keyed by 'reference'.
    source.put('clients', 'c1', {'id': 'c1', 'name': 'Sofia'});
    source.put('repairs', '#R-1', {'reference': '#R-1', 'device': 'iPhone'});
    source.put('invoices', 'i1', {'id': 'i1', 'number': 'FACT-2026-0001'});

    final json = BackupService(source).exportJson();

    final target = InMemoryStore();
    final imported = BackupService(target).importJson(json);

    expect(imported, 3);
    expect(target.all('clients').single['name'], 'Sofia');
    expect(target.all('repairs').single['reference'], '#R-1');
    expect(target.all('invoices').single['number'], 'FACT-2026-0001');
  });

  test('idField uses reference for repairs, id otherwise', () {
    expect(BackupService.idField('repairs'), 'reference');
    expect(BackupService.idField('clients'), 'id');
    expect(BackupService.idField('invoices'), 'id');
  });
}
