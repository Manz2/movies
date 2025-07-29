import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final Logger logger = Logger();

  static Future<void> initialize() async {
    await _initFCM();
    await _initLocalNotifications();
  }

  static Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.d('Permission granted for push notifications');
    } else {
      logger.d('Permission denied for push notifications');
      return;
    }

    String? token = await messaging.getToken();
    logger.d('📱 FCM-Token: $token');
    await Clipboard.setData(ClipboardData(text: token!));
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotificationsPlugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Standard',
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android:
                android != null
                    ? AndroidNotificationDetails(
                      'default_channel',
                      'Standard',
                      icon: android.smallIcon ?? '@mipmap/ic_launcher',
                      importance: Importance.max,
                      priority: Priority.high,
                    )
                    : null,
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
    });
  }
}
