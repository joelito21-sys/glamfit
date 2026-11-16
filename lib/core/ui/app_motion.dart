import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared motion vocabulary for the app.
///
/// Every duration and curve a screen needs lives here so the app moves at
/// one tempo instead of each screen inventing its own. Animations are
/// skipped automatically when the platform asks for reduced motion
/// (`MediaQuery.disableAnimations`), so accessibility settings are honoured.
class AppMotion {
  const AppMotion._();

  /// Tap feedback: press-down scale, ripple fades.
  static const Duration fast = Duration(milliseconds: 160);

  /// Colour/position changes on small elements.
  static const Duration medium = Duration(milliseconds: 280);

  /// Content entrance and larger reveals.
  static const Duration slow = Duration(milliseconds: 460);

  /// Pushed routes.
  static const Duration route = Duration(milliseconds: 420);

  /// Gap added between staggered siblings.
  static const Duration stagger = Duration(milliseconds: 60);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve press = Curves.easeOut;

  /// True when the OS asks us to avoid motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Delay for the [index]-th item of a staggered group.
  static Duration delayFor(int index, {int stepMs = 60}) =>
      Duration(milliseconds: (index.clamp(0, 12)) * stepMs);
}

/// Reveals [child] once, when it first mounts.
///
/// Use [index] to stagger siblings: each step waits a little longer than the
/// previous one, which is what makes a list of cards feel composed instead of
/// all popping in at once.
class Reveal extends StatefulWidget {
  final Widget child;

  /// Position in a staggered group.
  final int index;

  /// Extra wait before this item starts.
  final Duration delay;

  /// Direction/distance the child travels in from.
  final Offset offset;

  /// Starting scale; 1.0 means no scaling.
  final double scaleFrom;

  final Duration duration;
  final Curve curve;

  /// Set false to render statically (e.g. items already on screen).
  final bool enabled;

  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 18),
    this.scaleFrom = 1.0,
    this.duration = AppMotion.slow,
    this.curve = AppMotion.enter,
    this.enabled = true,
  });

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (!widget.enabled) {
      _controller.value = 1;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppMotion.reduced(context)) {
        _controller.value = 1;
        return;
      }
      Future<void>.delayed(
        widget.delay + AppMotion.delayFor(widget.index),
        () {
          if (mounted) _controller.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool animates =
        widget.offset != Offset.zero || widget.scaleFrom != 1.0;
    if (!widget.enabled || !animates && widget.delay == Duration.zero) {
      // Still fade, but avoid the extra transform layers when there is no
      // movement to perform.
      return AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (context, child) =>
            Opacity(opacity: _progress.value.clamp(0.0, 1.0), child: child),
      );
    }

    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final double t = _progress.value.clamp(0.0, 1.0);
        Widget result = child!;
        if (widget.scaleFrom != 1.0) {
          result = Transform.scale(
            scale: widget.scaleFrom + (1 - widget.scaleFrom) * t,
            child: result,
          );
        }
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(
              widget.offset.dx * (1 - t),
              widget.offset.dy * (1 - t),
            ),
            child: result,
          ),
        );
      },
    );
  }
}

/// Wraps any tappable so it reacts to being pressed.
///
/// Replaces bare `GestureDetector`s: the child scales down slightly under the
/// finger, gives a light haptic tick on mobile, and shows a pointer cursor on
/// the web. Screen readers still get a proper button node.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// How far the child shrinks while held.
  final double pressedScale;

  /// Opacity applied while held; 1.0 keeps the child fully opaque.
  final double pressedOpacity;

  final bool haptic;
  final HitTestBehavior behavior;
  final String? semanticLabel;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.955,
    this.pressedOpacity = 1.0,
    this.haptic = true,
    this.behavior = HitTestBehavior.opaque,
    this.semanticLabel,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setDown(bool value) {
    if (!_enabled || _down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;

    final Duration duration =
        AppMotion.reduced(context) ? Duration.zero : AppMotion.fast;

    Widget content = AnimatedScale(
      scale: _down ? widget.pressedScale : 1.0,
      duration: duration,
      curve: AppMotion.press,
      child: AnimatedOpacity(
        opacity: _down ? widget.pressedOpacity : 1.0,
        duration: duration,
        child: widget.child,
      ),
    );

    content = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: (_) {
          _setDown(true);
          if (widget.haptic) HapticFeedback.selectionClick();
        },
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: content,
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: content,
    );
  }
}

/// Fade + rise + settle transition used for every pushed route.
///
/// The first route is left untouched so app launch is not delayed by a
/// transition, and reduced-motion users get an instant swap.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.isFirst || AppMotion.reduced(context)) return child;

    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.exit,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

/// Fade-through transition for swapping content that is not a route
/// (tab bodies, filter results, empty/loaded states).
class FadeThroughSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeThroughSwitcher({
    super.key,
    required this.child,
    this.duration = AppMotion.medium,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.reduced(context) ? Duration.zero : duration,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
