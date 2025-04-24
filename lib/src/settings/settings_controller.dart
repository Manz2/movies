import 'package:flutter/material.dart';
import 'package:json_store/json_store.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/db_service_firebase.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  final String? uid;
  SettingsController(this._settingsService, {required this.uid});

  final SettingsService _settingsService;
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  Logger logger = Logger();

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> syncMovies() async {
    DbServiceFirebase dbServiceFirebase = DbServiceFirebase(uid!);
    TmdbService tmdbService = TmdbService();
    List<Movie> movies = await dbServiceFirebase.getMovies();
    for (Movie movie in movies) {
      try {
        Movie movie2 = await tmdbService.getMovieWithCredits(movie);
        await dbServiceFirebase.setMovie(movie2);
      } on Exception catch (e) {
        logger.e('Fehler beim Synchronisieren der Filme: $e');
      }
    }
  }

  Future<void> clearDataBase() async {
    final jsonStore = JsonStore(dbName: 'movies');
    jsonStore.clearDataBase();
  }

  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', fontSize);
  }

  Future<List<Movie>> removeDublicates() async {
    DbServiceFirebase dbServiceFirebase = DbServiceFirebase(uid!);
    return await dbServiceFirebase.removeDuplicates();
  }
}
