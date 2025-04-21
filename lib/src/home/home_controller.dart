import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Filter/filter_model.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();
  final _db = DbCombinator();
  Logger logger = Logger();

  HomeController()
    : _model = HomeModel(
        movies: [],
        filter: Filter(
          movie: 3,
          fsk: [],
          durationFrom: 30,
          durationTo: 180,
          rating: 0,
          yearFrom: 0,
          yearTo: 6000,
          sortBy: 'Standard',
          accending: false,
        ),
      );

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    await _getFilteredMovies();
  }

  addMovie(BuildContext context, Movie movie) async {
    try {
      _model.addMovie(movie);
      _db.addMovie(movie);
    } on Exception catch (e) {
      logger.e('Fehler beim Hinzufügen des Films: $e');
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Film mit der id $movie.id konnte nicht hinzugefügt werden",
          ),
        ),
      );
    }
  }

  Future<void> removeMovie(Movie movie) async {
    try {
      await _db.removeMovie(movie);
      _model.removeMovie(movie);
    } catch (e) {
      logger.e('Fehler beim Entfernen des Films: $e');
    }
  }

  // Die Methode zur Filterung der Filme
  Future<void> _getFilteredMovies() async {
    // Hole die Liste aller Filme
    _model.movies = await _db.getMovies();

    // Initialisiere die Liste der gefilterten Filme
    List<Movie> filteredMovies = [];

    // Hole das Filterobjekt
    Filter filter = _model.filter;

    // Filtere die Filme basierend auf den Filterkriterien
    for (var movie in _model.movies) {
      bool matchesFilter = true;

      // Filtere nach Filmtitel
      if (filter.movie == 1 && movie.mediaType != 'movie') {
        matchesFilter = false;
      } else if (filter.movie == 2 && movie.mediaType != 'tv') {
        matchesFilter = false;
      } else if (filter.movie == 3 &&
          !(movie.mediaType == 'movie' || movie.mediaType == 'tv')) {
        matchesFilter = false;
      }

      // Filtere nach FSK
      if (filter.fsk.isNotEmpty && !filter.fsk.contains(movie.fsk)) {
        matchesFilter = false;
      }

      // Filtere nach Dauer
      if ((filter.durationFrom > 30 && movie.duration < filter.durationFrom) ||
          (filter.durationTo < 180 && movie.duration > filter.durationTo)) {
        matchesFilter = false;
      }

      // Filtere nach Bewertung
      if (movie.privateRating < filter.rating && filter.rating != 0) {
        matchesFilter = false;
      }

      // Filtere nach Jahr
      if (movie.year < filter.yearFrom || movie.year > filter.yearTo) {
        matchesFilter = false;
      }

      // Füge den Film zur gefilterten Liste hinzu, wenn er alle Kriterien erfüllt
      if (matchesFilter) {
        filteredMovies.add(movie);
      }
    }
    //Dauer passt
    if (filter.sortBy != 'Standard') {
      filteredMovies.sort((a, b) {
        if (filter.accending) {
          final temp = a;
          a = b;
          b = temp;
        }
        switch (filter.sortBy) {
          case 'Hinzugefügt':
            return a.addedAt.compareTo(b.addedAt);
          case 'Alphabetisch':
            return b.title.compareTo(a.title);
          case 'Dauer':
            return a.duration.compareTo(b.duration);
          case 'Public Rating':
            return a.rating.compareTo(b.rating);
          case 'Bewertung':
            return a.privateRating.compareTo(b.privateRating);
          case 'Jahr':
            return a.year.compareTo(b.year);
          default:
            return 0;
        }
      });
    }
    _model.movies = filteredMovies;
    _model.filteredMovies = filteredMovies;
  }

  Future<void> syncMovies() async {
    _model.movies = await _db.syncMovies();
    _model.filteredMovies = _model.movies;
    _model.filter = Filter(
      movie: 3,
      fsk: [],
      durationFrom: 30,
      durationTo: 180,
      rating: 0,
      yearFrom: 0,
      yearTo: 6000,
      sortBy: 'Standard',
      accending: false,
    );
  }

  Future<Watchlist> getCurrentWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('current_watchlist') ?? '';
    if (id == '') {
      return _db.getWatchlists().then((value) {
        if (value.isNotEmpty) {
          prefs.setString('current_watchlist', value.first.id);
          return value.first;
        } else {
          return Watchlist(id: '', name: 'Watchlist', entries: []);
        }
      });
    } else {
      try {
        return await _db.getWatchlistMovies(id);
      } finally {}
    }
  }

  Future<Providers> getProviders(Movie item) async {
    try {
      return await tmdbService.getProviders(item.id.toString(), item.mediaType);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Provider: $e');
      return Providers(providers: [], link: '');
    }
  }

  Future<List<String>> getTrailers(Movie item) async {
    try {
      return await tmdbService.getTrailers(item.id.toString(), item.mediaType);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Trailer: $e');
      return [];
    }
  }
}
