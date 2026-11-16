import '../data/api_client.dart';
import '../models/sms_notification_model.dart';

class SmsNotificationApiService {
  SmsNotificationApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<List<SmsNotificationModel>> fetchHistory(String token, {Map<String, String>? query}) async {
    final body = await _client.getJson('notifications/sms/history', token: token, query: query);
    final rows = _extractList(body);
    return rows.whereType<Map<String, dynamic>>().map(SmsNotificationModel.fromJson).toList();
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is! Map<String, dynamic>) return const [];
    final data = body['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) return inner; // paginator {data:[...],...}
      if (inner is Map<String, dynamic> && inner['data'] is List) return inner['data'] as List;
    }
    return const [];
  }

  Future<SmsPreferencesModel> getPreferences(String token) async {
    final body = await _client.getJson('notifications/preferences', token: token);
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is Map<String, dynamic>) return SmsPreferencesModel.fromJson(data);
    return SmsPreferencesModel.defaults();
  }

  Future<SmsPreferencesModel> updatePreferences(String token, SmsPreferencesModel prefs) async {
    final body = await _client.putJsonPath('notifications/preferences', prefs.toJson(), token: token);
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is Map<String, dynamic>) return SmsPreferencesModel.fromJson(data);
    return prefs;
  }
}
