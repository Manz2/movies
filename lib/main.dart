import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        name: 'my_app',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      final settingsController = SettingsController(SettingsService());
      await settingsController.loadSettings(); // ⬅️ fehlte!

      FirebaseCrashlytics.instance.log("✅ Settings geladen");

      runApp(MyApp(settingsController: settingsController));
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);

      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                "❌ Fehler beim Start: $error",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      );
    },
  );
}
