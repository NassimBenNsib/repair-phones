import 'dart:convert';

import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/pdf/statement_pdf.dart';
import '../../company/application/company_controller.dart';
import '../application/client_statement.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/contact_actions.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../../core/auth/permissions.dart';
import '../../auth/application/session_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/domain/invoice.dart';
import '../../invoices/presentation/invoice_detail.dart';
import '../../payments/application/payment_history.dart';
import '../../payments/presentation/ledger_row.dart';
import '../../quotes/application/quotes_controller.dart';
import '../../quotes/domain/quote.dart';
import '../../quotes/presentation/quote_detail.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/domain/repair.dart';
import '../../repairs/presentation/repair_detail.dart';
import '../../../shared/widgets/apple/kpi_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../application/client_payments_controller.dart';
import '../application/client_stats.dart';
import '../application/clients_controller.dart';
import '../domain/client_payment.dart';
import '../domain/client.dart';
import '../domain/client_address.dart';
import '../domain/contact_channel.dart';
import 'client_addresses.dart';
import 'client_channels.dart';

/// Placeholder du volet (deux colonnes, rien de sélectionné).
class ClientDetailEmpty extends StatelessWidget {
  const ClientDetailEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return ColoredBox(
      color: colors.groupedBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 64, color: colors.tertiaryLabel),
            const SizedBox(height: 16),
            Text(l.clientsEmpty,
                style: AppleTypography.title3.copyWith(color: colors.label)),
          ],
        ),
      ),
    );
  }
}

/// Écran de détail client (page poussée).
class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(context.backIcon, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(client.displayName),
      ),
      body: ClientDetailView(clientId: client.id),
    );
  }
}

/// Contenu réutilisable (volet ou écran) — vue + édition inline.
class ClientDetailView extends ConsumerStatefulWidget {
  const ClientDetailView({super.key, required this.clientId, this.onClose});

  final String clientId;
  final VoidCallback? onClose;

  @override
  ConsumerState<ClientDetailView> createState() => _ClientDetailViewState();
}

class _ClientDetailViewState extends ConsumerState<ClientDetailView> {
  bool _editing = false;
  late Map<String, TextEditingController> _c;
  late ClientType _type;
  List<ContactChannel> _channels = const [];
  List<ClientAddress> _addresses = const [];
  bool _consent = false;
  // Historiques repliés à 5 lignes par défaut.
  bool _allInvoices = false;
  bool _allQuotes = false;
  bool _allRepairs = false;
  bool _allPayments = false;
  static const int _cap = 5;

  @override
  void initState() {
    super.initState();
    _c = {
      for (final k in const [
        'name', 'company', 'vat', 'phone', 'email', 'address', 'city', 'notes',
        'tags', 'siret', 'billing', 'terms', 'discount', 'credit'
      ])
        k: TextEditingController(),
    };
    final c = _current();
    _type = c?.type ?? ClientType.individual;
    if (c != null) _fill(c);
  }

  Client? _current() {
    for (final c in ref.read(clientsProvider)) {
      if (c.id == widget.clientId) return c;
    }
    return null;
  }

  void _fill(Client c) {
    _c['name']!.text = c.name;
    _c['company']!.text = c.companyName ?? '';
    _c['vat']!.text = c.vatNumber ?? '';
    _c['phone']!.text = c.phone;
    _c['email']!.text = c.email ?? '';
    _c['address']!.text = c.address ?? '';
    _c['city']!.text = c.city ?? '';
    _c['notes']!.text = c.notes ?? '';
    _channels = c.channels;
    _addresses = c.addresses;
    _c['tags']!.text = c.tags.join(', ');
    _c['siret']!.text = c.siret ?? '';
    _c['billing']!.text = c.billingContact ?? '';
    _c['terms']!.text = c.paymentTerms ?? '';
    _c['discount']!.text =
        c.discountRate == 0 ? '' : (c.discountRate * 100).toStringAsFixed(0);
    _c['credit']!.text = c.creditLimit?.toStringAsFixed(0) ?? '';
    _consent = c.marketingConsent;
    _type = c.type;
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(String k) => _c[k]!.text.trim().isEmpty ? null : _c[k]!.text.trim();

  double? _optNum(String k) {
    final t = _c[k]!.text.trim();
    return t.isEmpty ? null : double.tryParse(t.replaceAll(',', '.'));
  }

  void _save() {
    final c = _current();
    if (c == null) return;
    // Construction directe (et non copyWith) : permet d'effacer un champ vidé.
    ref.read(clientsProvider.notifier).update(Client(
          id: c.id,
          createdAt: c.createdAt,
          type: _type,
          name: _c['name']!.text.trim(),
          companyName: _opt('company'),
          vatNumber: _opt('vat'),
          phone: _c['phone']!.text.trim(),
          email: _opt('email'),
          address: _opt('address'),
          city: _opt('city'),
          notes: _opt('notes'),
          channels: _channels,
          addresses: _addresses,
          tags: _c['tags']!
              .text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          marketingConsent: _consent,
          siret: _opt('siret'),
          billingContact: _opt('billing'),
          paymentTerms: _opt('terms'),
          discountRate: (_optNum('discount') ?? 0) / 100,
          creditLimit: _optNum('credit'),
        ));
    setState(() => _editing = false);
  }

  void _cancel() {
    final c = _current();
    if (c != null) _fill(c);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final c = _current();
    if (c == null) return const ClientDetailEmpty();

    final stats = computeClientStats(
      c,
      invoices: ref.watch(invoicesProvider),
      quotes: ref.watch(quotesProvider),
      repairs: ref.watch(repairsProvider),
    );
    final history = stats.repairs;
    final df = AppFormats.dateFormat;
    final can = ref.read(sessionControllerProvider.notifier);
    final ledger = buildPaymentHistory(
      invoices: ref.watch(invoicesProvider),
      clientPayments: ref.watch(clientPaymentsProvider),
      clientId: c.id,
    );
    final hasActivity = history.isNotEmpty ||
        stats.invoices.isNotEmpty ||
        stats.quotes.isNotEmpty ||
        ledger.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Barre d'actions.
        Row(
          children: [
            if (widget.onClose != null)
              IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(Icons.close, color: colors.secondaryLabel)),
            const Spacer(),
            if (_editing) ...[
              AppleButton(
                  label: l.commonCancel,
                  style: AppleButtonStyle.gray,
                  onPressed: _cancel),
              const SizedBox(width: 8),
              AppleButton(label: l.commonSave, onPressed: _save),
            ] else
              AppleButton(
                  label: l.actionEdit,
                  icon: Icons.edit_outlined,
                  style: AppleButtonStyle.tinted,
                  onPressed: () => setState(() => _editing = true)),
          ],
        ),

        // En-tête.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              AppleAvatar(name: c.displayName, size: 72),
              const SizedBox(height: 12),
              if (_editing) ...[
                AppleTextField(controller: _c['name']!, label: l.fieldName),
                const SizedBox(height: 10),
                AppleSegmentedControl<ClientType>(
                  value: _type,
                  onChanged: (t) => setState(() => _type = t),
                  segments: {for (final t in ClientType.values) t: t.label(l)},
                ),
              ] else ...[
                Text(c.displayName,
                    textAlign: TextAlign.center,
                    style: AppleTypography.title2.copyWith(color: colors.label)),
                const SizedBox(height: 6),
                AppleBadge(label: c.type.label(l), color: context.accentColor),
              ],
            ],
          ),
        ),

        // Actions rapides (vue seule).
        if (!_editing) _quickActions(c, l, colors),

        // Synthèse financière (vue seule, si activité).
        if (!_editing &&
            (stats.invoiceCount + stats.quoteCount + stats.repairCount) > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                    label: l.clientStatInvoiced,
                    value: stats.invoicedTotal.round(),
                    unit: AppFormats.symbol,
                    icon: Icons.receipt_long,
                    tint: colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                    label: l.clientStatOutstanding,
                    value: stats.outstanding.round(),
                    unit: AppFormats.symbol,
                    icon: Icons.error_outline,
                    tint: colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                    label: l.clientStatRepairs,
                    value: stats.repairCount,
                    icon: Icons.build,
                    tint: colors.green),
              ),
            ],
          ),
          Builder(builder: (_) {
            final df = AppFormats.dateFormat;
            final parts = <String>[
              if (c.createdAt != null)
                '${l.clientSince} ${df.format(c.createdAt!)}',
              if (stats.lastActivity != null)
                '${l.clientLastActivity} · ${df.format(stats.lastActivity!)}',
            ];
            if (parts.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 0),
              child: Text(parts.join('  ·  '),
                  style: AppleTypography.footnote
                      .copyWith(color: colors.tertiaryLabel)),
            );
          }),
          _accountCard(c, stats, l, colors),
          if (stats.invoices.any((i) => i.isIssued)) ...[
            const SizedBox(height: 12),
            AppleButton(
              label: l.clientStatementPdf,
              icon: Icons.description_outlined,
              style: AppleButtonStyle.gray,
              expand: true,
              onPressed: () => _exportStatement(c, stats, l),
            ),
          ],
        ],

        // Coordonnées.
        SectionHeader(
            title: l.clientSectionContact,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        if (_editing) ...[
          AppleCard(
            child: Column(
              children: [
                AppleTextField(
                    controller: _c['phone']!,
                    label: l.fieldPhone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                AppleTextField(controller: _c['email']!, label: l.fieldEmail),
                const SizedBox(height: 12),
                AppleTextField(controller: _c['address']!, label: l.fieldAddress),
              ],
            ),
          ),
          SectionHeader(
              title: l.clientOtherContacts,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          ChannelsEditor(
            initial: _channels,
            onChanged: (v) => _channels = v,
          ),
          SectionHeader(
              title: l.clientOtherAddresses,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AddressesEditor(
            initial: _addresses,
            onChanged: (v) => _addresses = v,
          ),
        ] else ...[
          // Coordonnées unifiées : téléphone + e-mail principaux (synchronisés),
          // puis les canaux supplémentaires. L'adresse principale vit dans la
          // section « Adresses » ci-dessous.
          ClientChannelsCard(
            mainPhone: c.phone,
            mainEmail: c.email,
            channels: c.channels,
          ),
          if ((c.address != null && c.address!.trim().isNotEmpty) ||
              c.addresses.isNotEmpty) ...[
            SectionHeader(
                title: l.clientSectionAddresses,
                padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
            ClientAddressesCard(
                mainAddress: c.address, addresses: c.addresses),
          ],
        ],

        // Entreprise (B2B).
        if (_editing || c.isCompany) ...[
          SectionHeader(
              title: l.clientSectionCompany,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleCard(
            child: _editing
                ? Column(
                    children: [
                      AppleTextField(
                          controller: _c['company']!,
                          label: l.clientCompanyName),
                      const SizedBox(height: 12),
                      AppleTextField(controller: _c['vat']!, label: l.clientVat),
                      const SizedBox(height: 12),
                      AppleTextField(
                          controller: _c['siret']!, label: l.companySiret),
                      const SizedBox(height: 12),
                      AppleTextField(
                          controller: _c['city']!, label: l.clientCity),
                      const SizedBox(height: 12),
                      AppleTextField(
                          controller: _c['billing']!,
                          label: l.clientBillingContact),
                      const SizedBox(height: 12),
                      AppleTextField(
                          controller: _c['terms']!,
                          label: l.clientPaymentTerms),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: AppleTextField(
                              controller: _c['discount']!,
                              label: l.clientDiscount,
                              suffix: '%',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppleTextField(
                              controller: _c['credit']!,
                              label: l.clientCreditLimit,
                              suffix: AppFormats.symbol,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true)),
                        ),
                      ]),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv(l.clientCompanyName, c.companyName, colors, l),
                      _kv(l.clientVat, c.vatNumber, colors, l),
                      if (c.siret != null)
                        _kv(l.companySiret, c.siret, colors, l),
                      _kv(l.clientCity, c.city, colors, l),
                      if (c.billingContact != null)
                        _kv(l.clientBillingContact, c.billingContact, colors, l),
                      if (c.paymentTerms != null)
                        _kv(l.clientPaymentTerms, c.paymentTerms, colors, l),
                      if (c.discountRate > 0)
                        _kv(
                            l.clientDiscount,
                            '${(c.discountRate * 100).toStringAsFixed(0)} %',
                            colors,
                            l),
                      if (c.creditLimit != null)
                        _kv(l.clientCreditLimit,
                            AppFormats.money(c.creditLimit!, decimals: 0), colors, l),
                    ],
                  ),
          ),
        ],

        // Historique & documents du client.
        if (!_editing && !hasActivity)
          // Client sans aucune activité : un seul état vide, avec raccourcis.
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 8),
            child: _SectionEmpty(
              icon: Icons.inbox_outlined,
              message: l.clientNoActivity,
              actionLabel:
                  can.can(Permission.createInvoice) ? l.quickNewInvoice : null,
              onAction:
                  can.can(Permission.createInvoice) ? () => _newInvoice(c) : null,
              secondaryLabel:
                  can.can(Permission.createQuote) ? l.quickNewQuote : null,
              onSecondary:
                  can.can(Permission.createQuote) ? () => _newQuote(c) : null,
            ),
          ),

        if (!_editing && hasActivity) ...[
          // Réparations.
          _histHeader(l.clientSectionHistory, history.length, _allRepairs,
              () => setState(() => _allRepairs = !_allRepairs), l),
          if (history.isEmpty)
            _SectionEmpty(
                icon: Icons.build_outlined, message: l.dashboardNoRepairs)
          else
            AppleListSection(
              children: [
                for (final r in _capped(history, _allRepairs))
                  AppleListRow(
                    leadingIcon: r.kind.icon,
                    leadingTint: r.status.color(colors),
                    title: r.device,
                    subtitle: _repairSubtitle(r, df, l),
                    trailingText: AppFormats.money(r.total, decimals: 0),
                    showChevron: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RepairDetailScreen(reference: r.reference),
                      ),
                    ),
                  ),
              ],
            ),

          // Factures.
          _histHeader(l.clientSectionInvoices, stats.invoices.length,
              _allInvoices, () => setState(() => _allInvoices = !_allInvoices), l),
          if (stats.invoices.isEmpty)
            _SectionEmpty(
              icon: Icons.receipt_long_outlined,
              message: l.clientNoInvoices,
              actionLabel:
                  can.can(Permission.createInvoice) ? l.quickNewInvoice : null,
              onAction:
                  can.can(Permission.createInvoice) ? () => _newInvoice(c) : null,
            )
          else
            AppleListSection(
              children: [
                for (final iv in _capped(stats.invoices, _allInvoices))
                  AppleListRow(
                    leadingIcon: Icons.receipt_long_outlined,
                    leadingTint: iv.effectiveStatus(DateTime.now()).color(colors),
                    title: iv.number.isEmpty ? l.invoiceStatusDraft : iv.number,
                    subtitle:
                        '${iv.effectiveStatus(DateTime.now()).label(l)} · ${df.format(iv.issueDate ?? iv.date)}',
                    trailingText: AppFormats.money(iv.totals.total, decimals: 0),
                    showChevron: true,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => InvoiceDetailScreen(invoiceId: iv.id))),
                  ),
              ],
            ),

          // Devis.
          _histHeader(l.clientSectionQuotes, stats.quotes.length, _allQuotes,
              () => setState(() => _allQuotes = !_allQuotes), l),
          if (stats.quotes.isEmpty)
            _SectionEmpty(
              icon: Icons.description_outlined,
              message: l.clientNoQuotes,
              actionLabel:
                  can.can(Permission.createQuote) ? l.quickNewQuote : null,
              onAction:
                  can.can(Permission.createQuote) ? () => _newQuote(c) : null,
            )
          else
            AppleListSection(
              children: [
                for (final qt in _capped(stats.quotes, _allQuotes))
                  AppleListRow(
                    leadingIcon: Icons.description_outlined,
                    leadingTint: qt.status.color(colors),
                    title: qt.number,
                    subtitle: '${qt.status.label(l)} · ${df.format(qt.date)}',
                    trailingText: AppFormats.money(qt.totals.total, decimals: 0),
                    showChevron: true,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => QuoteDetailScreen(quoteId: qt.id))),
                  ),
              ],
            ),

          // Paiements.
          _histHeader(l.invoiceSectionPayments, ledger.length, _allPayments,
              () => setState(() => _allPayments = !_allPayments), l),
          if (ledger.isEmpty)
            _SectionEmpty(
                icon: Icons.payments_outlined, message: l.paymentsEmpty)
          else
            AppleListSection(
              children: [
                for (final e in _capped(ledger, _allPayments))
                  PaymentLedgerRow(
                    entry: e,
                    df: df,
                    showClient: false,
                    onTap: e.invoiceId == null
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                InvoiceDetailScreen(invoiceId: e.invoiceId!))),
                  ),
              ],
            ),
        ],

        // Segmentation (étiquettes + consentement RGPD).
        if (_editing) ...[
          SectionHeader(
              title: l.clientTags,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleCard(
            child: Column(
              children: [
                AppleTextField(
                    controller: _c['tags']!, hint: l.clientTagsHint),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(l.clientConsent,
                          style: AppleTypography.body
                              .copyWith(color: colors.label)),
                    ),
                    Switch(
                        value: _consent,
                        onChanged: (v) => setState(() => _consent = v)),
                  ],
                ),
              ],
            ),
          ),
        ] else if (c.tags.isNotEmpty || c.marketingConsent) ...[
          SectionHeader(
              title: l.clientTags,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in c.tags)
                        AppleBadge(label: t, color: context.accentColor),
                    ],
                  ),
                if (c.marketingConsent) ...[
                  if (c.tags.isNotEmpty) const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.check_circle, size: 18, color: colors.green),
                    const SizedBox(width: 8),
                    Text(l.clientConsent,
                        style: AppleTypography.subheadline
                            .copyWith(color: colors.secondaryLabel)),
                  ]),
                ],
              ],
            ),
          ),
        ],

        // Notes.
        SectionHeader(
            title: l.repairSectionNotes,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        AppleCard(
          child: _editing
              ? AppleTextField(controller: _c['notes']!, minLines: 2, maxLines: 4)
              : Text(c.notes ?? l.notProvided,
                  style: AppleTypography.body
                      .copyWith(color: colors.secondaryLabel)),
        ),
      ],
    );
  }

  /// Rangée d'actions rapides : contacter + créer un document pour le client.
  Widget _quickActions(Client c, AppLocalizations l, AppleColors colors) {
    final can = ref.read(sessionControllerProvider.notifier);
    final tiles = <_QuickTile>[
      if (c.phone.isNotEmpty)
        _QuickTile(Icons.call, l.actionCall, colors.green,
            () => launchContact(context, Uri(scheme: 'tel', path: c.phone))),
      if (c.phone.isNotEmpty)
        _QuickTile(Icons.chat, l.actionWhatsapp, const Color(0xFF25D366),
            () => launchContact(context, whatsappUri(c.phone))),
      if (c.email != null)
        _QuickTile(Icons.mail_outline, l.actionEmail, colors.blue,
            () => launchContact(context, Uri(scheme: 'mailto', path: c.email))),
      if (can.can(Permission.createQuote))
        _QuickTile(Icons.description_outlined, l.quickNewQuote,
            context.accentColor, () => _newQuote(c)),
      if (can.can(Permission.createInvoice))
        _QuickTile(Icons.receipt_long_outlined, l.quickNewInvoice,
            context.accentColor, () => _newInvoice(c)),
    ];
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [for (final t in tiles) t]),
      ),
    );
  }

  void _newQuote(Client c) {
    final q = ref
        .read(quotesProvider.notifier)
        .create(clientId: c.id, clientName: c.displayName);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuoteDetailScreen(quoteId: q.id)));
  }

  void _newInvoice(Client c) {
    final iv = ref
        .read(invoicesProvider.notifier)
        .create(clientId: c.id, clientName: c.displayName);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InvoiceDetailScreen(invoiceId: iv.id)));
  }

  /// Carte « Compte / Crédit » : crédit disponible, solde net, actions.
  /// Génère et partage le relevé de compte du client (PDF).
  Future<void> _exportStatement(
      Client c, ClientStats stats, AppLocalizations l) async {
    final statement = buildClientStatement(stats.invoices);
    final company = ref.read(companyProvider);
    final rtl = context.isRtl;
    await printStatementDocument(
      appName: company.name.isNotEmpty ? company.name : l.appTitle,
      partyName: c.displayName,
      dateLabel: AppFormats.dateFormat.format(DateTime.now()),
      statement: statement,
      sellerDetails: company.headerLines,
      logo: company.hasLogo ? base64Decode(company.logo) : null,
      rtl: rtl,
      labels: (
        title: l.statementTitle,
        date: l.statementDate,
        detail: l.statementDetail,
        debit: l.statementDebit,
        credit: l.statementCredit,
        balance: l.statementBalance,
        opening: l.statementOpening,
        closing: l.statementClosing,
        invoice: l.statementInvoice,
        deposit: l.statementDeposit,
        payment: l.statementPayment,
      ),
    );
  }

  Widget _accountCard(
      Client c, ClientStats stats, AppLocalizations l, AppleColors colors) {
    final credit = availableCredit(c.id, ref.watch(clientPaymentsProvider));
    final net = stats.outstanding - credit;
    final canPay =
        ref.read(sessionControllerProvider.notifier).can(Permission.recordPayment);
    if (!canPay && credit <= 0.005 && stats.outstanding <= 0.005) {
      return const SizedBox.shrink();
    }
    Widget metric(String label, double v, Color color) => Expanded(
          child: Column(children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(AppFormats.money(v, decimals: 0),
                  style: AppleTypography.title3
                      .copyWith(color: color, fontWeight: FontWeight.w600)),
            ),
            Text(label,
                textAlign: TextAlign.center,
                style: AppleTypography.caption1
                    .copyWith(color: colors.secondaryLabel)),
          ]),
        );
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 12),
      child: AppleCard(
        child: Column(
          children: [
            Row(children: [
              if (credit > 0.005) metric(l.clientCredit, credit, colors.green),
              metric(l.clientNetBalance, net,
                  net > 0.005 ? colors.orange : colors.green),
            ]),
            if (canPay) ...[
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: AppleButton(
                    label: l.clientAddDeposit,
                    icon: Icons.add,
                    style: AppleButtonStyle.tinted,
                    expand: true,
                    onPressed: () => _addDeposit(c, l),
                  ),
                ),
                if (credit > 0.005 && stats.outstanding > 0.005) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppleButton(
                      label: l.clientApplyCredit,
                      icon: Icons.playlist_add_check,
                      style: AppleButtonStyle.tinted,
                      expand: true,
                      onPressed: () =>
                          ref.read(clientPaymentsProvider.notifier).applyCredit(c.id),
                    ),
                  ),
                ],
              ]),
              if (credit > 0.005) ...[
                const SizedBox(height: 8),
                AppleButton(
                  label: l.clientRefund,
                  icon: Icons.undo,
                  style: AppleButtonStyle.gray,
                  expand: true,
                  onPressed: () => _refund(c, l),
                ),
              ],
              if (stats.outstanding > 0.005) ...[
                const SizedBox(height: 8),
                AppleButton(
                  label:
                      '${l.clientSettleAll} (${AppFormats.money(stats.outstanding)})',
                  icon: Icons.done_all,
                  expand: true,
                  onPressed: () => _settleAll(c, l),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addDeposit(Client c, AppLocalizations l) async {
    final result = await showDialog<({double amount, PaymentMethod method})>(
      context: context,
      builder: (_) => _DepositDialog(title: l.clientAddDeposit),
    );
    if (result == null) return;
    ref
        .read(clientPaymentsProvider.notifier)
        .addDeposit(c.id, result.amount, result.method);
  }

  Future<void> _refund(Client c, AppLocalizations l) async {
    final result = await showDialog<({double amount, PaymentMethod method})>(
      context: context,
      builder: (_) => _DepositDialog(title: l.clientRefund),
    );
    if (result == null) return;
    ref
        .read(clientPaymentsProvider.notifier)
        .refund(c.id, result.amount, result.method);
  }

  /// Solde toutes les factures dues du client avec un moyen de paiement choisi.
  Future<void> _settleAll(Client c, AppLocalizations l) async {
    final method = await showAppleSelectionSheet<PaymentMethod>(
      context: context,
      title: l.clientSettleAll,
      selected: PaymentMethod.cash,
      options: [
        for (final m in PaymentMethodX.manual) AppleSheetOption(m, m.label(l)),
      ],
    );
    if (method == null) return;
    ref.read(invoicesProvider.notifier).settleClient(c.id, method);
  }

  /// N premiers éléments (ou tous si [expanded]).
  List<T> _capped<T>(List<T> items, bool expanded) =>
      expanded ? items : items.take(_cap).toList();

  /// En-tête d'historique avec bascule « Voir tout / Réduire » au-delà de [_cap].
  Widget _histHeader(String title, int total, bool expanded,
      VoidCallback onToggle, AppLocalizations l) {
    final over = total > _cap;
    return SectionHeader(
      title: title,
      padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8),
      actionLabel: over ? (expanded ? l.commonShowLess : l.commonSeeAll) : null,
      onAction: over ? onToggle : null,
    );
  }

  /// Sous-titre d'une réparation : référence · statut (· date si connue).
  String _repairSubtitle(Repair r, DateFormat df, AppLocalizations l) {
    final date = r.completedAt ?? r.createdAt;
    final base = '${r.reference} · ${r.status.label(l)}';
    return date == null ? base : '$base · ${df.format(date)}';
  }

  Widget _kv(String label, String? value, AppleColors colors, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
          ),
          Expanded(
            child: Text(value ?? l.notProvided,
                style: AppleTypography.body.copyWith(color: colors.label)),
          ),
        ],
      ),
    );
  }
}

/// État vide « intelligent » d'une section : icône discrète + message, avec
/// jusqu'à deux raccourcis de création optionnels.
class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final hasPrimary = actionLabel != null && onAction != null;
    final hasSecondary = secondaryLabel != null && onSecondary != null;
    return AppleCard(
      child: Column(
        children: [
          Icon(icon, size: 38, color: colors.tertiaryLabel),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
          if (hasPrimary || hasSecondary) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (hasPrimary)
                  AppleButton(
                      label: actionLabel!,
                      icon: Icons.add,
                      style: AppleButtonStyle.tinted,
                      onPressed: onAction),
                if (hasSecondary)
                  AppleButton(
                      label: secondaryLabel!,
                      icon: Icons.add,
                      style: AppleButtonStyle.tinted,
                      onPressed: onSecondary),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialogue montant + moyen de paiement (acompte ou remboursement).
class _DepositDialog extends StatefulWidget {
  const _DepositDialog({required this.title});
  final String title;

  @override
  State<_DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<_DepositDialog> {
  final _amount = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    if (v <= 0) return;
    Navigator.of(context).pop((amount: v, method: _method));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return AlertDialog(
      backgroundColor: colors.secondaryGroupedBackground,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppleTextField(
            controller: _amount,
            label: l.invoiceAmount,
            suffix: AppFormats.symbol,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in PaymentMethodX.manual)
                AppleChip(
                    label: m.label(l),
                    selected: _method == m,
                    onTap: () => setState(() => _method = m)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l.commonSave)),
      ],
    );
  }
}

/// Tuile d'action rapide : pastille d'icône colorée + libellé.
class _QuickTile extends StatelessWidget {
  const _QuickTile(this.icon, this.label, this.tint, this.onTap);

  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                  color: tint.withValues(alpha: 0.14),
                  shape: AppleRadii.shape(AppleRadii.lg)),
              child: Icon(icon, color: tint, size: 22),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppleTypography.caption1
                      .copyWith(color: colors.secondaryLabel)),
            ),
          ],
        ),
      ),
    );
  }
}
