import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../application/session_controller.dart';

enum _Mode { email, pin }

/// Écran de connexion : e-mail + mot de passe, ou code PIN comptoir.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String routePath = '/login';
  static const String routeName = 'login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _Mode _mode = _Mode.email;
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _pin = '';
  bool _error = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submitEmail() {
    final ok = ref
        .read(sessionControllerProvider.notifier)
        .loginEmail(_email.text, _password.text);
    if (!ok) setState(() => _error = true);
  }

  void _onDigit(String d) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length >= 4) _tryPin();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _tryPin() {
    final ok = ref.read(sessionControllerProvider.notifier).loginPin(_pin);
    if (!ok) {
      setState(() {
        _error = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final accent = context.accentColor;

    return Scaffold(
      backgroundColor: colors.groupedBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: ShapeDecoration(
                      color: accent.withValues(alpha: 0.16),
                      shape: AppleRadii.shape(AppleRadii.xl),
                    ),
                    child: Icon(Icons.handyman, color: accent, size: 34),
                  ),
                  const SizedBox(height: 16),
                  Text(l.appTitle,
                      style:
                          AppleTypography.title1.copyWith(color: colors.label)),
                  const SizedBox(height: 4),
                  Text(l.authLoginTitle,
                      style: AppleTypography.subheadline
                          .copyWith(color: colors.secondaryLabel)),
                  const SizedBox(height: 24),
                  AppleSegmentedControl<_Mode>(
                    value: _mode,
                    onChanged: (m) => setState(() {
                      _mode = m;
                      _error = false;
                      _pin = '';
                    }),
                    segments: {
                      _Mode.email: l.authModeEmail,
                      _Mode.pin: l.authModePin,
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_mode == _Mode.email)
                    _emailForm(l)
                  else
                    _pinPad(colors, accent),
                  if (_error) ...[
                    const SizedBox(height: 16),
                    Text(l.authError,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.red)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailForm(AppLocalizations l) {
    return Column(
      children: [
        AppleTextField(
            controller: _email,
            label: l.authModeEmail,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        AppleTextField(
            controller: _password,
            label: l.authPassword,
            obscureText: true,
            onSubmitted: (_) => _submitEmail()),
        const SizedBox(height: 20),
        AppleButton(
            label: l.authSignIn,
            icon: Icons.login,
            expand: true,
            onPressed: _submitEmail),
      ],
    );
  }

  Widget _pinPad(AppleColors colors, Color accent) {
    return Column(
      children: [
        // Points de saisie.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 6; i++)
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? accent : colors.fill,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) _key(d, colors)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 76),
            _key('0', colors),
            _iconKey(Icons.backspace_outlined, colors, _onBackspace),
          ],
        ),
      ],
    );
  }

  Widget _key(String d, AppleColors colors) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: () => _onDigit(d),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: colors.secondaryGroupedBackground,
            shape: AppleRadii.shape(AppleRadii.xl),
          ),
          child: Text(d,
              style: AppleTypography.title2.copyWith(color: colors.label)),
        ),
      ),
    );
  }

  Widget _iconKey(IconData icon, AppleColors colors, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(icon, color: colors.secondaryLabel),
        ),
      ),
    );
  }
}
