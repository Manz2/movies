import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/tmdb_service.dart';

class MovieController {
  final MovieModel _model;
  final _db = DbCombinator();

  MovieController({required Movie movie, required Providers providers, required List<String> trailers}) : _model = MovieModel(movie: movie, providers: providers, trailers: trailers);
  final TmdbService tmdbService = TmdbService();
  MovieModel get model => _model;

  /*
  * Returns all Movies from a specific actor sorted by Popularity
  * param: actorId: a string representing the caracter id of the Actor
  * returns: a list of Movies
  */
  Future<List<Movie>> getMovies(int actorId) async {
    try {
      return await tmdbService.getCombinedCredits(actorId);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
    }
    return [];
  }

  Future<bool> isSaved() async {
    return _model.movie.firebaseId != '';
  }

  Future<void> addMovie() async {
    try {
      _model.movie = await _db.addMovie(_model.movie);
    } catch (e) {
      print('Fehler beim Hinzufügen des Films: $e');
    }
  }

  Future<void> setRating(double rating) async {
    _model.movie.privateRating = rating;
    await _db.setMovie(_model.movie);
  }

  Future<void> getWatchlists() async {
    _model.watchlists = await _db.getWatchlists();
  }

  Future<void> addMovieToWatchlist(
      Watchlist watchlist, BuildContext context) async {
    if (watchlist.entries.any((element) =>
        element.id == _model.movie.id &&
        element.type == _model.movie.mediaType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${_model.movie.title} ist bereits in ${watchlist.name} enthalten"),
        ),
      );
      return;
    }
    await _db.addMovieToWatchlist(watchlist, _model.movie);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "${_model.movie.title} wurde zu ${watchlist.name} hinzugefügt"),
      ),
    );
  }

  Future<void> addWatchlist(String name) async {
    _model.watchlists.add(await _db.addWatchlist(name));
  }
}
