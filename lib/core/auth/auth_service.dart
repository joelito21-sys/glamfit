import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/api_client.dart';
import 'auth_session.dart';

class AuthService {
  AuthService({ApiClient? client, FlutterSecureStorage? storage})
      : _client = client ?? ApiClient.instance,
        _storage = storage ?? const FlutterSecureStorage();

  static final AuthService instance = AuthService();

  final ApiClient _client;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required AuthSession session,
  }) async {
    final body = await _client.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    final data = body['data'] as Map<String, dynamic>?;
    final token = data?['token']?.toString() ?? body['token']?.toString();
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
      session.authenticate(name: name, email: email, accessToken: token);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required AuthSession session,
  }) async {
    final body = await _client.login(email: email, password: password);
    final data = body['data'] as Map<String, dynamic>?;
    final token = data?['token']?.toString() ?? body['token']?.toString();
    final name = data?['name']?.toString() ?? email;
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
      session.authenticate(name: name, email: email, accessToken: token);
    }
  }

  Future<String?> restoreToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> logout(AuthSession session) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      try {
        await _client.logout(token);
      } catch (_) {}
    }
    await _storage.delete(key: _tokenKey);
    await session.logout();
  }
}
