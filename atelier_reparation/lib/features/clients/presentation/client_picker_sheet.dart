import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../application/clients_controller.dart';
import '../domain/client.dart';
import '../domain/contact_channel.dart';
import 'client_channels.dart';

/// Ouvre le sélecteur de client : recherche dans la liste ou création d'un
/// nouveau client. Renvoie le client choisi/créé (ou `null` si annulé).
Future<Client?> showClientPickerSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<Client>(
    context: context,
    title: l.clientSelect,
    builder: (context) => const _ClientPicker(),
  );
}

class _ClientPicker extends ConsumerStatefulWidget {
  const _ClientPicker();

  @override
  ConsumerState<_ClientPicker> createState() => _ClientPickerState();
}

class _ClientPickerState extends ConsumerState<_ClientPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final clients = ref.watch(clientsProvider);
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? clients
        : clients
            .where((c) =>
                c.name.toLowerCase().contains(q) || c.phone.contains(q))
            .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: AppleSearchField(
            hintText: l.clientsSearch,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: AppleButton(
            label: l.clientsNew,
            icon: Icons.person_add_alt,
            expand: true,
            onPressed: _createNew,
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, i) {
              final c = results[i];
              return ListTile(
                leading: AppleAvatar(name: c.name, size: 36),
                title: Text(c.name,
                    style: AppleTypography.body.copyWith(color: colors.label)),
                subtitle: Text(c.phone,
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel)),
                onTap: () => Navigator.of(context).pop(c),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _createNew() async {
    final created = await showAddClientSheet(context);
    if (created == null) return;
    ref.read(clientsProvider.notifier).add(created);
    if (mounted) Navigator.of(context).pop(created);
  }
}

/// Formulaire de création d'un client ; renvoie le client saisi.
Future<Client?> showAddClientSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showAppleSheet<Client>(
    context: context,
    title: l.clientsNew,
    builder: (context) => const _AddClientForm(),
  );
}

class _AddClientForm extends StatefulWidget {
  const _AddClientForm();

  @override
  State<_AddClientForm> createState() => _AddClientFormState();
}

class _AddClientFormState extends State<_AddClientForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  List<ContactChannel> _channels = const [];

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _opt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppleTextField(controller: _name, label: l.repairSectionClient),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _phone,
              label: l.fieldPhone,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _email,
              label: l.fieldEmail,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          AppleTextField(controller: _address, label: l.fieldAddress),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l.clientOtherContacts,
                style: AppleTypography.footnote
                    .copyWith(color: context.appleColors.secondaryLabel)),
          ),
          const SizedBox(height: 8),
          ChannelsEditor(initial: _channels, onChanged: (v) => _channels = v),
          const SizedBox(height: 16),
          AppleButton(
            label: l.addLabel,
            icon: Icons.check,
            expand: true,
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(Client(
                      id: const Uuid().v4(),
                      name: _name.text.trim(),
                      phone: _phone.text.trim(),
                      email: _opt(_email),
                      address: _opt(_address),
                      channels: _channels,
                      createdAt: DateTime.now(),
                    )),
          ),
        ],
      ),
    );
  }
}
