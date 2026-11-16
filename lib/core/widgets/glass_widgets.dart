import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../ui/app_motion.dart';

/// A frosted glass container with blur, gradient, and subtle border.
/// Adapted for the blush-pink luxury theme.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final bool withGoldBorder;
  final Color? borderColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blur = 15,
    this.opacity = 0.5,
    this.withGoldBorder = false,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightPink.withValues(alpha: (opacity + 0.25).clamp(0, 1)),
                  AppColors.lightPink.withValues(alpha: opacity),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: withGoldBorder
                    ? AppColors.champagneGold.withValues(alpha: 0.85)
                    : (borderColor ?? AppColors.rosePink.withValues(alpha: 0.55)),
                width: withGoldBorder ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rosePink.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Floating glass bottom navigation bar container (soft pink).
class GlassNavBar extends StatelessWidget {
  final Widget child;
  const GlassNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightPink.withValues(alpha: 0.97),
                  AppColors.blushPink.withValues(alpha: 0.90),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.rosePink.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rosePink.withValues(alpha: 0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Luxury background with soft pink gradient and glowing rose accents.
class LuxuryBackground extends StatelessWidget {
  final Widget child;
  final bool showGlow;

  const LuxuryBackground({
    super.key,
    required this.child,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.splashGradient),
      child: showGlow
          ? Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: _glow(AppColors.roseRed.withValues(alpha: 0.12)),
                ),
                Positioned(
                  bottom: 100,
                  left: -80,
                  child: _glow(AppColors.rosePink.withValues(alpha: 0.45)),
                ),
                child,
              ],
            )
          : child,
    );
  }

  Widget _glow(Color color) => Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      );
}

/// Ambient rose glow circle for background decoration.
class GoldGlow extends StatelessWidget {
  final double size;
  final double opacity;
  final Alignment alignment;

  const GoldGlow({
    super.key,
    this.size = 200,
    this.opacity = 0.08,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.roseRed.withValues(alpha: opacity + 0.10),
              AppColors.rosePink.withValues(alpha: opacity),
              AppColors.rosePink.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gold shimmer text effect (kept for compatibility; reads well on pink too).
class GoldText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final bool usePlayfair;

  const GoldText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
    this.textAlign,
    this.usePlayfair = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AppColors.goldShimmer,
          AppColors.champagneGold,
          AppColors.metallicGold,
          AppColors.champagneGold,
          AppColors.goldShimmer,
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: usePlayfair ? 'Playfair Display' : 'Poppins',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
          letterSpacing: usePlayfair ? 1.5 : 0,
        ),
      ),
    );
  }
}

/// Simple circular glow for rose accents.
class RoseGlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const RoseGlowCircle({super.key, this.size = 220, this.color = AppColors.metallicGold});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// A delicate rose flower petal decoration.
class FloralAccent extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  const FloralAccent({
    super.key,
    this.size = 28,
    this.color = AppColors.metallicGold,
    this.icon = Icons.local_florist_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color.withValues(alpha: 0.55));
  }
}

/// A gold gradient button matching the luxury design.
///
/// Press feedback combines a scale dip, a champagne shine that sweeps across
/// the gradient while held, and an arrow that nudges forward. An idle shimmer
/// runs every few seconds when [idleShine] is true so primary actions catch
/// the eye without shifting layout.
class LuxuryGoldButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool showArrow;
  final double? width;
  final Color textColor;
  final double fontSize;
  final double height;

  /// Slow repeating shimmer for the hero-level actions.
  final bool idleShine;

  const LuxuryGoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.showArrow = true,
    this.width,
    this.textColor = AppColors.textBlack,
    this.fontSize = 15,
    this.height = 56,
    this.idleShine = true,
  });

  @override
  State<LuxuryGoldButton> createState() => _LuxuryGoldButtonState();
}

class _LuxuryGoldButtonState extends State<LuxuryGoldButton>
    with TickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;
  late final AnimationController _shine;
  Timer? _idleTimer;

  bool get _enabled => !widget.isLoading && widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1, end: 0.965).animate(
      CurvedAnimation(parent: _press, curve: AppMotion.press),
    );
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.idleShine || AppMotion.reduced(context)) {
      _idleTimer?.cancel();
      _idleTimer = null;
      return;
    }
    _idleTimer ??= Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && _shine.isDismissed) _shine.forward();
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _press.dispose();
    _shine.dispose();
    super.dispose();
  }

  void _handleDown() {
    if (!_enabled) return;
    _press.forward();
    _shine.forward(from: 0);
    HapticFeedback.selectionClick();
  }

  void _handleUp() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: Semantics(
        button: true,
        enabled: _enabled,
        label: widget.text,
        child: MouseRegion(
          cursor:
              _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTapDown: (_) => _handleDown(),
            onTapUp: (_) => _handleUp(),
            onTapCancel: _handleUp,
            child: AnimatedBuilder(
              animation: _scale,
              builder: (context, child) =>
                  Transform.scale(scale: _scale.value, child: child),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _enabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(16),
                  splashColor:
                      AppColors.champagneLight.withValues(alpha: 0.45),
                  highlightColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.goldButtonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.roseRed.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(child: _buildContent()),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _shine,
                                builder: (context, _) =>
                                    _buildShine(_shine.value),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShine(double t) {
    if (t <= 0 || t >= 1) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        const double bandWidth = 68;
        final double travel = constraints.maxWidth + bandWidth * 2;
        return Transform.translate(
          offset: Offset(-bandWidth + travel * t, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: bandWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.45),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.textColor,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: widget.textColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: GoogleFonts.poppins(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w700,
            color: widget.textColor,
          ),
        ),
        if (widget.showArrow) ...[
          const SizedBox(width: 10),
          AnimatedBuilder(
            animation: _press,
            builder: (context, child) => Transform.translate(
              offset: Offset(3 * _press.value, 0),
              child: child,
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: widget.textColor,
            ),
          ),
        ],
      ],
    );
  }
}
