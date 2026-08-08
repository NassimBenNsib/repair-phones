import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../application/catalog_controller.dart';
import '../application/product_facets_controller.dart';
import '../application/smart_views_controller.dart';
import '../domain/product_category_node.dart';
import '../domain/smart_view.dart';

/// Gestion des sélections intelligentes : liste + création/édition avec un
/// constructeur de règle simple.
class SmartViewsScreen extends ConsumerWidget {
  const SmartViewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final views = ref.watch(smartViewsProvider);
    final products = ref.watch(catalogProvider);

    return AppleScaffold(
      title: l.smartViews,
      actions: [
        IconButton(
            onPressed: () => _openForm(context),
            icon: Icon(Icons.add, color: context.accentColor),
            tooltip: l.smartViewNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
          sliver: SliverToBoxAdapter(
            child: views.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l.smartViews,
                        textAlign: TextAlign.center,
                        style: AppleTypography.subheadline
                            .copyWith(color: colors.secondaryLabel)),
                  )
                : AppleListSection(children: [
                    for (final v in views)
                      _ViewRow(
                        view: v,
                        count: ref
                            .read(smartViewsProvider.notifier)
                            .productsFor(v.id, products)
                            .length,
                        onTap: () => _openForm(context, view: v),
                      ),
                  ]),
          ),
        ),
      ],
    );
  }

  Future<void> _openForm(BuildContext context, {SmartView? view}) =>
      showAppleSheet<void>(
        context: context,
        title: view?.name ?? AppLocalizations.of(context).smartViewNew,
        builder: (_) => _SmartViewForm(initial: view),
      );
}

class _ViewRow extends StatelessWidget {
  const _ViewRow(
      {required this.view, required this.count, required this.onTap});
  final SmartView view;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: ShapeDecoration(
                color: view.color.withValues(alpha: 0.16),
                shape: AppleRadii.shape(AppleRadii.sm),
              ),
              child: Icon(kProductCategoryIcons[view.iconKey] ?? Icons.bolt,
                  size: 17, color: view.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(view.name,
                  style: AppleTypography.body.copyWith(color: colors.label)),
            ),
            Text('$count',
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
            const SizedBox(width: 6),
            Icon(context.chevronForward, size: 20, color: colors.tertiaryLabel),
          ]),
        ),
      ),
    );
  }
}

/// Formulaire d'une sélection : nom, couleur, et règle (stock / prix / marque /
/// facette).
class _SmartViewForm extends ConsumerStatefulWidget {
  const _SmartViewForm({this.initial});
  final SmartView? initial;

  @override
  ConsumerState<_SmartViewForm> createState() => _SmartViewFormState();
}

class _SmartViewFormState extends ConsumerState<_SmartViewForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _brand =
      TextEditingController(text: widget.initial?.rule.brand ?? '');
  late final _priceMax = TextEditingController(
      text: widget.initial?.rule.priceMax?.toStringAsFixed(0) ?? '');
  late final _priceMin = TextEditingController(
      text: widget.initial?.rule.priceMin?.toStringAsFixed(0) ?? '');
  late int _colorHex = widget.initial?.colorHex ?? kProductCategoryColors.first;
  late String? _stock = widget.initial?.rule.stock;
  late String? _facetValueId = widget.initial?.rule.facetValueId;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _brand, _priceMax, _priceMin]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _save() {
    final ctrl = ref.read(smartViewsProvider.notifier);
    final rule = SmartRule(
      stock: _stock,
      priceMax: _num(_priceMax),
      priceMin: _num(_priceMin),
      facetValueId: _facetValueId,
      brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
    );
    final init = widget.initial;
    if (init == null) {
      final order = ref.read(smartViewsProvider).length;
      ctrl.add(SmartView(
          id: const Uuid().v4(),
          name: _name.text.trim(),
          colorHex: _colorHex,
          order: order,
          rule: rule));
    } else {
      ctrl.update(init.copyWith(
          name: _name.text.trim(), colorHex: _colorHex, rule: rule));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final facets = ref.watch(productFacetsProvider);
    final facetValues = facets.where((n) => n.parentId != null && n.active);

    Widget label(String t) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(t,
              style: AppleTypography.footnote
                  .copyWith(color: colors.secondaryLabel)),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleTextField(controller: _name, label: l.fieldName),
          const SizedBox(height: 16),
          label(l.categoryColor),
          const SizedBox(height: 8),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final hex in kProductCategoryColors)
              GestureDetector(
                onTap: () => setState(() => _colorHex = hex),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Color(hex),
                    shape: BoxShape.circle,
                    border: _colorHex == hex
                        ? Border.all(color: colors.label, width: 2)
                        : null,
                  ),
                  child: _colorHex == hex
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
          ]),
          const SizedBox(height: 20),
          label(l.smartRule.toUpperCase()),
          const SizedBox(height: 12),
          // Stock.
          label(l.smartStock),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            AppleChip(
                label: l.smartAny,
                selected: _stock == null,
                onTap: () => setState(() => _stock = null)),
            AppleChip(
                label: l.inventoryOut,
                selected: _stock == 'out',
                onTap: () => setState(() => _stock = 'out')),
            AppleChip(
                label: l.inventoryLow,
                selected: _stock == 'low',
                onTap: () => setState(() => _stock = 'low')),
          ]),
          const SizedBox(height: 12),
          // Prix.
          Row(children: [
            Expanded(
              child: AppleTextField(
                  controller: _priceMin,
                  label: l.smartPriceMin,
                  suffix: AppFormats.symbol,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppleTextField(
                  controller: _priceMax,
                  label: l.smartPriceMax,
                  suffix: AppFormats.symbol,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ),
          ]),
          const SizedBox(height: 12),
          // Marque contient.
          AppleTextField(controller: _brand, label: l.productBrand),
          if (facetValues.isNotEmpty) ...[
            const SizedBox(height: 12),
            label(l.productFacets),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final v in facetValues)
                AppleChip(
                  label: v.name,
                  selected: _facetValueId == v.id,
                  selectedColor: v.color,
                  onTap: () => setState(() =>
                      _facetValueId = _facetValueId == v.id ? null : v.id),
                ),
            ]),
          ],
          const SizedBox(height: 20),
          AppleButton(
            label: l.commonSave,
            icon: Icons.check,
            expand: true,
            onPressed: _name.text.trim().isEmpty ? null : _save,
          ),
          if (widget.initial != null) ...[
            const SizedBox(height: 8),
            AppleButton(
              label: l.actionDelete,
              icon: Icons.delete_outline,
              style: AppleButtonStyle.destructive,
              expand: true,
              onPressed: () {
                ref.read(smartViewsProvider.notifier).remove(widget.initial!.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
