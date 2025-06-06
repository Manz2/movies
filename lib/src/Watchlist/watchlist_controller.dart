import 'package:logger/logger.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistController {
  final WatchlistModel _model;
  TmdbService tmdbService = TmdbService();
  final DbCombinator _db;
  WatchlistController({
    required Watchlist currentWatchlist,
    required String uid,
  }) : _model = WatchlistModel(currentWatchlist: currentWatchlist),
       _db = DbCombinator(uid: uid);
  WatchlistModel get model => _model;
  Logger logger = Logger();

  Future<void> getWatchlists() async {
    _model.watchlists = await _db.getWatchlists();
  }

  Future<void> addWatchlist(Watchlist watchlist) async {
    if (watchlist.id == '') {
      return;
    }
    try {
      await _db.setWatchlist(watchlist);
    } catch (e) {
      logger.e('Fehler beim Hinzufügen der Watchlist: $e');
    }
  }

  Future<void> addNewWatchlist(String name) async {
    _model.watchlists.add(await _db.addWatchlist(name));
  }

  Future<void> removeWatchlist(Watchlist watchlist) async {
    try {
      if (watchlist.id == '') {
        return;
      }
      await _db.removeWatchlist(watchlist.id);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('current_watchlist', '');
    } catch (e) {
      logger.e('Fehler beim Entfernen der Watchlist: $e');
    }
  }

  Future<void> addMovieToWatchlist(Entry entry) async {
    try {
      await _db.addMovieToWatchlist(
        model.currentWatchlist,
        await _db.getMovie(entry.id, entry.type),
      );
    } catch (e) {
      logger.e('Fehler beim Hinzufügen des Films zur Watchlist: $e');
    }
  }

  Future<void> removeMovieFromWatchlist(Entry entry) async {
    try {
      await _db.removeMovieFromWatchlist(model.currentWatchlist, entry);
      model.currentWatchlist.entries.remove(entry);
    } catch (e) {
      logger.e('Fehler beim Entfernen des Films von der Watchlist: $e');
    }
  }

  Future<void> getMoviesForCurrentWatchlist(Watchlist watchlist) async {
    try {
      if (watchlist.id == '') {
        return;
      }
      try {
        model.currentWatchlist = await _db.getWatchlistMovies(watchlist.id);
      } on Exception catch (e) {
        logger.d('Fehler beim Laden der Filme aus der Watchlist: $e');
        model.currentWatchlist = Watchlist(
          id: '',
          name: 'Watchlist',
          entries: [],
        );
      }
    } catch (e) {
      logger.e('Fehler beim Laden der Filme aus der Watchlist: $e');
    }
  }

  Future<void> changeWatchlist(Watchlist watchlist) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('current_watchlist', watchlist.id);
      model.currentWatchlist = watchlist;
    } catch (e) {
      logger.e('Fehler beim Ändern der Watchlist: $e');
    }
  }

  Future<Movie> getMovie(Entry item) async {
    TmdbService tmdbService = TmdbService();
    try {
      Movie movie = await _db.getMovie(item.id, item.type);
      if (movie.firebaseId == '') {
        movie = await tmdbService.getMovieWithCredits(movie);
      }
      return movie;
    } on Exception catch (e) {
      throw Exception('Fehler beim Laden des Films: $e');
    }
  }

  Future<Providers> getProviders(Entry item) async {
    try {
      return await tmdbService.getProviders(item.id.toString(), item.type);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Provider: $e');
      return Providers(providers: [], link: '');
    }
  }

  Future<List<String>> getTrailers(Entry item) async {
    try {
      return await tmdbService.getTrailers(item.id.toString(), item.type);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Trailer: $e');
      return [];
    }
  }

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
}
