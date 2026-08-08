import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../domain/repair.dart';

/// Filtres secondaires appliqués à la liste des réparations.
@immutable
class RepairFilters {
  const RepairFilters({this.priority, this.device, this.activeOnly = false});

  final RepairPriority? priority;
  final DeviceKind? device;
  final bool activeOnly;

  /// Nombre de filtres actifs (pour le badge du bouton « Filtres »).
  int get activeCount =>
      (priority != null ? 1 : 0) +
      (device != null ? 1 : 0) +
      (activeOnly ? 1 : 0);

  RepairFilters copyWith({
    RepairPriority? priority,
    DeviceKind? device,
    bool? activeOnly,
    bool clearPriority = false,
    bool clearDevice = false,
  }) {
    return RepairFilters(
      priority: clearPriority ? null : (priority ?? this.priority),
      device: clearDevice ? null : (device ?? this.device),
      activeOnly: activeOnly ?? this.activeOnly,
    );
  }
}

/// Ouvre la feuille de filtres et renvoie la sélection (ou `null` si annulée).
Future<RepairFilters?> showRepairFilterSheet({
  required BuildContext context,
  required RepairFilters current,
}) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<RepairFilters>(
    context: context,
    title: l.repairFilters,
    builder: (context) {
      var draft = current;
      return StatefulBuilder(
        builder: (context, setSheet) {
          final colors = context.appleColors;

          Widget label(String t) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(t,
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                ),
              );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Priorité.
                label(l.repairPriority),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppleChip(
                        label: l.repairsFilterAll,
                        selected: draft.priority == null,
                        onTap: () => setSheet(
                            () => draft = draft.copyWith(clearPriority: true)),
                      ),
                      for (final p in RepairPriority.values)
                        AppleChip(
                          label: p.label(l),
                          selected: draft.priority == p,
                          onTap: () =>
                              setSheet(() => draft = draft.copyWith(priority: p)),
                        ),
                    ],
                  ),
                ),

                // Type d'appareil.
                label(l.repairFilterDeviceTitle),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppleChip(
                        label: l.repairFilterAny,
                        selected: draft.device == null,
                        onTap: () => setSheet(
                            () => draft = draft.copyWith(clearDevice: true)),
                      ),
                      for (final d in DeviceKind.values)
                        AppleChip(
                          label: d.label(l),
                          selected: draft.device == d,
                          onTap: () =>
                              setSheet(() => draft = draft.copyWith(device: d)),
                        ),
                    ],
                  ),
                ),

                // Actifs seulement.
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l.repairActiveOnly,
                            style: AppleTypography.body
                                .copyWith(color: colors.label)),
                      ),
                      Switch.adaptive(
                        value: draft.activeOnly,
                        onChanged: (v) => setSheet(
                            () => draft = draft.copyWith(activeOnly: v)),
                      ),
                    ],
                  ),
                ),

                // Actions.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      AppleButton(
                        label: l.repairFiltersReset,
                        style: AppleButtonStyle.gray,
                        onPressed: () => Navigator.of(context)
                            .pop(const RepairFilters()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppleButton(
                          label: l.repairFiltersApply,
                          expand: true,
                          onPressed: () => Navigator.of(context).pop(draft),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
