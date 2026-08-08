// Codec QR des réparations : aller-retour et décodage tolérant.

import 'package:atelier_reparation/features/repairs/application/repair_qr_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encode ↔ tryDecode : aller-retour', () {
    for (final ref in ['#R-2026-0001', '#R-2048']) {
      expect(RepairQrCodec.tryDecode(RepairQrCodec.encode(ref)), ref);
    }
  });

  test('tryDecode tolérant : brut, sans #, URL, lien profond', () {
    expect(RepairQrCodec.tryDecode('#R-2026-0001'), '#R-2026-0001');
    expect(RepairQrCodec.tryDecode('R-2026-0001'), '#R-2026-0001');
    expect(RepairQrCodec.tryDecode('  #R-2026-0001  '), '#R-2026-0001');
    expect(RepairQrCodec.tryDecode('https://shop.app/repairs/%23R-2026-0001'),
        '#R-2026-0001');
    expect(RepairQrCodec.tryDecode('atelier://repairs/%23R-2048'), '#R-2048');
  });

  test('tryDecode : charges non reconnues → null', () {
    expect(RepairQrCodec.tryDecode(''), isNull);
    expect(RepairQrCodec.tryDecode('bonjour'), isNull);
    expect(RepairQrCodec.tryDecode('#F-2026-0001'), isNull); // facture, pas répa
  });
}
