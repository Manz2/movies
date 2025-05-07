import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

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

  runApp(MyApp(settingsController: settingsController));
}
