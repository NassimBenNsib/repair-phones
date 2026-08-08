import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../repairs/domain/repair.dart';
import '../application/categories_controller.dart';
import '../domain/service_category_node.dart';
import '../application/service_catalog_controller.dart';

/// Ouvre le sélecteur de prestation (catalogue actif, filtrable par catégorie)
/// et renvoie la prestation choisie (ou saisie manuellement), ou `null`.
Future<RepairService?> showServicePickerSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<RepairService>(
    context: context,
    title: l.prestationPickTitle,
    builder: (context) => const _ServicePickerBody(),
  );
}

class _ServicePickerBody extends ConsumerStatefulWidget {
  const _ServicePickerBody();

  @override
  ConsumerState<_ServicePickerBody> createState() => _ServicePickerBodyState();
}

class _ServicePickerBodyState extends ConsumerState<_ServicePickerBody> {
  String _query = '';
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final q = _query.trim().toLowerCase();
    final cats = ref.watch(categoriesProvider);
    final byId = {for (final c in cats) c.id: c};
    // Filtre catégorie avec rollup (une catégorie inclut ses sous-catégories).
    final selNode = _categoryId == null ? null : byId[_categoryId];
    final activeTop = selNode?.parentId ?? selNode?.id;
    final subs = activeTop == null
        ? const <dynamic>[]
        : cats.where((c) => c.parentId == activeTop).toList();
    final catIds = _categoryId == null
        ? null
        : (selNode?.parentId == null
            ? {
                _categoryId!,
                for (final c in cats.where((c) => c.parentId == _categoryId))
                  c.id
              }
            : {_categoryId!});
    // Catalogue : prestations actives uniquement.
    final templates = ref.watch(serviceCatalogProvider).where((t) {
      if (!t.active) return false;
      if (catIds != null && !catIds.contains(t.categoryId)) return false;
      return q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 8),
          child: AppleSearchField(
            hintText: l.prestationSearch,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        // Filtre par catégorie (avec drill-down sous-catégories).
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            AppleChip(
                label: l.repairsFilterAll,
                selected: _categoryId == null,
                onTap: () => setState(() => _categoryId = null)),
            for (final c in cats.where((n) => n.parentId == null))
              AppleChip(
                  label: c.name,
                  selected: activeTop == c.id,
                  onTap: () => setState(
                      () => _categoryId = activeTop == c.id ? null : c.id)),
          ]),
        ),
        if (subs.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              AppleChip(
                  label: l.repairsFilterAll,
                  selected: _categoryId == activeTop,
                  onTap: () => setState(() => _categoryId = activeTop)),
              for (final s in subs)
                AppleChip(
                    label: s.name,
                    selected: _categoryId == s.id,
                    onTap: () => setState(() => _categoryId = s.id)),
            ]),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
          child: AppleButton(
            label: l.prestationManual,
            icon: Icons.edit_outlined,
            style: AppleButtonStyle.tinted,
            expand: true,
            onPressed: () async {
              final custom = await _showManualService(context);
              if (custom != null && context.mounted) {
                Navigator.of(context).pop(custom);
              }
            },
          ),
        ),
        Flexible(
          child: templates.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(l.catalogEmpty,
                      style: AppleTypography.subheadline
                          .copyWith(color: colors.secondaryLabel)),
                )
              : ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                  shrinkWrap: true,
                  children: [
                    AppleListSection(
                      children: [
                        for (final t in templates)
                          AppleListRow(
                            leadingIcon:
                                byId[t.categoryId]?.icon ?? Icons.handyman,
                            leadingTint: byId[t.categoryId]?.color ??
                                colors.secondaryLabel,
                            title: t.name,
                            subtitle: t.description,
                            trailingText: AppFormats.money(t.price, decimals: 0),
                            onTap: () => Navigator.of(context)
                                .pop(RepairService(t.name, t.price)),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Saisie manuelle (prestation hors catalogue) avec option « Ajouter au
/// catalogue » pour la réutiliser ensuite.
Future<RepairService?> _showManualService(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<RepairService>(
    context: context,
    title: l.prestationManual,
    builder: (context) => const _ManualServiceForm(),
  );
}

class _ManualServiceForm extends ConsumerStatefulWidget {
  const _ManualServiceForm();

  @override
  ConsumerState<_ManualServiceForm> createState() => _ManualServiceFormState();
}

class _ManualServiceFormState extends ConsumerState<_ManualServiceForm> {
  final _label = TextEditingController();
  final _price = TextEditingController();
  String _categoryId = 'other';
  bool _save = false;

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit() {
    final lbl = _label.text.trim();
    if (lbl.isEmpty) return;
    final p =
        double.tryParse(_price.text.trim().replaceAll(',', '.')) ?? 0;
    if (_save) {
      ref.read(serviceCatalogProvider.notifier).add(
          name: lbl, price: p, categoryId: _categoryId);
    }
    Navigator.of(context).pop(RepairService(lbl, p));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleTextField(controller: _label, label: l.addPrestation),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _price,
              label: '${l.priceLabel} (${AppFormats.symbol})',
              suffix: AppFormats.symbol,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          if (_save) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in ref.watch(categoriesProvider))
                AppleChip(
                    label: c.parentId == null ? c.name : '  ${c.name}',
                    selected: _categoryId == c.id,
                    onTap: () => setState(() => _categoryId = c.id)),
            ]),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Text(l.serviceAddToCatalog,
                  style: AppleTypography.body.copyWith(color: colors.label)),
            ),
            Switch.adaptive(
                value: _save, onChanged: (v) => setState(() => _save = v)),
          ]),
          const SizedBox(height: 12),
          AppleButton(
            label: l.addLabel,
            expand: true,
            onPressed: _label.text.trim().isEmpty ? null : _submit,
          ),
        ],
      ),
    );
  }
}
