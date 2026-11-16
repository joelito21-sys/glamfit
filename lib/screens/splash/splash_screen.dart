import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/dreamy_background.dart';
import '../../core/widgets/glass_widgets.dart';

/// Animated brand intro.
///
/// Plays a single one-shot reveal over the animated [DreamyBackground]:
///
///  1. A champagne light ring blooms outward behind the mark
///  2. The crowned gold gown fades and settles into place
///  3. The `GlamFit` wordmark rises through a gold gradient
///  4. The `RENT · WEAR · SHINE` line fades up beneath it
///  5. The entry actions fade up last
///
/// Everything is driven by one [AnimationController] and one
/// [AnimatedBuilder], so the whole sequence stays in sync and costs a
/// single ticker. Values are derived from [AnimationController.value]
/// rather than stacked [CurvedAnimation]s, which keeps the timeline easy
/// to read and cheap to allocate.
///
/// Layout notes:
///  * The entry actions are the point of this screen, so they are pinned
///    to the bottom of the available height rather than being pushed out
///    of it by the mark. The mark scales with the space that is left.
///  * If the window is shorter than [minContentHeight] the reveal becomes
///    scrollable instead of clipping the actions out of reach.
///  * Above [maxContentWidth] the composition stays centred, so Flutter
///    web and tablet windows do not stretch a phone layout edge to edge.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Brand mark artwork (transparent PNG, bundled via `image/`).
  static const String _markAsset = 'image/gold_gown_logo.png';

  /// Shortest height the reveal needs before it starts scrolling.
  static const double minContentHeight = 560;

  /// The reveal is a phone-width composition at heart.
  static const double maxContentWidth = 440;

  /// Reference sizes the reveal was designed against.
  static const double _designMarkBox = 246;
  static const double _referenceRing = 232;
  static const double _referenceMark = 186;
  static const double _referenceWordSize = 54;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Normalised 0..1 progress of the segment [start]..[end].
  double _segment(double start, double end) {
    if (end <= start) return 1;
    return ((_controller.value - start) / (end - start)).clamp(0.0, 1.0);
  }

  /// Segment progress with [curve] applied.
  double _curve(double start, double end, Curve curve) =>
      curve.transform(_segment(start, end));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blushPink,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DreamyBackground(petalCount: 14, particleCount: 14),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double available = constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : minContentHeight;
                final bool needsScroll = available < minContentHeight;
                final double contentHeight =
                    needsScroll ? minContentHeight : available;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: SingleChildScrollView(
                      physics: needsScroll
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        height: contentHeight,
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) =>
                              _buildReveal(context, contentHeight),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReveal(BuildContext context, double height) {
    // ── Timeline ──
    final ringProgress = _curve(0.00, 0.34, Curves.easeOutCubic);
    final ringOpacity = _curve(0.00, 0.20, Curves.easeOut);
    final markScale = _curve(0.06, 0.42, Curves.easeOutBack);
    final markOpacity = _curve(0.06, 0.26, Curves.easeOut);
    final wordProgress = _curve(0.30, 0.60, Curves.easeOutCubic);
    final taglineProgress = _curve(0.46, 0.68, Curves.easeOut);
    final actionsProgress = _curve(0.64, 0.92, Curves.easeOutCubic);

    // Scale the mark to the space actually available, so a short window
    // shrinks the artwork instead of losing the actions below the fold.
    final double markBox =
        (height * 0.34).clamp(_designMarkBox * 0.6, _designMarkBox);
    final double scale = markBox / _designMarkBox;
    final double ringSize = _referenceRing * scale;
    final double markHeight = _referenceMark * scale;
    final double wordSize = (_referenceWordSize * scale)
        .clamp(_referenceWordSize * 0.66, _referenceWordSize);

    final Widget mark = SizedBox(
      height: markBox,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: ringOpacity,
            child: Transform.scale(
              scale: 0.55 + ringProgress * 0.45,
              child: Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lightPink.withValues(alpha: 0.92),
                      AppColors.champagneLight.withValues(alpha: 0.34),
                      AppColors.champagneGold.withValues(alpha: 0.10),
                      AppColors.champagneGold.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 0.78, 1.0],
                  ),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.42),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagneGold.withValues(alpha: 0.28),
                      blurRadius: 34 * scale,
                      spreadRadius: 6 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Opacity(
            opacity: markOpacity,
            child: Transform.scale(
              scale: 0.84 + markScale * 0.16,
              child: Image.asset(
                _markAsset,
                height: markHeight,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.checkroom_rounded,
                  size: markHeight * 0.52,
                  color: AppColors.champagneGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final Widget wordmark = Opacity(
      opacity: wordProgress,
      child: Transform.translate(
        offset: Offset(0, (1 - wordProgress) * 22),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAEAEA),
              AppColors.champagneGold,
              AppColors.champagneDark,
            ],
            stops: [0.0, 0.52, 1.0],
          ).createShader(bounds),
          child: Text(
            'GlamFit',
            style: GoogleFonts.playfairDisplay(
              fontSize: wordSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.1,
            ),
          ),
        ),
      ),
    );

    final Widget tagline = Opacity(
      opacity: taglineProgress,
      child: Transform.translate(
        offset: Offset(0, (1 - taglineProgress) * 12),
        child: Text(
          'RENT  ·  WEAR  ·  SHINE',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 3.2,
            color: AppColors.deepRose.withValues(alpha: 0.88),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // The brand block stays together at the top; the entry actions
          // are pinned to the bottom so they can never fall off-screen.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              mark,
              const SizedBox(height: 4),
              wordmark,
              const SizedBox(height: 10),
              tagline,
            ],
          ),
          Opacity(
            opacity: actionsProgress,
            child: Transform.translate(
              offset: Offset(0, (1 - actionsProgress) * 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 280,
                    child: LuxuryGoldButton(
                      text: 'Get Started',
                      showArrow: true,
                      onPressed: widget.onComplete,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: widget.onComplete,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.roseRed.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
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
