import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/api_client.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class FcmService {
  static final FcmService instance = FcmService._();
  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? _authToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    try {
      if (kIsWeb) return;
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get token
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');
      }

      // Handle token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (_authToken != null) {
          _registerToken(_authToken!);
        }
      });

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = 
          InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(initSettings);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      // Background/terminated message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle notification tap
      });
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  Future<void> registerToken(String authToken) async {
    _authToken = authToken;
    if (_fcmToken != null) {
      await _registerToken(authToken);
    }
  }

  Future<void> _registerToken(String authToken) async {
    try {
      await ApiClient.instance.registerDeviceToken(
        token: authToken,
        deviceToken: _fcmToken!,
        deviceType: Platform.isAndroid ? 'Android' : 'iOS',
      );
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  Future<void> removeToken(String authToken) async {
    try {
      if (_fcmToken != null) {
        await ApiClient.instance.unregisterDeviceToken(
          token: authToken,
          deviceToken: _fcmToken!,
        );
      }
    } catch (e) {
      debugPrint('Failed to unregister device token: $e');
    }
  }
}
