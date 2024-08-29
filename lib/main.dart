import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));

  /* TOdo
  anbieter netflix etc bei movieView hinzufügen
  nicht testmovie anzeigen sionder route back un ups da ist wohl etwas schiegelaufen
  suche filter hinzufügen actor movie oder tv show 
  adult false bei der suche hinzufügen
  bei seri3en keine duratuion und year sonder von bis und anzahl folgen bzw. staffeln
  + zu suche ändern, dann filter bei der suche damit man nur die eigenen Filme durchsuchen kann
  eigenes rating
  Firebasse als db
  netzwerk auslastung messen ggf. image siz ereduzieren
  suchergebnisse sind nicht auf deutsch
  */
}
