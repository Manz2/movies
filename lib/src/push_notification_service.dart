import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:movies/main.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart' show MovieViewArguments;
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/search/search_controller.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final Logger logger = Logger();

  static RemoteMessage? _lastMessage;

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
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (_lastMessage != null) {
          await _handleMessage(_lastMessage);
        }
      },
    );

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
      _lastMessage = message;

      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Standard',
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  static Future<void> _handleMessage(RemoteMessage? message) async {
    if (message?.data == null) return;
    logger.i('handleMessage called with: ${message?.data}');

    final data = message!.data;
    final id = data['id'];
    final mediaType = data['mediaType'];

    if (id == null || mediaType == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final context = globalAppContext;
    if (context == null || !context.mounted) {
      logger.e("Context is null or not mounted");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final controller = SearchPageController(uid: uid);
      Movie movie = await controller.getMovie(id, mediaType);
      final providers = await controller.getProviders(movie);
      final trailers = await controller.getTrailers(movie);
      final recommendations = await controller.getRecommendations(movie);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!context.mounted) return;
      Navigator.of(context).pushNamed(
        MovieView.routeName,
        arguments: MovieViewArguments(
          movie: movie,
          providers: providers,
          trailers: trailers,
          recommendations: recommendations,
        ),
      );
    } catch (e) {
      // Close dialog on error
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      logger.e("Error while loading movie: $e");
    }
  }
}
