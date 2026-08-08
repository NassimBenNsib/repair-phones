import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/domain/repair.dart';
import '../../repairs/presentation/repair_detail.dart';
import '../application/device_registry.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  static const String routeName = 'devices';
  static const String routePath = '/devices';

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final devices = deriveDevices(ref.watch(repairsProvider));
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? devices
        : devices
            .where((d) =>
                d.title.toLowerCase().contains(q) ||
                d.client.toLowerCase().contains(q) ||
                (d.serial ?? '').toLowerCase().contains(q))
            .toList();

    return AppleScaffold(
      title: l.navDevices,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
                hintText: l.devicesSearch,
                onChanged: (v) => setState(() => _query = v)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: shown.isEmpty
                ? _Empty(l: l)
                : AppleListSection(
                    children: [
                      for (final d in shown)
                        AppleListRow(
                          leadingIcon: d.kind.icon,
                          leadingTint: context.accentColor,
                          title: d.title,
                          subtitle:
                              '${d.client} · ${d.repairs.length} ${l.deviceRepairs}',
                          showChevron: true,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DeviceDetailScreen(deviceKey: d.key))),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

/// Détail d'un appareil : identité + propriétaire + historique de réparations.
class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({super.key, required this.deviceKey});
  final String deviceKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    final devices = deriveDevices(ref.watch(repairsProvider));
    DeviceEntry? d;
    for (final e in devices) {
      if (e.key == deviceKey) {
        d = e;
        break;
      }
    }

    Widget body;
    if (d == null) {
      body = Center(
        child: Text(l.devicesEmpty,
            style: AppleTypography.body.copyWith(color: colors.secondaryLabel)),
      );
    } else {
      final device = d;
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AppleCard(
            elevated: true,
            child: Row(
              children: [
                Icon(device.kind.icon, size: 34, color: context.accentColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.title,
                          style: AppleTypography.title3
                              .copyWith(color: colors.label)),
                      Text(device.client,
                          style: AppleTypography.subheadline
                              .copyWith(color: colors.secondaryLabel)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SectionHeader(
              title: l.deviceIdentity,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleListSection(
            children: [
              if (device.serial != null && device.serial!.isNotEmpty)
                AppleListRow(
                    title: l.deviceSerial, trailingText: device.serial!),
              if (device.lastRepair.warrantyMonths != null)
                AppleListRow(
                    title: l.deviceWarranty,
                    trailingText: '${device.lastRepair.warrantyMonths} mois'),
              AppleListRow(title: l.deviceOwner, trailingText: device.client),
            ],
          ),

          SectionHeader(
              title: l.deviceHistory,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleListSection(
            children: [
              for (final r in device.repairs)
                AppleListRow(
                  title: r.reference,
                  subtitle: r.device,
                  trailingText: r.status.label(l),
                  showChevron: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          RepairDetailScreen(reference: r.reference))),
                ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(context.backIcon, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(d?.title ?? l.navDevices),
      ),
      body: body,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.devices_outlined, size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.devicesEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          const SizedBox(height: 4),
          Text(l.devicesEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
        ],
      ),
    );
  }
}
