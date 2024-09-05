import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:json_store/json_store.dart';
import 'package:movies/src/db_service_firebase.dart';
import 'package:movies/src/db_service_local.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> syncMovies() async {
    DbServiceFirebase dbServiceFirebase = DbServiceFirebase();
    TmdbService tmdbService = TmdbService();
    List<Movie> movies = await dbServiceFirebase.getMovies();
    for (Movie movie in movies) {
      try {
        Movie movie2 = await tmdbService.getMovieWithCredits(movie);
        await dbServiceFirebase.setMovie(movie2);
      } on Exception catch (e) {
        print('Fehler beim Laden des Films: $e');
      }
    }
  }

  Future<void> clearDataBase() async {
    final jsonStore = JsonStore(dbName: 'movies');
    jsonStore.clearDataBase();
  }

  //TODO Passive and active sync
  //TODO Sync only when on wifi

  //TDO datensparmodus
  //TODO Schriftgröße

  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', fontSize);
  }
}
