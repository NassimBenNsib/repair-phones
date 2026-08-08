/// Encode/décode la charge utile du QR d'une réparation.
///
/// Source unique partagée par l'écriture (fiche Pro + ticket) et la lecture
/// (scanner, H4). Le décodage est **tolérant** : il accepte la référence brute
/// (`#R-2026-0001`), une URL ou un lien profond la contenant, avec ou sans `#`.
class RepairQrCodec {
  const RepairQrCodec._();

  /// Une référence de réparation : `#R-2048` (historique) ou `#R-2026-0001`.
  static final RegExp _ref = RegExp(r'^#R-[0-9]');

  /// Donnée écrite dans le QR (référence canonique).
  static String encode(String reference) => reference.trim();

  /// Relit une charge utile → référence, ou `null` si non reconnue.
  static String? tryDecode(String payload) {
    var s = payload.trim();
    if (s.isEmpty) return null;

    // URL / lien profond → dernier segment de chemin.
    final uri = Uri.tryParse(s);
    if (uri != null && (uri.hasScheme || s.contains('/'))) {
      final segs = uri.pathSegments.where((e) => e.isNotEmpty).toList();
      if (segs.isNotEmpty) s = segs.last;
    }

    s = _decode(s).trim();
    if (!s.startsWith('#')) s = '#$s';
    return _ref.hasMatch(s) ? s : null;
  }

  static String _decode(String v) {
    try {
      return Uri.decodeComponent(v);
    } catch (_) {
      return v; // charge malformée → on garde tel quel
    }
  }
}
