import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'my_app',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  runApp(MyApp(settingsController: settingsController));
}
