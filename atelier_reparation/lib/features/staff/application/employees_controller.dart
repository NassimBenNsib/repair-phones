import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/employee_mapper.dart';
import '../domain/employee.dart';

final employeeStoreProvider = Provider<CollectionStore<Employee>>(
  (ref) =>
      CollectionStore<Employee>(ref.watch(localStoreProvider), EmployeeMapper()),
);

/// Employés, adossés au stockage local (SQLite / mémoire).
class EmployeesController extends Notifier<List<Employee>> {
  CollectionStore<Employee> get _store => ref.read(employeeStoreProvider);

  @override
  List<Employee> build() {
    _store.seedIfEmpty(sampleEmployees);
    return _store.loadAll();
  }

  void add(Employee e) {
    _store.upsert(e);
    state = [e, ...state];
  }

  void update(Employee e) {
    _store.upsert(e);
    state = [for (final x in state) if (x.id == e.id) e else x];
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final x in state) if (x.id != id) x];
  }
}

final employeesProvider =
    NotifierProvider<EmployeesController, List<Employee>>(EmployeesController.new);
