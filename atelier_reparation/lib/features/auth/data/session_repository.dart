import 'package:shared_preferences/shared_preferences.dart';

/// Persiste l'identifiant de l'utilisateur connecté.
class SessionRepository {
  SessionRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _kUserId = 'session.userId';

  String? load() => _prefs.getString(_kUserId);
  Future<void> save(String userId) => _prefs.setString(_kUserId, userId);
  Future<void> clear() => _prefs.remove(_kUserId);
}
