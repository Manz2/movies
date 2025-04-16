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

      // Crashlytics initialisieren
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      FirebaseCrashlytics.instance.log("🚀 main() gestartet");

      final settingsController = SettingsController(SettingsService());
      await settingsController.loadSettings();

      FirebaseCrashlytics.instance.log("✅ Settings geladen – starte App");

      runApp(MyApp(settingsController: settingsController));
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      debugPrint("❌ Fehler in main(): $error");
    },
  );
}
