import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/layout_prefs.dart';
import '../../../core/settings/settings_controller.dart';

/// Échafaudage « grand titre » façon iOS, avec barre supérieure en verre dépoli.
///
/// Le contenu défile *sous* la barre translucide ; le grand titre défile avec le
/// contenu puis, une fois passé le seuil, un titre condensé apparaît dans la
/// barre (avec un filet de séparation). Le contenu est fourni en slivers.
class AppleScaffold extends ConsumerStatefulWidget {
  const AppleScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.actions = const [],
    this.maxContentWidth = 840,
  });

  final String title;
  final List<Widget> slivers;
  final List<Widget> actions;

  /// Largeur maximale du contenu (centré) sur grand écran. `double.infinity`
  /// pour occuper toute la largeur.
  final double maxContentWidth;

  @override
  ConsumerState<AppleScaffold> createState() => _AppleScaffoldState();
}

class _AppleScaffoldState extends ConsumerState<AppleScaffold> {
  final _controller = ScrollController();
  static const double _barHeight = 44;
  static const double _threshold = 40;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed = _controller.offset > _threshold;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final topInset = MediaQuery.paddingOf(context).top;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final stretch = ref.watch(settingsControllerProvider
            .select((s) => s.contentWidth)) ==
        ContentWidth.stretch;
    final maxW = stretch ? double.infinity : widget.maxContentWidth;

    final scrollView = CustomScrollView(
      controller: _controller,
      slivers: [
        // Espace réservé sous la barre en verre.
        SliverToBoxAdapter(child: SizedBox(height: topInset + _barHeight)),
        // Grand titre défilant.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 8),
            child: Text(
              widget.title,
              style: AppleTypography.largeTitle.copyWith(color: colors.label),
            ),
          ),
        ),
        ...widget.slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );

    return ColoredBox(
      color: colors.groupedBackground,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: scrollView,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassSurface(
              colors: colors,
              enabled: !reduceMotion,
              border: Border(
                bottom: BorderSide(
                  color: _collapsed ? colors.separator : Colors.transparent,
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: topInset),
                child: SizedBox(
                  height: _barHeight,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedOpacity(
                                duration: AppleMotion.fast,
                                opacity: _collapsed ? 1 : 0,
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: AppleTypography.headline
                                      .copyWith(color: colors.label),
                                ),
                              ),
                            ),
                            ...widget.actions,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
