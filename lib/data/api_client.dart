import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/booking_model.dart';
import '../models/gown_model.dart';
import '../models/notification_model.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static final ApiClient instance = ApiClient();

  final http.Client _client;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    return 'http://127.0.0.1:8000/api/v1';
  }

  Uri _endpoint(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(baseUrl);
    return base.replace(
      path: '${base.path.replaceFirst(RegExp(r'/+$'), '')}/$path',
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _postJson('auth/login', {'email': email, 'password': password});

  Future<Map<String, dynamic>> verifyLoginCode({
    required String challengeId,
    required String code,
  }) => _postJson('auth/verify-login', {'challenge_id': challengeId, 'code': code});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) => _postJson('auth/register', {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
  });

  Future<void> logout(String token) async {
    await _postJson('auth/logout', const {}, token: token);
  }

  Future<List<BookingModel>> fetchOrders(String token) async {
    final response = await _client
        .get(_endpoint('me/orders'), headers: _authorizedHeaders(token))
        .timeout(const Duration(seconds: 15));
    final body = _decodeResponse(response);
    final rows = body is Map<String, dynamic> ? body['data'] : body;
    if (rows is! List) {
      throw const FormatException(
        'The orders response did not contain a data list.',
      );
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => BookingModel.fromApiJson(row, resolveImageUrl))
        .toList(growable: false);
  }

  Future<BookingModel> createRental({
    required String token,
    required String gownId,
    required DateTime rentalStart,
    required DateTime rentalEnd,
    required String size,
    required String color,
  }) async {
    final body = await _postJson('rentals', {
      'gown_id': gownId,
      'rental_start': _dateOnly(rentalStart),
      'rental_end': _dateOnly(rentalEnd),
      'size': size,
      'color': color,
    }, token: token);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'The rental response did not contain the created reservation.',
      );
    }
    return BookingModel.fromApiJson(data, resolveImageUrl);
  }

  Future<List<NotificationModel>> fetchNotifications(String token) async {
    final response = await _client
        .get(_endpoint('notifications'), headers: _authorizedHeaders(token))
        .timeout(const Duration(seconds: 15));
    final body = _decodeResponse(response);
    final rows = body is Map<String, dynamic> ? body['data'] : body;
    if (rows is! List) {
      throw const FormatException(
        'The notifications response did not contain a data list.',
      );
    }
    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => NotificationModel.fromApiJson(row))
        .toList(growable: false);
  }

  Future<void> markNotificationRead(String token, String id) async {
    await _postJson('notifications/$id/read', const {}, token: token);
  }

  Future<void> registerDeviceToken({
    required String token,
    required String deviceToken,
    required String deviceType,
  }) async {
    await _postJson('device-tokens', {
      'device_token': deviceToken,
      'device_type': deviceType,
    }, token: token);
  }

  Future<void> unregisterDeviceToken({
    required String token,
    required String deviceToken,
  }) async {
    final response = await _client
        .delete(
          _endpoint('device-tokens'),
          headers: {
            ..._authorizedHeaders(token),
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'device_token': deviceToken}),
        )
        .timeout(const Duration(seconds: 15));
    _decodeResponse(response);
  }

  Future<Map<String, dynamic>> fetchDeliveryServiceTypes(String token) async {
    final response = await _client
        .get(
          _endpoint('deliveries/service-types'),
          headers: _authorizedHeaders(token),
        )
        .timeout(const Duration(seconds: 20));
    final body = _decodeResponse(response);
    if (body is! Map<String, dynamic>) {
      throw const FormatException('The delivery services response was invalid.');
    }
    return body;
  }

  Future<Map<String, dynamic>> createDeliveryQuote({
    required String token,
    required String gownId,
    required String dropoffAddress,
    required double latitude,
    required double longitude,
    required String serviceType,
  }) async => _postJson('deliveries/quote', {
    'gown_id': gownId,
    'dropoff_address': dropoffAddress,
    'dropoff_latitude': latitude,
    'dropoff_longitude': longitude,
    'service_type': serviceType,
  }, token: token);

  Future<Map<String, dynamic>> bookDelivery({
    required String token,
    required String reservationId,
    required String quotationId,
  }) async => _postJson('deliveries/book', {
    'reservation_id': reservationId,
    'quotation_id': quotationId,
  }, token: token);

  Future<Map<String, dynamic>> fetchDeliveryTracking({
    required String token,
    required String deliveryId,
  }) async {
    final response = await _client
        .get(
          _endpoint('deliveries/$deliveryId/tracking'),
          headers: _authorizedHeaders(token),
        )
        .timeout(const Duration(seconds: 20));
    final body = _decodeResponse(response);
    if (body is! Map<String, dynamic>) {
      throw const FormatException('The delivery tracking response was invalid.');
    }
    return body;
  }

  Future<void> dismissNotification(String token, String id) async {
    final response = await _client
        .delete(
          _endpoint('notifications/$id'),
          headers: _authorizedHeaders(token),
        )
        .timeout(const Duration(seconds: 15));
    _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload, {
    String? token,
  }) async {
    final response = await _client
        .post(
          _endpoint(path),
          headers: {
            ..._headers,
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decodeResponse(response);
    if (body is! Map<String, dynamic>) {
      throw const FormatException(
        'The backend returned an unexpected response.',
      );
    }
    return body;
  }

  Map<String, String> _authorizedHeaders(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<List<GownModel>> fetchGowns({double? userLat, double? userLng}) async {
    final params = <String, String>{'per_page': '100'};
    if (userLat != null && userLng != null) {
      params['user_lat'] = userLat.toString();
      params['user_lng'] = userLng.toString();
    }
    final response = await _client
        .get(_endpoint('gowns', params), headers: _headers)
        .timeout(const Duration(seconds: 15));
    final body = _decodeResponse(response);
    final rows = body is Map<String, dynamic> ? body['data'] : body;
    if (rows is! List) {
      throw const FormatException(
        'The gowns response did not contain a data list.',
      );
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) => GownModel.fromApiJson(row, resolveImageUrl))
        .toList(growable: false);
  }

  Future<List<GownCategory>> fetchCategories() async {
    final response = await _client
        .get(_endpoint('categories'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    final body = _decodeResponse(response);
    final rows = body is Map<String, dynamic> ? body['data'] : body;
    if (rows is! List) {
      throw const FormatException(
        'The categories response did not contain a data list.',
      );
    }

    return [
      for (var index = 0; index < rows.length; index++)
        GownCategory.fromApiJson(rows[index], index),
    ];
  }

  String resolveImageUrl(String image) {
    final value = image.trim();
    if (value.isEmpty) return '';

    final base = Uri.parse(baseUrl);
    final origin = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    );

    final parsed = Uri.tryParse(value);
    if (parsed != null && parsed.hasScheme) {
      // If the backend baked a local host into an absolute URL (common in dev),
      // rebase it onto the app's configured API origin so devices can reach it.
      const localHosts = {'localhost', '127.0.0.1', '::1', '0.0.0.0'};
      if (localHosts.contains(parsed.host)) {
        final rebased = parsed.replace(
          scheme: origin.scheme,
          host: origin.host,
          port: origin.hasPort ? origin.port : null,
        );
        return rebased.toString();
      }
      return value;
    }

    // Serve relative paths through the API image endpoint (matches
    // GownApiController::imageUrl / GownImageController), not /storage.
    final normalized = value.startsWith('/') ? value.substring(1) : value;
    final path =
        (normalized.startsWith('storage/') || normalized.startsWith('api/'))
        ? '/$normalized'
        : '/api/v1/gown-images/$normalized';
    return origin.resolve(path).toString();
  }

  Map<String, String> get _headers => const {'Accept': 'application/json'};

  dynamic _decodeResponse(http.Response response) {
    final dynamic decoded;
    final body = response.body.replaceAll('\uFEFF', '').trim();
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const FormatException(
        'The backend returned an invalid JSON response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(
        message ?? 'Backend request failed (${response.statusCode}).',
      );
    }

    return decoded;
  }

  Future<dynamic> getJson(String path, {required String token, Map<String, String>? query}) async {
    final response = await _client
        .get(_endpoint(path, query), headers: _authorizedHeaders(token))
        .timeout(const Duration(seconds: 20));
    return _decodeResponse(response);
  }

  Future<dynamic> postJsonPath(String path, Map<String, dynamic> payload, {required String token}) async {
    final response = await _client
        .post(
          _endpoint(path),
          headers: {
            ..._headers,
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeResponse(response);
  }

  Future<dynamic> putJsonPath(String path, Map<String, dynamic> payload, {required String token}) async {
    final response = await _client
        .put(
          _endpoint(path),
          headers: {
            ..._headers,
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeResponse(response);
  }
}
