import 'package:flutter/material.dart';
import 'package:movies/src/Filter/filter_model.dart';
import 'package:movies/src/db_service_local.dart';
import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();
  final _db = DbServiceLocal();

  HomeController()
      : _model = HomeModel(
            movies: [],
            filter: Filter(
                movie: 3,
                fsk: [],
                durationFrom: 0,
                durationTo: 400,
                rating: 0,
                yearFrom: 0,
                yearTo: 6000));

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    _model.movies = await _db.getMovies();
  }

  Future<Movie> getMovieWithCredits(Movie movie) async {
    try {
      return await tmdbService.getMovieWithCredits(movie);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
      return testMovie; //Fehlerbehandlung
    }
  }

  addMovieWithId(BuildContext context, Movie movie) async {
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

  Future<Movie> removeMovie(Movie movie) async {
    Movie movie2 = await _db.getMovie(movie.id, movie.mediaType);
    _model.removeMovie(movie);
    _db.removeMovie(movie);
    return movie2;
  }
}
