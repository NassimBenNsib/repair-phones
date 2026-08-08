import 'dart:convert';

import 'package:atelier_reparation/core/auth/hashing.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('auth hashing', () {
    test('hashSecret is deterministic and 64-hex (sha256)', () {
      final h = hashSecret('admin');
      expect(h, hashSecret('admin'));
      expect(h.length, 64);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(h), isTrue);
    });

    test('verifySecret round-trips the correct secret', () {
      expect(verifySecret('admin', hashSecret('admin')), isTrue);
    });

    test('verifySecret rejects a wrong secret and null hash', () {
      expect(verifySecret('wrong', hashSecret('admin')), isFalse);
      expect(verifySecret('admin', null), isFalse);
    });

    test('salt is applied (differs from unsalted sha256)', () {
      final unsalted = sha256.convert(utf8.encode('admin')).toString();
      expect(hashSecret('admin'), isNot(unsalted));
    });
  });
}
