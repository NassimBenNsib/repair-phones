import 'local_store.dart';

/// Web → mémoire (le SQLite web/wasm pourra être branché ultérieurement).
Future<LocalStore> openLocalStore() async => InMemoryStore();
