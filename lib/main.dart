import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/notifications/fcm_service.dart';
import 'package:flutter/services.dart';
import 'core/auth/auth_session.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/app_motion.dart';
import 'core/ui/app_viewport.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FcmService.instance.initialize();
  } catch (_) {}
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
  runApp(const EleganceGownsApp());
}

class EleganceGownsApp extends StatefulWidget {
  const EleganceGownsApp({super.key});

  @override
  State<EleganceGownsApp> createState() => _EleganceGownsAppState();
}

class _EleganceGownsAppState extends State<EleganceGownsApp> {
  final AuthSession _session = AuthSession();

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      session: _session,
      child: MaterialApp(
        title: 'Elegance Gowns',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Keeps every screen at a comfortable phone width on tablets and in
        // the browser, instead of stretching layouts edge to edge.
        builder: (context, child) =>
            AppViewport(child: child ?? const SizedBox.shrink()),
        home: const AppNavigator(),
      ),
    );
  }
}

enum AppScreen { splash, onboarding, main }

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  AppScreen _currentScreen = AppScreen.splash;

  void _navigateTo(AppScreen screen) {
    setState(() => _currentScreen = screen);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.reduced(context) ? Duration.zero : AppMotion.route,
      switchInCurve: AppMotion.emphasized,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.99, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case AppScreen.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: () => _navigateTo(AppScreen.main),
        );
      case AppScreen.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onComplete: () => _navigateTo(AppScreen.main),
        );
      case AppScreen.main:
        return const MainShell(
          key: ValueKey('main'),
        );
    }
  }
}
