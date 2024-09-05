import 'package:flutter/material.dart';
import 'package:movies/src/Filter/filter_model.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();
  final _db = DbCombinator();

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
                yearTo: 6000));

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    await _getFilteredMovies();
  }

  addMovie(BuildContext context, Movie movie) async {
    try {
      _model.addMovie(movie);
      _db.addMovie(movie);
    } on Exception catch (e) {
      print(e.toString());
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Film mit der id $movie.id konnte nicht hinzugefügt werden"),
        ),
      );
    }
  }

  Future<void> removeMovie(Movie movie) async {
    try {
      await _db.removeMovie(movie);
      _model.removeMovie(movie);
    } catch (e) {
      print(e.toString());
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

    // Setze die gefilterten Filme in das Modell
    print(filteredMovies.length);
    _model.movies = filteredMovies;
  }

  Future<void> syncMovies() async {
    _model.movies = await _db.syncMovies();
  }
}
