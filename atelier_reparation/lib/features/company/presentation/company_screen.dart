import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../application/company_controller.dart';
import '../domain/company_profile.dart';

/// Écran d'édition de l'identité de l'établissement.
class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});

  static const String routeName = 'company';
  static const String routePath = '/company';

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  late final CompanyProfile _initial = ref.read(companyProvider);
  late final _name = TextEditingController(text: _initial.name);
  late final _address = TextEditingController(text: _initial.address);
  late final _postalCode = TextEditingController(text: _initial.postalCode);
  late final _city = TextEditingController(text: _initial.city);
  late final _phone = TextEditingController(text: _initial.phone);
  late final _email = TextEditingController(text: _initial.email);
  late final _vat = TextEditingController(text: _initial.vatNumber);
  late final _siret = TextEditingController(text: _initial.siret);
  late String _logo = _initial.logo;

  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _postalCode,
      _city,
      _phone,
      _email,
      _vat,
      _siret,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    const group = XTypeGroup(
      label: 'images',
      extensions: ['png', 'jpg', 'jpeg'],
    );
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _logo = base64Encode(bytes));
  }

  void _save() {
    ref.read(companyProvider.notifier).save(CompanyProfile(
          name: _name.text.trim(),
          address: _address.text.trim(),
          postalCode: _postalCode.text.trim(),
          city: _city.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          vatNumber: _vat.text.trim(),
          siret: _siret.text.trim(),
          logo: _logo,
        ));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppleScaffold(
      title: l.settingsWorkshopInfo,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _LogoField(
                    logo: _logo,
                    onPick: _pickLogo,
                    onRemove: () => setState(() => _logo = ''),
                  ),
                  const SizedBox(height: 16),
                  AppleTextField(controller: _name, label: l.companyName),
                  const SizedBox(height: 14),
                  AppleTextField(
                      controller: _address, label: l.fieldAddress),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: AppleTextField(
                            controller: _postalCode,
                            label: l.companyPostalCode),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppleTextField(
                            controller: _city, label: l.clientCity),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppleTextField(
                      controller: _phone,
                      label: l.fieldPhone,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  AppleTextField(
                      controller: _email,
                      label: l.fieldEmail,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  AppleTextField(controller: _vat, label: l.supplierVat),
                  const SizedBox(height: 14),
                  AppleTextField(controller: _siret, label: l.companySiret),
                  const SizedBox(height: 20),
                  AppleButton(
                    label: l.commonSave,
                    icon: Icons.check,
                    expand: true,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Aperçu + sélection du logo de l'établissement.
class _LogoField extends StatelessWidget {
  const _LogoField(
      {required this.logo, required this.onPick, required this.onRemove});

  final String logo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final hasLogo = logo.isNotEmpty;

    return Row(
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: 72,
            height: 72,
            decoration: ShapeDecoration(
              color: colors.fill,
              shape: AppleRadii.shape(AppleRadii.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasLogo
                ? Image.memory(base64Decode(logo), fit: BoxFit.cover)
                : Icon(Icons.add_photo_alternate_outlined,
                    color: colors.secondaryLabel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.companyLogo,
                  style:
                      AppleTypography.subheadline.copyWith(color: colors.label)),
              const SizedBox(height: 6),
              Row(
                children: [
                  AppleButton(
                    label: l.companyLogoAdd,
                    icon: Icons.image_outlined,
                    style: AppleButtonStyle.tinted,
                    onPressed: onPick,
                  ),
                  if (hasLogo) ...[
                    const SizedBox(width: 8),
                    AppleButton(
                      label: l.companyLogoRemove,
                      style: AppleButtonStyle.gray,
                      onPressed: onRemove,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
