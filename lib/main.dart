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
  await PushNotificationService.initialize();

  runApp(
    MyApp(settingsController: settingsController),
  );
}
