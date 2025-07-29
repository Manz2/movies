import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
    } else {
      rethrow;
    }
  }
  final uid = FirebaseAuth.instance.currentUser?.uid;

  final settingsController = SettingsController(SettingsService(), uid: uid);

  await settingsController.loadSettings();

  await setupFCM();

  runApp(MyApp(settingsController: settingsController));
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Push-Berechtigung erteilt');
  } else {
    print('❌ Push-Berechtigung abgelehnt');
    return;
  }

  String? token = await messaging.getToken();
  print('📱 FCM-Token: $token');
  await Clipboard.setData(ClipboardData(text: token!));
}
