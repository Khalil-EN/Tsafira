
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api_response.dart';
import '../http_client.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZATION
  // ============================================================

  static Future<void> init() async {
    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const ios = DarwinInitializationSettings();

    await _local.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
      ),
    );

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    final token = await messaging.getToken();

    if (token != null) {
      await saveFcmToken(token);
    }

    messaging.onTokenRefresh.listen(saveFcmToken);

    FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
  }

  // ============================================================
  // FCM TOKEN
  // ============================================================

  static Future<void> saveFcmToken(
      String token,
      ) async {
    try {
      await HttpClient.request(
        method: HttpMethod.post,
        endpoint: 'notifications/fcm-token',
        body: {
          'token': token,
        },
      );
    } catch (_) {
      // Token failure should not break the application.
    }
  }

  // ============================================================
  // FOREGROUND NOTIFICATION
  // ============================================================

  static Future<void> _handleForegroundMessage(
      RemoteMessage message,
      ) async {
    final notification = message.notification;

    if (notification == null) {
      return;
    }

    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'General',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ============================================================
  // GET NOTIFICATIONS
  // ============================================================

  static Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await HttpClient.request(
      method: HttpMethod.get,
      endpoint: 'notifications',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    return ApiResponse.decodeMap(response.body);
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  static Future<void> markRead(
      String notificationId,
      ) async {
    await HttpClient.request(
      method: HttpMethod.patch,
      endpoint: 'notifications/$notificationId/read',
    );
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  static Future<void> markAllRead() async {
    await HttpClient.request(
      method: HttpMethod.patch,
      endpoint: 'notifications/read-all',
    );
  }
}