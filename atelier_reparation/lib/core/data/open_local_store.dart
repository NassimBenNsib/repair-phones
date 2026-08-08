// Ouvre le LocalStore persistant adapté à la plateforme :
// SQLite sur natif (Windows / macOS / Linux / mobile), mémoire sur le Web.
export 'open_local_store_io.dart'
    if (dart.library.html) 'open_local_store_web.dart';
