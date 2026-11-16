import 'package:flutter/material.dart';
import '../../core/auth/auth_session.dart';
import '../../data/api_client.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'two_factor_screen.dart';
import 'register_screen.dart';

class AuthFlowScreen extends StatefulWidget {
  final String? prompt;
  const AuthFlowScreen({super.key, this.prompt});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  _AuthPage _page = _AuthPage.login;
  String? _challengeId;
  String? _emailHint;

  Future<void> _login(String email, String password) async {
    final response = await ApiClient.instance.login(email: email, password: password);
    if (response['two_factor_required'] == true) {
      final challengeId = response['challenge_id']?.toString();
      if (challengeId == null || challengeId.isEmpty) {
        throw const FormatException('The backend did not return a verification challenge.');
      }
      if (!mounted) return;
      setState(() {
        _challengeId = challengeId;
        _emailHint = response['email_hint']?.toString();
        _page = _AuthPage.twoFactor;
      });
      return;
    }
    _completeAuthentication(response);
  }

  Future<void> _verifyLoginCode(String code) async {
    final challengeId = _challengeId;
    if (challengeId == null) throw const FormatException('Sign in again to request a new verification code.');
    final response = await ApiClient.instance.verifyLoginCode(challengeId: challengeId, code: code);
    _completeAuthentication(response);
  }

  Future<void> _register(String name, String email, String phone, String password) async {
    final response = await ApiClient.instance.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    _completeAuthentication(response);
  }

  void _completeAuthentication(Map<String, dynamic> response) {
    final user = response['user'];
    final token = response['token'];
    if (user is! Map<String, dynamic> || token is! String || token.isEmpty) {
      throw const FormatException('The backend did not return an authenticated user.');
    }

    AuthScope.read(context).authenticate(
      name: (user['name'] ?? 'Customer').toString(),
      email: (user['email'] ?? '').toString(),
      accessToken: token,
    );
    Navigator.pop(context, true);
  }

  void _cancel() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    switch (_page) {
      case _AuthPage.login:
        return LoginScreen(
          prompt: widget.prompt,
          onLogin: _login,
          onRegister: () => setState(() => _page = _AuthPage.register),
          onForgotPassword: () => setState(() => _page = _AuthPage.forgot),
          onContinueShopping: _cancel,
        );
      case _AuthPage.register:
        return RegisterScreen(
          onRegister: _register,
          onBack: () => setState(() => _page = _AuthPage.login),
        );
      case _AuthPage.forgot:
        return ForgotPasswordScreen(
          onBack: () => setState(() => _page = _AuthPage.login),
        );
      case _AuthPage.twoFactor:
        return TwoFactorScreen(
          emailHint: _emailHint,
          onVerify: _verifyLoginCode,
          onBack: () => setState(() { _challengeId = null; _emailHint = null; _page = _AuthPage.login; }),
        );
    }
  }
}

enum _AuthPage { login, register, forgot, twoFactor }

class AuthGate {
  static Future<bool> requireLogin(
    BuildContext context, {
    String prompt = 'Sign in to continue your booking',
  }) async {
    if (AuthScope.of(context).isLoggedIn) return true;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AuthFlowScreen(prompt: prompt),
      ),
    );
    return result == true;
  }
}
