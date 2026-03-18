import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/push_notification_service.dart';

BuildContext? globalAppContext;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  final uid = FirebaseAuth.instance.currentUser?.uid;
  final settingsController = SettingsController(SettingsService(), uid: uid);
  await settingsController.loadSettings();

  runApp(MyApp(settingsController: settingsController));
  unawaited(_initializeNotificationsSafely());
}

Future<void> _initializeNotificationsSafely() async {
  try {
    await PushNotificationService.storeInitialMessage().timeout(
      const Duration(seconds: 10),
    );
    await PushNotificationService.initialize().timeout(
      const Duration(seconds: 20),
    );
  } catch (_) {
  }
}
