import 'package:flutter/foundation.dart';

import '../../data/api_client.dart';
import '../../models/notification_model.dart';

/// Central cache for the signed-in customer's notifications.
///
/// Feeds both the bell-badge on Home and the Notifications screen so the
/// unread count always agrees with the list the user sees.
class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final NotificationStore instance = NotificationStore._();

  final ApiClient _api = ApiClient.instance;

  List<NotificationModel> items = const [];
  bool isLoading = false;
  String? error;
  String? _token;
  Future<void>? _pendingLoad;

  int get unreadCount => items.where((n) => !n.isRead).length;

  /// Loads notifications for [token]. Safe to call repeatedly — concurrent
  /// callers share one request, and an unchanged token short-circuits.
  Future<void> load(String? token) {
    if (token == null) {
      // Signed out — clear.
      if (_token != null) {
        _token = null;
        items = const [];
        notifyListeners();
      }
      return Future.value();
    }
    if (_token == token && _pendingLoad != null) return _pendingLoad!;
    if (_token == token && items.isNotEmpty) return Future.value();

    _token = token;
    isLoading = true;
    error = null;
    notifyListeners();
    _pendingLoad = _fetch();
    return _pendingLoad!;
  }

  Future<void> refresh() => _token == null ? Future.value() : load(_token);

  Future<void> _fetch() async {
    try {
      items = await _api.fetchNotifications(_token!);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      _pendingLoad = null;
      notifyListeners();
    }
  }

  /// Marks one notification read on the backend and updates the cache.
  Future<void> markRead(String id) async {
    if (_token == null) return;
    final index = items.indexWhere((n) => n.id == id);
    if (index != -1 && !items[index].isRead) {
      items = [
        for (var i = 0; i < items.length; i++)
          if (i == index)
            NotificationModel(
              id: items[i].id,
              title: items[i].title,
              body: items[i].body,
              type: items[i].type,
              relatedBookingId: items[i].relatedBookingId,
              isRead: true,
              createdAt: items[i].createdAt,
            )
          else
            items[i],
      ];
      notifyListeners();
    }
    try {
      await _api.markNotificationRead(_token!, id);
    } catch (_) {
      // Best-effort: the optimistic UI update stands; the next refresh resyncs.
    }
  }

  /// Marks every notification read.
  Future<void> markAllRead() async {
    if (_token == null) return;
    final unread = items.where((n) => !n.isRead).map((n) => n.id).toList();
    for (final id in unread) {
      try {
        await _api.markNotificationRead(_token!, id);
      } catch (_) {}
    }
    items = [
      for (final n in items)
        NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          relatedBookingId: n.relatedBookingId,
          isRead: true,
          createdAt: n.createdAt,
        ),
    ];
    notifyListeners();
  }

  /// Removes a notification on the backend and drops it from the cache.
  Future<void> dismiss(String id) async {
    if (_token == null) return;
    items = items.where((n) => n.id != id).toList();
    notifyListeners();
    try {
      await _api.dismissNotification(_token!, id);
    } catch (_) {
      // Next refresh will restore it if the delete failed.
    }
  }
}
