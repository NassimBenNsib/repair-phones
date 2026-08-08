import '../../repairs/domain/repair.dart';

/// Un appareil distinct, dérivé des réparations qui le concernent.
class DeviceEntry {
  DeviceEntry({
    required this.key,
    required this.kind,
    required this.brand,
    required this.model,
    required this.serial,
    required this.client,
    required this.clientId,
    required this.repairs,
  });

  final String key;
  final DeviceKind kind;
  final String? brand;
  final String? model;
  final String? serial;
  final String client;
  final String? clientId;
  final List<Repair> repairs; // triées, plus récente en premier

  /// Libellé lisible : marque + modèle si connus, sinon le libellé de la
  /// réparation la plus récente.
  String get title {
    final bm =
        [brand, model].where((s) => s != null && s.isNotEmpty).join(' ');
    return bm.isNotEmpty ? bm : repairs.first.device;
  }

  Repair get lastRepair => repairs.first;
}

/// Construit le registre des appareils à partir des réparations : regroupées
/// par numéro de série quand il existe, sinon par marque+modèle+client.
List<DeviceEntry> deriveDevices(List<Repair> repairs) {
  final groups = <String, List<Repair>>{};
  for (final r in repairs) {
    final key = (r.serial != null && r.serial!.isNotEmpty)
        ? 'sn:${r.serial}'
        : 'dm:${r.brand ?? ''}|${r.model ?? ''}|${r.client}';
    (groups[key] ??= []).add(r);
  }

  final out = <DeviceEntry>[];
  groups.forEach((key, list) {
    list.sort((a, b) => a.hoursAgo.compareTo(b.hoursAgo)); // récent d'abord
    final r = list.first;
    out.add(DeviceEntry(
      key: key,
      kind: r.kind,
      brand: r.brand,
      model: r.model,
      serial: r.serial,
      client: r.client,
      clientId: r.clientId,
      repairs: list,
    ));
  });
  out.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return out;
}
