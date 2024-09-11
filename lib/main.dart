import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp(settingsController: settingsController));
}
