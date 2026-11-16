import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Responsive frame for the whole app.
///
/// This app is designed as a phone experience. On a phone it fills the
/// screen; on a tablet or a desktop browser the surface stays at a
/// comfortable reading width and is centred, instead of stretching a phone
/// layout across 1600px.
///
/// It works by rewriting the [MediaQuery] the app sees, so every screen,
/// grid and SafeArea inside believes the window is [maxWidth] wide and
/// lays itself out accordingly.
class AppViewport extends StatelessWidget {
  final Widget child;

  /// Widest the app surface is allowed to become.
  static const double maxWidth = 520;

  /// Window width at which the app stops filling the screen edge to edge.
  static const double breakpoint = 600;

  /// True when the window is wider than a phone.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= breakpoint;

  const AppViewport({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);

    if (media.size.width < breakpoint) {
      return DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.champagneGradient),
        child: child,
      );
    }

    final double surfaceWidth = maxWidth;
    final double surfaceHeight = media.size.height;

    return ColoredBox(
      // Dark surround and a softly lit phone canvas keep the app intentional
      // at tablet and desktop widths too.
      color: const Color(0xFF050505),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepRose.withValues(alpha: 0.22),
                blurRadius: 48,
                offset: const Offset(0, 18),
              ),
            ],
          ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: AppColors.champagneGradient),
                child: SizedBox(
              width: surfaceWidth,
              height: surfaceHeight,
              child: MediaQuery(
                // Hand the app a phone-shaped window. Height stays real so
                // vertical layouts behave exactly as they do on a device.
                data: media.copyWith(
                  size: Size(surfaceWidth, surfaceHeight),
                  padding: media.padding.copyWith(
                    left: 0,
                    right: 0,
                  ),
                  viewPadding: media.viewPadding.copyWith(
                    left: 0,
                    right: 0,
                  ),
                ),
                child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
