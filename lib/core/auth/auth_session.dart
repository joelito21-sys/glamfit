import 'package:flutter/material.dart';
import '../notifications/fcm_service.dart';
import '../../data/api_client.dart';

class AuthSession extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _displayName = 'Guest';
  String _email = '';
  String? _accessToken;

  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _displayName;
  String get email => _email;
  String? get accessToken => _accessToken;
  String get initial =>
      _isLoggedIn && _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'G';

  int get bookingCount => 0;
  int get wishlistCount => 0;
  double get totalSpent => 0.0;

  void authenticate({
    required String name,
    required String email,
    required String accessToken,
  }) {
    _isLoggedIn = true;
    _displayName = name;
    _email = email;
    _accessToken = accessToken;
    notifyListeners();
    if (accessToken.isNotEmpty) {
      FcmService.instance.registerToken(accessToken);
    }
  }

  Future<void> logout() async {
    final token = _accessToken;
    if (token != null) {
      try {
        await FcmService.instance.removeToken(token);
      } catch (_) {}
    }
    _isLoggedIn = false;
    _displayName = 'Guest';
    _email = '';
    _accessToken = null;
    notifyListeners();

    if (token != null) {
      try {
        await ApiClient.instance.logout(token);
      } catch (_) {
        // The local session is cleared even if the server is unreachable.
      }
    }
  }
}

class AuthScope extends InheritedNotifier<AuthSession> {
  const AuthScope({
    super.key,
    required AuthSession session,
    required super.child,
  }) : super(notifier: session);

  static AuthSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found');
    return scope!.notifier!;
  }

  static AuthSession read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found');
    return scope!.notifier!;
  }
}