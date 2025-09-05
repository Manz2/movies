import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/shared_widgets/base_controller.dart';
import 'package:movies/src/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieController extends BaseController with ChangeNotifier {
  final MovieModel _model;
  final String uid;
  final DbCombinator _db;

  bool _notificationSet = false;
  bool get notificationSet => _notificationSet;

  MovieController({
    required this.uid,
    required Movie movie,
    required Providers providers,
    required List<String> trailers,
    required List<Movie> recommendations,
  }) : _model = MovieModel(
         movie: movie,
         providers: providers,
         trailers: trailers,
         recommendations: recommendations,
       ),
       _db = DbCombinator(uid: uid);
  final TmdbService tmdbService = TmdbService();
  MovieModel get model => _model;
  Logger logger = Logger();

  Future<List<Movie>> getMovies(int actorId, {bool isDirector = false}) async {
    try {
      // Lokale Movies laden
      List<Movie> localMovies = await _db.getMovies();

      // Set aus kombinierten "id|mediaType"-Strings erstellen
      Set<String> localMovieKeys = localMovies
          .map((m) => '${m.id}|${m.mediaType}')
          .toSet();

      List<Movie> combinedCredits = await tmdbService.getCombinedCredits(
        actorId,
        isDirector: isDirector,
      );

      // Alle Filme markieren, die in der lokalen Liste sind (id UND mediaType matchen)
      for (var movie in combinedCredits) {
        String key = '${movie.id}|${movie.mediaType}';
        movie.setOnList(localMovieKeys.contains(key));
      }

      // Neu sortieren: zuerst alle mit onList == true (Reihenfolge beibehalten), dann der Rest
      List<Movie> sorted = [
        ...combinedCredits.where((m) => m.onList),
        ...combinedCredits.where((m) => !m.onList),
      ];

      return sorted;
    } on Exception catch (e) {
      logger.e('Fehler beim Laden der Filme: $e');
      return [];
    }
  }

  Future<bool> isSaved() async {
    return _model.movie.firebaseId != '';
  }

  Future<void> addMovie() async {
    try {
      _model.movie = await _db.addMovie(_model.movie);
    } catch (e) {
      logger.e('Fehler beim Hinzufügen des Films: $e');
    }
  }

  Future<void> setRating(double rating) async {
    _model.movie.privateRating = rating;
    await _db.setMovie(_model.movie);
  }

  Future<void> getWatchlists() async {
    _model.watchlists = await _db.getWatchlists();

    final prefs = await SharedPreferences.getInstance();
    String currentId = prefs.getString('current_watchlist') ?? '';

    if (currentId.isNotEmpty) {
      Watchlist? current;

      try {
        current = _model.watchlists.firstWhere((w) => w.id == currentId);
      } catch (_) {
        current = null;
      }

      if (current != null) {
        _model.watchlists.removeWhere((w) => w.id == currentId);
        _model.watchlists.insert(0, current);
      }
    }
  }

  Future<void> addMovieToWatchlist(
    Watchlist watchlist,
    BuildContext context,
  ) async {
    if (watchlist.entries.any(
      (element) =>
          element.id == _model.movie.id &&
          element.type == _model.movie.mediaType,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${_model.movie.title} ist bereits in ${watchlist.name} enthalten",
          ),
        ),
      );
      return;
    }
    await _db.addMovieToWatchlist(watchlist, _model.movie);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${_model.movie.title} wurde zu ${watchlist.name} hinzugefügt",
        ),
      ),
    );
  }

  Future<void> addWatchlist(String name) async {
    _model.watchlists.add(await _db.addWatchlist(name));
  }

  String getDuration() {
    int durationInMinutes = _model.movie.duration;
    int hours = durationInMinutes ~/ 60; // Ganze Stunden
    int minutes = durationInMinutes % 60;
    return "$hours Std. $minutes Min."; // Verbleibende Minuten
  }

  @override
  Future<Providers> getProviders(Movie item) async {
    try {
      return await tmdbService.getProviders(item.id.toString(), item.mediaType);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Provider: $e');
      return Providers(providers: [], link: '');
    }
  }

  @override
  Future<List<String>> getTrailers(Movie item) async {
    try {
      return await tmdbService.getTrailers(item.id.toString(), item.mediaType);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Trailer: $e');
      return [];
    }
  }

  @override
  Future<List<Movie>> getRecommendations(Movie movie) async {
    try {
      return await tmdbService.getRecommendations(
        movie.id.toString(),
        movie.mediaType,
      );
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Trailer: $e');
      return [];
    }
  }

  @override
  Future<Movie> getMovie(Movie item) async {
    TmdbService tmdbService = TmdbService();
    try {
      Movie movie = await _db.getMovie(item.id, item.mediaType);
      if (movie.firebaseId == '') {
        movie = await tmdbService.getMovieWithCredits(movie);
      }
      return movie;
    } on Exception catch (e) {
      throw Exception('Fehler beim Laden des Films: $e');
    }
  }

  Future<void> toggleNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if (token == null) return;

    if (_notificationSet) {
      await _db.removeNotification(token, _model.movie);
      _notificationSet = false;
    } else {
      await _db.setNotification(_model.movie, token, []);
      _notificationSet = true;
    }
    notifyListeners();
  }

  Future<void> loadNotificationState() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if (token != null) {
      _notificationSet = await _db.isNotificationSet(token, _model.movie);
      notifyListeners();
    }
  }
}
