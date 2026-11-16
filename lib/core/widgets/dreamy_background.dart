import 'dart:math';

import 'package:flutter/material.dart';

/// Luxurious, dreamy animated background.
///
/// Layers (back to front):
///  1. Blush → pastel pink radial gradient base
///  2. Flowing silk fabric waves hugging the upper-left and bottom edges
///     (translucent pink ribbons with glossy highlight bands)
///  3. Thin champagne-gold glowing curves flowing diagonally near the bottom
///  4. Soft bokeh light orbs that breathe in and out
///  5. Delicate floating rose petals drifting upward with a gentle sway
///
/// The centre of the screen is kept deliberately clean so a logo can sit on
/// top of this widget.
///
/// Performance notes:
///  * Everything is drawn in a single [CustomPainter] driven by ONE ticker,
///    wrapped in a [RepaintBoundary] so only this layer repaints.
///  * Blur is faked with radial gradients instead of ImageFilter blur — far
///    cheaper on mobile GPUs and avoids backdrop-filter cost.
///  * Deterministic pseudo-random layout (seeded) so the composition is
///    stable across frames and identical on every launch.
class DreamyBackground extends StatefulWidget {
  /// Number of drifting petals. Fewer = better perf on low-end devices.
  final int petalCount;

  /// Number of breathing bokeh orbs.
  final int particleCount;

  final bool animate;

  const DreamyBackground({
    super.key,
    this.petalCount = 9,
    this.particleCount = 10,
    this.animate = true,
  });

  @override
  State<DreamyBackground> createState() => _DreamyBackgroundState();
}

class _DreamyBackgroundState extends State<DreamyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _DreamyPainter(
              t: widget.animate ? _controller.value : 0,
              petalCount: widget.petalCount,
              particleCount: widget.particleCount,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _DreamyPainter extends CustomPainter {
  final double t;
  final int petalCount;
  final int particleCount;

  _DreamyPainter({
    required this.t,
    required this.petalCount,
    required this.particleCount,
  });

  // ── Palette ──
  static const Color _blushBase = Color(0xFF080808);
  static const Color _pastelPink = Color(0xFF171717);
  static const Color _silkPink = Color(0xFF242424);
  static const Color _silkDeep = Color(0xFF303030);
  static const Color _ribbonLight = Color(0xFFBDBDBD);
  static const Color _gold = Color(0xFFD4D4D4);
  static const Color _goldSoft = Color(0xFFEAEAEA);

  @override
  void paint(Canvas canvas, Size size) {
    _paintBase(canvas, size);
    _paintBokeh(canvas, size);
    _paintSilkTopLeft(canvas, size);
    _paintSilkBottom(canvas, size);
    _paintGoldCurves(canvas, size);
    _paintPetals(canvas, size);
  }

  // ── Layer 1: gradient base ──
  void _paintBase(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Diagonal blush wash.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blushBase, _pastelPink, _blushBase],
        ).createShader(rect),
    );
    // Bright centre halo — keeps the logo area luminous and clean.
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      size.width * 0.75,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.42),
          radius: size.width * 0.75,
        )),
    );
    // Warm rose corner glows.
    _drawGlow(canvas, Offset(-size.width * 0.15, -size.height * 0.10),
        size.width * 0.65, _silkDeep.withValues(alpha: 0.12));
    _drawGlow(canvas, Offset(size.width * 1.08, size.height * 1.05),
        size.width * 0.70, _silkPink.withValues(alpha: 0.12));
  }

  void _drawGlow(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  // ── Layer 2a: silk waves upper-left ──
  void _paintSilkTopLeft(Canvas canvas, Size size) {
    // Three stacked translucent ribbons flowing from the top-left corner
    // downward-right, each with a slightly different phase so the fold
    // appears to travel slowly through the fabric.
    final specs = [
      (phase: 0.00, drop: 0.10, amp: 0.055, alpha: 0.55, deep: false),
      (phase: 0.18, drop: 0.16, amp: 0.075, alpha: 0.42, deep: true),
      (phase: 0.36, drop: 0.24, amp: 0.060, alpha: 0.34, deep: false),
    ];

    for (final s in specs) {
      final path = Path()
        ..moveTo(-size.width * 0.05, -size.height * 0.05);
      // Right edge of ribbon: a sine flowing down the left half of the screen.
      const segments = 32;
      for (var i = 0; i <= segments; i++) {
        final p = i / segments;
        final x = -size.width * 0.05 + p * (size.width * 0.72);
        final wave = sin((p * 2.1 + s.phase + t * 2 * pi) * pi) *
            size.height * s.amp;
        final y = s.drop * size.height + wave + p * size.height * 0.10;
        path.lineTo(x, y);
      }
      // Sweep back up the left edge to close the ribbon.
      path.lineTo(-size.width * 0.05, s.drop * size.height + size.height * 0.28);
      path.close();

      final base = (s.deep ? _silkDeep : _silkPink).withValues(alpha: s.alpha);
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [base, base.withValues(alpha: 0)],
            stops: const [0.15, 1.0],
          ).createShader(Offset.zero & size),
      );

      // Glossy highlight band riding on the ribbon crest.
      final hiPath = Path()
        ..moveTo(-size.width * 0.05, -size.height * 0.05);
      for (var i = 0; i <= segments; i++) {
        final p = i / segments;
        final x = -size.width * 0.05 + p * (size.width * 0.72);
        final wave = sin((p * 2.1 + s.phase + t * 2 * pi) * pi) *
            size.height * s.amp;
        final y = s.drop * size.height + wave + p * size.height * 0.10 +
            size.height * 0.012;
        hiPath.lineTo(x, y);
      }
      hiPath.lineTo(-size.width * 0.05, -size.height * 0.02);
      hiPath.close();
      canvas.drawPath(
        hiPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _ribbonLight.withValues(alpha: s.alpha * 0.85),
              _ribbonLight.withValues(alpha: 0),
            ],
            stops: const [0.05, 0.85],
          ).createShader(Offset.zero & size),
      );
    }
  }

  // ── Layer 2b: silk waves along the bottom ──
  void _paintSilkBottom(Canvas canvas, Size size) {
    final specs = [
      (phase: 0.50, lift: 0.16, amp: 0.050, alpha: 0.50, deep: true),
      (phase: 0.68, lift: 0.11, amp: 0.065, alpha: 0.40, deep: false),
      (phase: 0.86, lift: 0.06, amp: 0.045, alpha: 0.55, deep: true),
    ];

    for (final s in specs) {
      final path = Path()
        ..moveTo(-size.width * 0.05, size.height * (1 + 0.05));
      const segments = 40;
      for (var i = 0; i <= segments; i++) {
        final p = i / segments;
        final x = -size.width * 0.05 + p * (size.width * 1.10);
        final wave = sin((p * 3.0 + s.phase + t * 2 * pi) * pi) *
            size.height * s.amp;
        final y = size.height * (1 - s.lift) + wave + p * size.height * 0.04;
        path.lineTo(x, y);
      }
      path.lineTo(size.width * 1.05, size.height * 1.05);
      path.lineTo(-size.width * 0.05, size.height * 1.05);
      path.close();

      final base = (s.deep ? _silkDeep : _silkPink).withValues(alpha: s.alpha);
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [base.withValues(alpha: s.alpha * 0.6), base],
            stops: const [0.0, 0.7],
          ).createShader(Offset.zero & size),
      );

      // Pearl-like sheen along the top edge of each fold.
      final hiPath = Path();
      for (var i = 0; i <= segments; i++) {
        final p = i / segments;
        final x = -size.width * 0.05 + p * (size.width * 1.10);
        final wave = sin((p * 3.0 + s.phase + t * 2 * pi) * pi) *
            size.height * s.amp;
        final y = size.height * (1 - s.lift) + wave + p * size.height * 0.04;
        if (i == 0) {
          hiPath.moveTo(x, y);
        } else {
          hiPath.lineTo(x, y);
        }
      }
      canvas.drawPath(
        hiPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.height * 0.010
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _ribbonLight.withValues(alpha: 0),
              _ribbonLight.withValues(alpha: s.alpha * 1.6),
              _ribbonLight.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Offset.zero & size),
      );
    }
  }

  // ── Layer 3: champagne-gold light trails near the bottom ──
  void _paintGoldCurves(Canvas canvas, Size size) {
    for (var k = 0; k < 3; k++) {
      // Each trail slides horizontally across the bottom, staggered.
      final phase = (t + k / 3) % 1.0;
      final slide = -size.width * 0.35 + phase * size.width * 1.7;
      final baseY = size.height * (0.88 + k * 0.035);
      final curve = Path();
      const segments = 48;
      var first = true;
      for (var i = 0; i <= segments; i++) {
        final p = i / segments;
        final x = slide + p * size.width * 0.55;
        final y = baseY -
            sin(p * pi) * size.height * 0.035 * (1 - k * 0.2) -
            k * size.height * 0.008;
        if (first) {
          curve.moveTo(x, y);
          first = false;
        } else {
          curve.lineTo(x, y);
        }
      }

      final alpha = (sin(phase * pi) * 0.8).clamp(0.0, 1.0) * 0.75;
      canvas.drawPath(
        curve,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.height * (0.004 + 0.002 * sin(phase * pi))
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _goldSoft.withValues(alpha: 0),
              _gold.withValues(alpha: alpha),
              _goldSoft.withValues(alpha: alpha * 0.9),
              _gold.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ).createShader(Offset.zero & size)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Sparkling tip on each trail.
      final tipX = slide + size.width * 0.55;
      final tipY = baseY - size.height * 0.012;
      canvas.drawCircle(
        Offset(tipX, tipY),
        2.4 + 1.6 * sin(phase * pi),
        Paint()
          ..color = _goldSoft.withValues(alpha: alpha * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  // ── Layer 4: bokeh lights ──
  void _paintBokeh(Canvas canvas, Size size) {
    final random = Random(7);
    for (var i = 0; i < particleCount; i++) {
      final sx = random.nextDouble();
      final sy = random.nextDouble();
      // Keep the central logo area (roughly the middle 45%) free of orbs.
      if ((sx - 0.5).abs() < 0.28 && (sy - 0.45).abs() < 0.30) continue;

      final speed = 0.4 + random.nextDouble() * 0.6;
      final radius = 3.0 + random.nextDouble() * 9.0;
      final breathe = sin((t * 2 * pi * speed) + i * 1.7);
      final drift = sin(t * 2 * pi + i * 2.3) * size.width * 0.02;
      final opacity = (0.10 + 0.16 * (breathe.abs())).clamp(0.0, 0.4);

      final pos = Offset(
        sx * size.width + drift,
        ((sy + t * speed * 0.12) % 1.15 - 0.05) * size.height,
      );

      _drawGlow(canvas, pos, radius * 3.2, Colors.white.withValues(alpha: opacity * 0.55));
      canvas.drawCircle(pos, radius * 0.55, Paint()..color = Colors.white.withValues(alpha: opacity + 0.15));
    }
  }

  // ── Layer 5: floating rose petals ──
  void _paintPetals(Canvas canvas, Size size) {
    for (var i = 0; i < petalCount; i++) {
      final seed = Random(i * 13 + 5);
      final sx = seed.nextDouble();
      final fallSpeed = 0.35 + seed.nextDouble() * 0.5;
      final swayPhase = seed.nextDouble() * 2 * pi;
      final spinPhase = seed.nextDouble() * 2 * pi;
      final petalSize = 7.0 + seed.nextDouble() * 8.0;
      final tint = seed.nextBool();

      // Petals rise/drift slowly upward with a swaying sideways motion and
      // fade in/out at the ends of their journey — seamless loop.
      final life = ((t * fallSpeed) + i / petalCount) % 1.0;
      final y = (1.05 - life * 1.15) * size.height;
      final x = sx * size.width + sin(life * 2.2 * pi + swayPhase) * size.width * 0.05;
      final fade = sin(life * pi).clamp(0.0, 1.0);
      final opacity = 0.20 + 0.45 * fade;
      final color = tint ? _silkDeep : _silkPink;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(spinPhase + life * 2 * pi * 0.8);
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      // Petal shape: two mirrored quadratic arcs.
      final path = Path()
        ..moveTo(0, -petalSize)
        ..quadraticBezierTo(petalSize * 0.85, 0, 0, petalSize)
        ..quadraticBezierTo(-petalSize * 0.85, 0, 0, -petalSize)
        ..close();
      canvas.drawPath(path, paint);
      // Inner gloss.
      canvas.drawPath(
        path,
        Paint()
          ..color = _ribbonLight.withValues(alpha: opacity * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DreamyPainter oldDelegate) =>
      oldDelegate.t != t;
}
