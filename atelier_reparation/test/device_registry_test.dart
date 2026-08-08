import 'package:atelier_reparation/features/devices/application/device_registry.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:flutter_test/flutter_test.dart';

Repair _r({
  required String ref,
  String device = 'Appareil',
  String client = 'Sofia',
  String? serial,
  String? brand,
  String? model,
  int hoursAgo = 1,
}) =>
    Repair(
      reference: ref,
      device: device,
      kind: DeviceKind.phone,
      client: client,
      status: RepairStatus.inProgress,
      priority: RepairPriority.normal,
      progress: 0,
      updatedLabel: '',
      hoursAgo: hoursAgo,
      serial: serial,
      brand: brand,
      model: model,
    );

void main() {
  test('groups repairs by serial number', () {
    final devices = deriveDevices([
      _r(ref: '#R-1', serial: 'SN1', hoursAgo: 5),
      _r(ref: '#R-2', serial: 'SN1', hoursAgo: 1),
      _r(ref: '#R-3', serial: 'SN2'),
    ]);
    expect(devices.length, 2);
    final sn1 = devices.firstWhere((d) => d.serial == 'SN1');
    expect(sn1.repairs.length, 2);
    // Most recent (smallest hoursAgo) first.
    expect(sn1.lastRepair.reference, '#R-2');
  });

  test('falls back to brand+model+client when no serial', () {
    final devices = deriveDevices([
      _r(ref: '#R-1', brand: 'Apple', model: 'iPhone 13', client: 'Sofia'),
      _r(ref: '#R-2', brand: 'Apple', model: 'iPhone 13', client: 'Sofia'),
      // Same model, different client → different device.
      _r(ref: '#R-3', brand: 'Apple', model: 'iPhone 13', client: 'Lucas'),
    ]);
    expect(devices.length, 2);
    expect(devices.firstWhere((d) => d.client == 'Sofia').repairs.length, 2);
    expect(devices.first.title, 'Apple iPhone 13');
  });
}
