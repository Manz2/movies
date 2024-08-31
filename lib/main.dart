import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));

  /* TOdo
  Firebase als db nutzen
  logger anstatt print
  nicht testmovie anzeigen sonder route back un ups da ist wohl etwas schiegelaufen
  netzwerk auslastung messen ggf. image siz ereduzieren,   Alarm wenn wlan nicht aktiv
  Unbedingt eine warchlist für filme die noch nicht angesehen wurden aber gut aussehen die sind nicht auf home
  Evtl nutzer unterscheidung und bewertungen mitteln
  Projekte backup erstellen
  Vorschau bilder größer
  Schauspieler ohne filme beider Suche ausblenden 
  Sortieren nach dauer Oder Bewertung oder Alfabetisch
  Bei schauspielern sind serien immer ganz unten
  Wo schauen evtl mit link play button als floating action button oder direkt im movie view als icons
  Filtern nach genre (optional)
  Evtl. Bei popular noch serien und noch mehr verschiedene filme evtl. Auch mit den selben filtern
  Sichtbar machen ob aktuell filter aktiv sind
  Bilder der fsk zentrieren (ipad view emulator auf tablat ändern)
  Bei apple einrichen
  Icon hinzufügen
  Die todos nach dringlichkeit und reihenfolge sortieren
  */
}
