import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../application/catalog_controller.dart';

/// Variante choisie dans le sélecteur de produit.
typedef PickedVariant = ({
  String productId,
  String variantId,
  String label,
  double price,
});

/// Sélecteur de produit : liste à plat des variantes du catalogue.
Future<PickedVariant?> showProductPickerSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<PickedVariant>(
    context: context,
    title: l.productPickTitle,
    builder: (context) => const _ProductPicker(),
  );
}

class _ProductPicker extends ConsumerStatefulWidget {
  const _ProductPicker();

  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final products = ref.watch(catalogProvider);
    final q = _query.trim().toLowerCase();

    final rows = <PickedVariant>[];
    for (final p in products) {
      for (final v in p.variants) {
        final label = v.attributes.isEmpty ? p.name : '${p.name} — ${v.label}';
        if (q.isEmpty || label.toLowerCase().contains(q)) {
          rows.add((
            productId: p.id,
            variantId: v.id,
            label: label,
            price: v.price,
          ));
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: AppleSearchField(
            hintText: l.catalogSearch,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              return ListTile(
                title: Text(r.label,
                    style: AppleTypography.body.copyWith(color: colors.label)),
                trailing: Text(AppFormats.money(r.price, decimals: 0),
                    style: AppleTypography.subheadline.copyWith(
                        color: colors.secondaryLabel,
                        fontWeight: FontWeight.w600)),
                onTap: () => Navigator.of(context).pop(r),
              );
            },
          ),
        ),
      ],
    );
  }
}
