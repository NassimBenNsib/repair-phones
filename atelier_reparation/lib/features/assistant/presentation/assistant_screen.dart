import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/anthropic_client.dart';
import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../repairs/application/repairs_controller.dart';
import '../application/assistant_config.dart';
import '../application/shop_context.dart';

class _Msg {
  const _Msg(this.role, this.text);
  final String role; // 'user' | 'assistant'
  final String text;
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  static const String routeName = 'assistant';
  static const String routePath = '/assistant';

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    final config = ref.read(assistantConfigProvider);
    if (!config.hasKey) {
      _openConfig();
      return;
    }
    setState(() {
      _messages.add(_Msg('user', text));
      _busy = true;
      _input.clear();
    });
    _scrollToEnd();

    final l = AppLocalizations.of(context);
    try {
      final context0 = buildShopContext(
        repairs: ref.read(repairsProvider),
        invoices: ref.read(invoicesProvider),
        products: ref.read(catalogProvider),
        now: DateTime.now(),
      );
      final system =
          'Tu es l\'assistant d\'une application de gestion d\'atelier de '
          'réparation. Réponds de façon concise et utile, dans la langue de '
          'l\'utilisateur. Voici l\'état actuel de l\'atelier :\n\n$context0';
      final reply = await AnthropicClient(
        apiKey: config.apiKey,
        model: config.model,
      ).ask(
        system: system,
        messages: [
          for (final m in _messages) {'role': m.role, 'content': m.text},
        ],
      );
      if (!mounted) return;
      setState(() => _messages.add(_Msg('assistant', reply)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _messages.add(_Msg('assistant', l.assistantError)));
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _openConfig() async {
    final l = AppLocalizations.of(context);
    final config = ref.read(assistantConfigProvider);
    final keyCtrl = TextEditingController(text: config.apiKey);
    final modelCtrl = TextEditingController(text: config.model);
    await showAppleSheet<void>(
      context: context,
      title: l.assistantConfig,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppleTextField(
                controller: keyCtrl,
                label: l.assistantApiKey,
                obscureText: true),
            const SizedBox(height: 12),
            AppleTextField(controller: modelCtrl, label: l.assistantModel),
            const SizedBox(height: 16),
            AppleButton(
              label: l.commonSave,
              expand: true,
              onPressed: () {
                ref.read(assistantConfigProvider.notifier).save(
                      config.copyWith(
                        apiKey: keyCtrl.text.trim(),
                        model: modelCtrl.text.trim().isEmpty
                            ? config.model
                            : modelCtrl.text.trim(),
                      ),
                    );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    keyCtrl.dispose();
    modelCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final hasKey = ref.watch(assistantConfigProvider).hasKey;

    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        backgroundColor: colors.groupedBackground,
        title: Text(l.navAssistant),
        actions: [
          IconButton(
            onPressed: _openConfig,
            icon: Icon(Icons.settings_outlined, color: context.accentColor),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              children: [
                _Bubble(role: 'assistant', text: l.assistantIntro),
                if (!hasKey)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l.assistantNoKey,
                        textAlign: TextAlign.center,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                  ),
                for (final m in _messages)
                  _Bubble(role: m.role, text: m.text),
                if (_busy)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(l.assistantThinking,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppleTextField(
                      controller: _input,
                      hint: l.assistantPlaceholder,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.arrow_upward),
                    style: IconButton.styleFrom(
                        backgroundColor: context.accentColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.role, required this.text});
  final String role;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: ShapeDecoration(
          color: isUser ? context.accentColor : colors.secondaryGroupedBackground,
          shape: AppleRadii.shape(AppleRadii.lg),
        ),
        child: Text(text,
            style: AppleTypography.body
                .copyWith(color: isUser ? Colors.white : colors.label)),
      ),
    );
  }
}
