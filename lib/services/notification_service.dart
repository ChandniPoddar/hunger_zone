import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint("Handling background message: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'hunger_zone_channel',
    'Order Notifications',
    description: 'Notifications for order status changes and updates',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> init() async {
    // 1. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped: ${response.payload}");
      },
    );

    // Create high importance Android notification channel
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 2. Initialize Firebase Messaging if Firebase is initialized
    try {
      if (Firebase.apps.isNotEmpty) {
        await _setupFCM();
      }
    } catch (e) {
      debugPrint("[NotificationService] Firebase Messaging init error: $e");
    }
  }

  static Future<void> _setupFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request notification permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('User notification permission: ${settings.authorizationStatus}');

      // Set foreground notification presentation options
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        RemoteNotification? notification = message.notification;

        if (notification != null) {
          showNotification(
            id: notification.hashCode,
            title: notification.title ?? "Hunger Zone",
            body: notification.body ?? "",
            payload: message.data.toString(),
          );
        } else if (message.data.isNotEmpty) {
          // Data-only message
          final title = message.data['title'] ?? 'Hunger Zone Update';
          final body = message.data['body'] ?? message.data['status'] ?? 'You have a new update';
          showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: title,
            body: body,
            payload: message.data.toString(),
          );
        }
      });

      // Notification opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published: ${message.data}');
      });

    } catch (e) {
      debugPrint("[NotificationService] Setup FCM error: $e");
    }
  }

  /// Get device FCM token
  static Future<String?> getFCMToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("[NotificationService] Could not get FCM token: $e");
      return null;
    }
  }

  /// Show local heads-up notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
