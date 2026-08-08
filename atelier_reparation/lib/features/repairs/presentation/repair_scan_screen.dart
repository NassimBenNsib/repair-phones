import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../application/repair_qr_codec.dart';
import '../application/repairs_controller.dart';

/// Le scan par caméra est possible sur Web / Android / iOS / macOS.
/// `mobile_scanner` n'implémente pas Windows/Linux → on n'y crée jamais le
/// contrôleur caméra (seule la saisie manuelle est proposée).
bool get cameraScanSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// Scanner le QR d'une réparation. Renvoie (via `pop`) la référence trouvée,
/// ou `null` si l'utilisateur ferme sans scanner.
class RepairScanScreen extends ConsumerStatefulWidget {
  const RepairScanScreen({super.key});

  @override
  ConsumerState<RepairScanScreen> createState() => _RepairScanScreenState();
}

class _RepairScanScreenState extends ConsumerState<RepairScanScreen> {
  MobileScannerController? _controller;
  final _manual = TextEditingController();
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    if (cameraScanSupported) {
      _controller = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    }
    _manual.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _manual.dispose();
    super.dispose();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  /// Ouvre la réparation si la référence existe ; sinon signale (sauf en flux
  /// caméra continu où l'on n'inonde pas de messages).
  void _open(String reference, {required bool silentIfMissing}) {
    if (_handled) return;
    final exists =
        ref.read(repairsProvider.notifier).byRef(reference) != null;
    if (!exists) {
      if (!silentIfMissing) {
        _snack(AppLocalizations.of(context).repairScanNotFound);
      }
      return;
    }
    _handled = true;
    _controller?.stop();
    Navigator.of(context).pop(reference);
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final ref = RepairQrCodec.tryDecode(raw);
      if (ref == null) continue; // pas un QR de réparation → on ignore
      _open(ref, silentIfMissing: true);
      if (_handled) return;
    }
  }

  void _openManual() {
    final ref = RepairQrCodec.tryDecode(_manual.text);
    if (ref == null) {
      _snack(AppLocalizations.of(context).repairScanNotFound);
      return;
    }
    _open(ref, silentIfMissing: false);
  }

  Future<void> _decodeImage() async {
    final c = _controller;
    if (c == null) return;
    const group =
        XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg']);
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    try {
      final capture = await c.analyzeImage(file.path);
      for (final b in capture?.barcodes ?? const <Barcode>[]) {
        final raw = b.rawValue;
        if (raw == null) continue;
        final ref = RepairQrCodec.tryDecode(raw);
        if (ref != null) {
          _open(ref, silentIfMissing: false);
          if (_handled) return;
        }
      }
      if (mounted && !_handled) {
        _snack(AppLocalizations.of(context).repairScanError);
      }
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).repairScanError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        title: Text(l.repairScan),
        backgroundColor: colors.groupedBackground,
        foregroundColor: colors.label,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _cameraArea(l, colors)),
            _manualPanel(l, colors),
          ],
        ),
      ),
    );
  }

  Widget _cameraArea(AppLocalizations l, AppleColors colors) {
    final controller = _controller;
    if (controller == null) {
      return _placeholder(
          Icons.no_photography_outlined, l.repairScanUnavailable, colors);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _onDetect,
          errorBuilder: (context, error) => _placeholder(
              Icons.videocam_off_outlined, l.repairScanCameraError, colors),
        ),
        // Viseur.
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(l.repairScanHint,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(IconData icon, String text, AppleColors colors) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: colors.tertiaryLabel),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: AppleTypography.subheadline
                      .copyWith(color: colors.secondaryLabel)),
            ],
          ),
        ),
      );

  Widget _manualPanel(AppLocalizations l, AppleColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(color: colors.secondaryGroupedBackground),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.repairScanManual,
              style: AppleTypography.footnote
                  .copyWith(color: colors.secondaryLabel)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppleTextField(
                  controller: _manual,
                  label: l.repairScanReference,
                  onSubmitted: (_) => _openManual(),
                ),
              ),
              const SizedBox(width: 8),
              AppleButton(
                label: l.repairScanOpen,
                onPressed: _manual.text.trim().isEmpty ? null : _openManual,
              ),
            ],
          ),
          if (_controller != null) ...[
            const SizedBox(height: 10),
            AppleButton(
              label: l.repairScanFromImage,
              icon: Icons.image_outlined,
              style: AppleButtonStyle.gray,
              expand: true,
              onPressed: _decodeImage,
            ),
          ],
        ],
      ),
    );
  }
}
