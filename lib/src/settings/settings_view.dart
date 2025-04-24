import 'package:flutter/material.dart';
import 'package:movies/src/home/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
class SettingsView extends StatefulWidget {
  final SettingsController controller;

  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  double _fontSize = 16.0; // Standardwert

  @override
  void initState() {
    super.initState();
    _loadFontSize(); // Schriftgröße beim Start laden
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('font_size') ?? 16.0; // Standardwert
    });
  }

  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Theme:", style: TextStyle(fontSize: _fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: DropdownButton<ThemeMode>(
                value: widget.controller.themeMode,
                onChanged: widget.controller.updateThemeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark Theme'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Schriftgröße:",
                style: TextStyle(fontSize: _fontSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Slider(
                min: 15,
                max: 25,
                value: _fontSize,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                  _saveFontSize(value); // Schriftgröße speichern
                  widget.controller.saveFontSize(
                    value,
                  ); // Schriftgröße in den Controller speichern (optional)
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Sync:", style: TextStyle(fontSize: _fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      String passwordInput = '';
                      String correctPassword = '1234'; // Festgelegtes Passwort

                      return AlertDialog(
                        title: Text(
                          'Filme Synchronisieren',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Sind Sie sicher, dass Sie alle Filme mit der TMDB synchronisieren möchten? Ein hoher Datenverbrauch kann entstehen.",
                              style: TextStyle(fontSize: _fontSize),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              obscureText: true, // Passworteingabe verbergen
                              decoration: const InputDecoration(
                                labelText: 'Passwort eingeben',
                              ),
                              onChanged: (value) {
                                passwordInput = value;
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              'Abbrechen',
                              style: TextStyle(fontSize: _fontSize),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Dialog schließen
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Sync',
                              style: TextStyle(fontSize: _fontSize),
                            ),
                            onPressed: () {
                              if (passwordInput == correctPassword) {
                                Navigator.pop(context); // Dialog schließen
                                widget.controller
                                    .syncMovies(); // Filme synchronisieren
                              } else {
                                // Zeige eine Warnung an, dass das Passwort falsch ist
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Falsches Passwort'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'Sync Movies',
                  style: TextStyle(fontSize: _fontSize),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text("DB:", style: TextStyle(fontSize: _fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.clearDataBase();
                },
                child: Text(
                  'Lokale DB Löschen',
                  style: TextStyle(fontSize: _fontSize),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  List<Movie> deleted =
                      await widget.controller.removeDublicates();
                  String names = deleted.map((e) => e.title).join(', ');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Folgende Filme wurden gelöscht: $names"),
                    ),
                  );
                },
                child: Text(
                  'Duplikate löschen',
                  style: TextStyle(fontSize: _fontSize),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text("Account:", style: TextStyle(fontSize: _fontSize)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.logout(context);
                },
                child: Text('Abmelden', style: TextStyle(fontSize: _fontSize)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Credits:", style: TextStyle(fontSize: _fontSize)),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Image(image: AssetImage('assets/images/tmdb.png')),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "This product uses the TMDB API but is not endorsed or certified by TMDB.",
                style: TextStyle(fontSize: _fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
