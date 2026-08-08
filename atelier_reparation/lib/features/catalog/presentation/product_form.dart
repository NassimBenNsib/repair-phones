import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/taxonomy/taxonomy_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../suppliers/application/suppliers_controller.dart';
import '../application/product_categories_controller.dart';
import '../application/product_facets_controller.dart';
import '../domain/product.dart';
import '../domain/product_category_node.dart';

typedef NewProduct = ({
  String name,
  String brand,
  String categoryId,
  double price,
  int stock,
});

/// Champs de base éditables d'un produit (prix/stock vivent dans les variantes).
typedef EditProduct = ({
  String name,
  String brand,
  String categoryId,
  List<ProductSourcing> sourcing,
  Map<String, String> facets,
});

typedef NewVariant = ({String label, double price, int stock});

Future<NewProduct?> showAddProductSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<NewProduct>(
    context: context,
    title: l.productNew,
    builder: (context) => const _AddProductForm(),
  );
}

Future<EditProduct?> showEditProductSheet(
    BuildContext context, Product product) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<EditProduct>(
    context: context,
    title: l.productEdit,
    builder: (context) => _EditProductForm(product: product),
  );
}

Future<NewVariant?> showAddVariantSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<NewVariant>(
    context: context,
    title: l.variantNew,
    builder: (context) => const _AddVariantForm(),
  );
}

double _parsePrice(String s) => double.tryParse(s.trim().replaceAll(',', '.')) ?? 0;
int _parseStock(String s) => int.tryParse(s.trim()) ?? 0;

class _AddProductForm extends ConsumerStatefulWidget {
  const _AddProductForm();

  @override
  ConsumerState<_AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends ConsumerState<_AddProductForm> {
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '0');
  String _categoryId = 'part';

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _price.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty && _parsePrice(_price.text) > 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(controller: _name, label: l.productName),
          const SizedBox(height: 12),
          _Field(controller: _brand, label: l.productBrand),
          const SizedBox(height: 16),
          _FieldLabel(l.productCategory),
          const SizedBox(height: 8),
          TaxonomySelectField(
            provider: productCategoriesProvider,
            icons: kProductCategoryIcons,
            selectedId: _categoryId,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Field(
                    controller: _price,
                    label: '${l.priceLabel} (${AppFormats.symbol})',
                    keyboard: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                    controller: _stock,
                    label: l.stockLabel,
                    keyboard: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppleButton(
            label: l.addLabel,
            icon: Icons.add,
            expand: true,
            onPressed: _valid
                ? () => Navigator.of(context).pop((
                      name: _name.text.trim(),
                      brand: _brand.text.trim().isEmpty
                          ? '—'
                          : _brand.text.trim(),
                      categoryId: _categoryId,
                      price: _parsePrice(_price.text),
                      stock: _parseStock(_stock.text),
                    ))
                : null,
          ),
        ],
      ),
    );
  }
}

class _AddVariantForm extends StatefulWidget {
  const _AddVariantForm();

  @override
  State<_AddVariantForm> createState() => _AddVariantFormState();
}

class _AddVariantFormState extends State<_AddVariantForm> {
  final _label = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
    _price.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  bool get _valid =>
      _label.text.trim().isNotEmpty && _parsePrice(_price.text) > 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(controller: _label, label: l.variantLabel),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Field(
                    controller: _price,
                    label: '${l.priceLabel} (${AppFormats.symbol})',
                    keyboard: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                    controller: _stock,
                    label: l.stockLabel,
                    keyboard: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppleButton(
            label: l.addLabel,
            icon: Icons.add,
            expand: true,
            onPressed: _valid
                ? () => Navigator.of(context).pop((
                      label: _label.text.trim(),
                      price: _parsePrice(_price.text),
                      stock: _parseStock(_stock.text),
                    ))
                : null,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(text,
          style: AppleTypography.footnote
              .copyWith(color: context.appleColors.secondaryLabel)),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboard,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: AppleTypography.body.copyWith(color: colors.label),
          cursorColor: context.accentColor,
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }
}

/// Édition des champs de base d'un produit : nom, marque, catégorie.
class _EditProductForm extends ConsumerStatefulWidget {
  const _EditProductForm({required this.product});
  final Product product;

  @override
  ConsumerState<_EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends ConsumerState<_EditProductForm> {
  late final _name = TextEditingController(text: widget.product.name);
  late final _brand = TextEditingController(text: widget.product.brand);
  late String _categoryId = widget.product.categoryId;
  late List<ProductSourcing> _sourcing = [...widget.product.sourcing];
  late Map<String, String> _facets = {...widget.product.facets};

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(controller: _name, label: l.productName),
          const SizedBox(height: 12),
          _Field(controller: _brand, label: l.productBrand),
          const SizedBox(height: 16),
          _FieldLabel(l.productCategory),
          const SizedBox(height: 8),
          TaxonomySelectField(
            provider: productCategoriesProvider,
            icons: kProductCategoryIcons,
            selectedId: _categoryId,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          if (ref.watch(productFacetsProvider).any((n) => n.parentId == null)) ...[
            const SizedBox(height: 16),
            _FieldLabel(l.productFacets),
            const SizedBox(height: 8),
            _FacetsEditor(initial: _facets, onChanged: (v) => _facets = v),
          ],
          const SizedBox(height: 16),
          _FieldLabel(l.navSuppliers),
          const SizedBox(height: 8),
          _SourcingEditor(
            initial: _sourcing,
            onChanged: (v) => _sourcing = v,
          ),
          const SizedBox(height: 20),
          AppleButton(
            label: l.commonSave,
            icon: Icons.check,
            expand: true,
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop((
                      name: _name.text.trim(),
                      brand: _brand.text.trim().isEmpty
                          ? '—'
                          : _brand.text.trim(),
                      categoryId: _categoryId,
                      sourcing: _sourcing,
                      facets: _facets,
                    )),
          ),
        ],
      ),
    );
  }
}

/// Éditeur de facettes : une sélection unique par dimension (Marque, Qualité…).
class _FacetsEditor extends ConsumerStatefulWidget {
  const _FacetsEditor({required this.initial, required this.onChanged});
  final Map<String, String> initial;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  ConsumerState<_FacetsEditor> createState() => _FacetsEditorState();
}

class _FacetsEditorState extends ConsumerState<_FacetsEditor> {
  late final Map<String, String> _f = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final nodes = ref.watch(productFacetsProvider);
    final dims = nodes.where((n) => n.parentId == null && n.active).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final d in dims)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name,
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final v
                      in nodes.where((n) => n.parentId == d.id && n.active))
                    AppleChip(
                      label: v.name,
                      selected: _f[d.id] == v.id,
                      selectedColor: v.color,
                      onTap: () {
                        setState(() => _f[d.id] == v.id
                            ? _f.remove(d.id)
                            : _f[d.id] = v.id);
                        widget.onChanged(_f);
                      },
                    ),
                ]),
              ],
            ),
          ),
      ],
    );
  }
}

/// Éditeur d'approvisionnements : par fournisseur, prix d'achat + « préféré »,
/// avec ajout via la sélection multiple et retrait par ligne.
class _SourcingEditor extends ConsumerStatefulWidget {
  const _SourcingEditor({required this.initial, required this.onChanged});
  final List<ProductSourcing> initial;
  final ValueChanged<List<ProductSourcing>> onChanged;

  @override
  ConsumerState<_SourcingEditor> createState() => _SourcingEditorState();
}

class _SourcingEditorState extends ConsumerState<_SourcingEditor> {
  late List<ProductSourcing> _items = [...widget.initial];
  final Map<String, TextEditingController> _price = {};

  @override
  void dispose() {
    for (final c in _price.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(ProductSourcing s) => _price.putIfAbsent(s.supplierId, () {
        final c = TextEditingController(
            text: s.purchasePrice == null
                ? ''
                : s.purchasePrice!.toStringAsFixed(0));
        c.addListener(() {
          final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
          _items = [
            for (final x in _items)
              if (x.supplierId == s.supplierId)
                x.copyWith(purchasePrice: v, clearPrice: v == null)
              else
                x
          ];
          widget.onChanged(_items);
        });
        return c;
      });

  void _togglePreferred(String supplierId) {
    setState(() => _items = [
          for (final s in _items) s.copyWith(preferred: s.supplierId == supplierId)
        ]);
    widget.onChanged(_items);
  }

  void _remove(String supplierId) {
    setState(() =>
        _items = [for (final s in _items) if (s.supplierId != supplierId) s]);
    _price.remove(supplierId)?.dispose();
    widget.onChanged(_items);
  }

  Future<void> _add() async {
    final picked = await showSupplierMultiSelectSheet(
        context, _items.map((s) => s.supplierId).toList());
    if (picked == null) return;
    final keep = {
      for (final s in _items)
        if (picked.contains(s.supplierId)) s.supplierId: s
    };
    setState(() => _items = [
          for (final s in _items) if (picked.contains(s.supplierId)) s,
          for (final id in picked)
            if (!keep.containsKey(id)) ProductSourcing(supplierId: id),
        ]);
    widget.onChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final byId = {for (final s in ref.watch(suppliersProvider)) s.id: s};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_items.isEmpty)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l.notProvided,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
          )
        else
          for (final s in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  child: Text(byId[s.supplierId]?.name ?? s.supplierId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.body.copyWith(color: colors.label)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 104,
                  child: AppleTextField(
                    controller: _ctrl(s),
                    label: l.sourcingPurchasePrice,
                    suffix: AppFormats.symbol,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                IconButton(
                  onPressed: () => _togglePreferred(s.supplierId),
                  tooltip: l.sourcingPreferred,
                  icon: Icon(s.preferred ? Icons.star : Icons.star_border,
                      color: s.preferred
                          ? context.accentColor
                          : colors.tertiaryLabel),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: () => _remove(s.supplierId),
                  icon: Icon(Icons.close, size: 18, color: colors.tertiaryLabel),
                  visualDensity: VisualDensity.compact,
                ),
              ]),
            ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppleButton(
            label: l.addLabel,
            icon: Icons.add,
            style: AppleButtonStyle.gray,
            onPressed: _add,
          ),
        ),
      ],
    );
  }
}

/// Feuille de sélection multiple de fournisseurs. Renvoie la liste d'ids
/// choisie, ou `null` si annulée.
Future<List<String>?> showSupplierMultiSelectSheet(
    BuildContext context, List<String> selected) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<List<String>>(
    context: context,
    title: l.navSuppliers,
    builder: (_) => _SupplierMultiSelect(initial: selected),
  );
}

class _SupplierMultiSelect extends ConsumerStatefulWidget {
  const _SupplierMultiSelect({required this.initial});
  final List<String> initial;

  @override
  ConsumerState<_SupplierMultiSelect> createState() =>
      _SupplierMultiSelectState();
}

class _SupplierMultiSelectState extends ConsumerState<_SupplierMultiSelect> {
  late final Set<String> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final suppliers = ref.watch(suppliersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final s in suppliers)
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => setState(() => _selected.contains(s.id)
                    ? _selected.remove(s.id)
                    : _selected.add(s.id)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: AppleTypography.body
                                    .copyWith(color: colors.label)),
                            if (s.city != null)
                              Text(s.city!,
                                  style: AppleTypography.footnote.copyWith(
                                      color: colors.secondaryLabel)),
                          ],
                        ),
                      ),
                      if (_selected.contains(s.id))
                        Icon(Icons.check_circle, color: context.accentColor)
                      else
                        Icon(Icons.circle_outlined,
                            color: colors.tertiaryLabel),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AppleButton(
              label: l.commonDone,
              icon: Icons.check,
              expand: true,
              onPressed: () =>
                  Navigator.of(context).pop(_selected.toList()),
            ),
          ),
        ],
      ),
    );
  }
}

