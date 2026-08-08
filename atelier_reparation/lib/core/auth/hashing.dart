import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Hachage local (SHA-256 + sel applicatif).
///
/// Note : suffisant pour un usage local hors-ligne ; pour du multi-poste
/// serveur, préférer un hachage lent (bcrypt/argon2) côté backend.
const _salt = 'atelier-reparation::v1::';

String hashSecret(String value) =>
    sha256.convert(utf8.encode('$_salt$value')).toString();

bool verifySecret(String value, String? hash) =>
    hash != null && hashSecret(value) == hash;
