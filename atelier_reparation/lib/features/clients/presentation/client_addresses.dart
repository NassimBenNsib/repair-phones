import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/contact_actions.dart';
import '../domain/client_address.dart';

/// Carte listant les adresses du client : d'abord l'[mainAddress] **principale**
/// (synchronisée avec les coordonnées), puis les adresses supplémentaires, chaque
/// ligne ouvrant l'itinéraire.
class ClientAddressesCard extends StatelessWidget {
  const ClientAddressesCard(
      {super.key, required this.addresses, this.mainAddress});

  final List<ClientAddress> addresses;
  final String? mainAddress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final main = mainAddress?.trim() ?? '';
    if (main.isEmpty && addresses.isEmpty) return const SizedBox.shrink();

    Widget row(IconData icon, String label, String value) => Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => launchContact(context, mapsUri(value)),
            splashColor: colors.fill,
            highlightColor: colors.fill,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: ShapeDecoration(
                      color: colors.orange.withValues(alpha: 0.16),
                      shape: AppleRadii.shape(AppleRadii.sm),
                    ),
                    child: Icon(icon, size: 18, color: colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label,
                            style: AppleTypography.caption1
                                .copyWith(color: colors.secondaryLabel)),
                        const SizedBox(height: 1),
                        Text(value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppleTypography.body
                                .copyWith(color: colors.label)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.directions_outlined,
                      size: 18, color: colors.tertiaryLabel),
                ],
              ),
            ),
          ),
        );

    final rows = <Widget>[
      if (main.isNotEmpty) row(Icons.location_on_outlined, l.addressMain, main),
      for (final a in addresses) row(a.kind.icon, a.kind.label(l), a.value),
    ];

    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(Divider(
            height: 0.5, thickness: 0.5, indent: 60, color: colors.separator));
      }
    }

    return AppleCard(
      padding: EdgeInsets.zero,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Éditeur d'adresses : ajouter/supprimer et **choisir le type** (domicile,
/// travail, facturation, livraison…). Champ multi-lignes.
class AddressesEditor extends StatefulWidget {
  const AddressesEditor(
      {super.key, required this.initial, required this.onChanged});

  final List<ClientAddress> initial;
  final ValueChanged<List<ClientAddress>> onChanged;

  @override
  State<AddressesEditor> createState() => _AddressesEditorState();
}

class _AddrRow {
  _AddrRow(this.kind, this.ctrl);
  AddressKind kind;
  final TextEditingController ctrl;
}

class _AddressesEditorState extends State<AddressesEditor> {
  late final List<_AddrRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final a in widget.initial)
        _AddrRow(a.kind, TextEditingController(text: a.value)..addListener(_emit)),
    ];
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.ctrl.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged([
      for (final r in _rows)
        if (r.ctrl.text.trim().isNotEmpty)
          ClientAddress(kind: r.kind, value: r.ctrl.text.trim()),
    ]);
  }

  void _add() {
    setState(() => _rows
        .add(_AddrRow(AddressKind.home, TextEditingController()..addListener(_emit))));
  }

  void _remove(int i) {
    setState(() {
      _rows[i].ctrl.dispose();
      _rows.removeAt(i);
    });
    _emit();
  }

  Future<void> _pickKind(int i) async {
    final l = AppLocalizations.of(context);
    final choice = await showAppleSelectionSheet<AddressKind>(
      context: context,
      title: l.addressKindTitle,
      selected: _rows[i].kind,
      options: [
        for (final k in AddressKind.values)
          AppleSheetOption(k, k.label(l),
              leading: Icon(k.icon, size: 20, color: context.accentColor)),
      ],
    );
    if (choice != null) {
      setState(() => _rows[i].kind = choice);
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _pickKind(i),
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: context.accentColor.withValues(alpha: 0.16),
                      shape: AppleRadii.shape(AppleRadii.md),
                    ),
                    child: Icon(_rows[i].kind.icon,
                        color: context.accentColor, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppleTextField(
                    controller: _rows[i].ctrl,
                    hint: _rows[i].kind.label(l),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                IconButton(
                  onPressed: () => _remove(i),
                  icon: Icon(Icons.remove_circle_outline, color: colors.red),
                ),
              ],
            ),
          ),
        AppleButton(
          label: l.clientAddAddress,
          icon: Icons.add_location_alt_outlined,
          style: AppleButtonStyle.tinted,
          expand: true,
          onPressed: _add,
        ),
      ],
    );
  }
}
