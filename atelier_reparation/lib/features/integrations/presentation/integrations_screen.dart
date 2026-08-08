import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/list_empty_state.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../application/integrations_controller.dart';
import '../domain/integration.dart';

/// Catalogue d'intégrations tierces : paiements (Flouci, Konnect, ClicToPay,
/// Stripe), messagerie (WhatsApp, Messenger, SMS) et cloud/e-mail (Drive, Gmail).
/// Recherche, filtres par catégorie, activation et configuration par fournisseur.
class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  static const String routeName = 'integrations';
  static const String routePath = '/integrations';

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  String _query = '';
  IntegrationCategory? _category;

  Integration _byKind(List<Integration> all, IntegrationKind kind) {
    for (final i in all) {
      if (i.kind == kind) return i;
    }
    return Integration(kind: kind);
  }

  bool _matches(IntegrationKind kind, AppLocalizations l) {
    if (_category != null && kind.category != _category) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return kind.brand.toLowerCase().contains(q) ||
        kind.description(l).toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final all = ref.watch(integrationsProvider);

    final kinds = IntegrationKind.values.where((k) => _matches(k, l)).toList();
    final activeCount = IntegrationKind.values
        .where((k) => _byKind(all, k).status == IntegrationStatus.active)
        .length;

    return AppleScaffold(
      title: l.navIntegrations,
      slivers: [
        // Résumé.
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              child: Row(children: [
                Icon(Icons.extension_outlined, color: context.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l.integrationsSummary,
                      style: AppleTypography.body
                          .copyWith(color: colors.secondaryLabel)),
                ),
                Text('$activeCount / ${IntegrationKind.values.length}',
                    style: AppleTypography.title3.copyWith(
                        color: colors.label, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        // Recherche.
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.integrationsSearch,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        // Catégories.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              AppleChip(
                  label: l.repairsFilterAll,
                  selected: _category == null,
                  onTap: () => setState(() => _category = null)),
              for (final c in IntegrationCategory.values)
                AppleChip(
                    label: c.label(l),
                    selected: _category == c,
                    onTap: () =>
                        setState(() => _category = _category == c ? null : c)),
            ]),
          ),
        ),
        if (kinds.isEmpty)
          SliverToBoxAdapter(
            child: ListEmptyState(
                icon: Icons.search_off,
                title: l.listNoResults,
                subtitle: l.listNoResultsSubtitle),
          )
        else
          for (final cat in IntegrationCategory.values)
            if (kinds.any((k) => k.category == cat)) ...[
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
                sliver: SliverToBoxAdapter(
                    child: SectionHeader(title: cat.label(l))),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: AppleListSection(
                    children: [
                      for (final k
                          in kinds.where((k) => k.category == cat))
                        _IntegrationRow(
                          integration: _byKind(all, k),
                          onTap: () => _configure(_byKind(all, k)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Future<void> _configure(Integration current) async {
    final result = await showAppleSheet<Integration>(
      context: context,
      title: current.kind.brand,
      builder: (_) => _IntegrationSheet(initial: current),
    );
    if (result != null) ref.read(integrationsProvider.notifier).save(result);
  }
}

/// Libellé + couleur d'un statut d'intégration.
({String label, Color color}) _statusChip(
    Integration i, AppLocalizations l, AppleColors colors) {
  switch (i.status) {
    case IntegrationStatus.active:
      return (label: l.integrationStatusActive, color: colors.green);
    case IntegrationStatus.disabled:
      return (label: l.integrationStatusDisabled, color: colors.orange);
    case IntegrationStatus.notConfigured:
      return (
        label: l.integrationStatusNotConfigured,
        color: colors.secondaryLabel
      );
  }
}

class _IntegrationRow extends StatelessWidget {
  const _IntegrationRow({required this.integration, required this.onTap});

  final Integration integration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final k = integration.kind;
    final chip = _statusChip(integration, l, colors);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: ShapeDecoration(
                color: k.color.withValues(alpha: 0.16),
                shape: AppleRadii.shape(AppleRadii.md),
              ),
              child: Icon(k.icon, size: 20, color: k.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k.brand,
                      style:
                          AppleTypography.body.copyWith(color: colors.label)),
                  Text(k.description(l),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppleBadge(label: chip.label, color: chip.color),
            const SizedBox(width: 6),
            Icon(context.chevronForward,
                size: 20, color: colors.tertiaryLabel),
          ]),
        ),
      ),
    );
  }
}

/// Feuille de configuration d'une intégration.
class _IntegrationSheet extends StatefulWidget {
  const _IntegrationSheet({required this.initial});
  final Integration initial;

  @override
  State<_IntegrationSheet> createState() => _IntegrationSheetState();
}

class _IntegrationSheetState extends State<_IntegrationSheet> {
  late bool _enabled = widget.initial.enabled;
  late bool _connected = widget.initial.config['connected'] == 'true';
  late final Map<String, TextEditingController> _c = {
    for (final f in widget.initial.kind.fields)
      f.key: TextEditingController(text: widget.initial.config[f.key] ?? ''),
  };
  String? _note;
  bool _noteOk = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Integration _build() {
    final config = <String, String>{...widget.initial.config};
    for (final e in _c.entries) {
      final v = e.value.text.trim();
      if (v.isEmpty) {
        config.remove(e.key);
      } else {
        config[e.key] = v;
      }
    }
    if (widget.initial.kind.oauth) {
      if (_connected) {
        config['connected'] = 'true';
      } else {
        config.remove('connected');
      }
    }
    return widget.initial.copyWith(enabled: _enabled, config: config);
  }

  /// Message localisé pour un résultat de validation.
  String _validationMessage(AppLocalizations l, IntegrationValidation v) {
    String field(String? key) {
      if (key == null) return '';
      for (final f in widget.initial.kind.fields) {
        if (f.key == key) return f.label(l);
      }
      return key;
    }

    return switch (v.issue) {
      IntegrationIssue.none => l.integrationValid,
      IntegrationIssue.notConnected => l.integrationCheckNotConnected,
      IntegrationIssue.missingField => l.integrationCheckMissing(field(v.fieldKey)),
      IntegrationIssue.invalidUrl => l.integrationCheckUrl(field(v.fieldKey)),
      IntegrationIssue.invalidEmail => l.integrationCheckEmail,
      IntegrationIssue.tooShort => l.integrationCheckShort(field(v.fieldKey)),
    };
  }

  void _test(AppLocalizations l) {
    final v = validateIntegration(_build());
    setState(() {
      _noteOk = v.ok;
      _note = _validationMessage(l, v);
    });
  }

  Future<void> _connect(AppLocalizations l) async {
    final url = widget.initial.kind.accountUrl;
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
    if (!mounted) return;
    setState(() {
      _connected = true;
      _noteOk = true;
      _note = l.integrationConnected;
    });
  }

  void _disconnect() {
    setState(() {
      _connected = false;
      _note = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final k = widget.initial.kind;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(k.description(l),
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
          const SizedBox(height: 16),
          // Activation.
          Row(children: [
            Expanded(
              child: Text(l.integrationEnable,
                  style: AppleTypography.body.copyWith(color: colors.label)),
            ),
            Switch(
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v)),
          ]),
          if (k.oauth) ...[
            const SizedBox(height: 8),
            if (_connected)
              AppleButton(
                label: l.integrationDisconnect,
                icon: Icons.link_off,
                style: AppleButtonStyle.gray,
                expand: true,
                onPressed: _disconnect,
              )
            else
              AppleButton(
                label: l.integrationConnectAccount,
                icon: Icons.link,
                style: AppleButtonStyle.tinted,
                expand: true,
                onPressed: () => _connect(l),
              ),
          ] else
            for (final f in k.fields) ...[
              const SizedBox(height: 12),
              AppleTextField(
                controller: _c[f.key]!,
                label: f.label(l),
                hint: f.hint,
                obscureText: f.secret,
              ),
            ],
          const SizedBox(height: 16),
          AppleButton(
            label: l.integrationTest,
            icon: Icons.wifi_tethering,
            style: AppleButtonStyle.gray,
            expand: true,
            onPressed: () => _test(l),
          ),
          const SizedBox(height: 8),
          AppleButton(
            label: l.commonSave,
            icon: Icons.check,
            expand: true,
            onPressed: () => Navigator.of(context).pop(_build()),
          ),
          if (_note != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_noteOk ? Icons.check_circle : Icons.error_outline,
                    size: 16,
                    color: _noteOk ? colors.green : colors.orange),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(_note!,
                      textAlign: TextAlign.center,
                      style: AppleTypography.footnote.copyWith(
                          color: _noteOk ? colors.green : colors.orange)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
