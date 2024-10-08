import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/search/search_model.dart';
import 'package:movies/src/tmdb_service.dart';

class SearchPageController {
  final SearchModel _model;
  final TmdbService tmdbService = TmdbService();
  final DbCombinator _db = DbCombinator();
  SearchPageController() : _model = SearchModel(results: []);

  SearchModel get model => _model;
  Logger logger = Logger();

  Future<void> getResult(
      BuildContext context, Result result, double fontSize) async {
    if (result.type == 'person') {
      final movies = await _getMovies(int.parse(result.id));
      if (!context.mounted) return;
      Navigator.pushNamed(
        context,
        ActorView.routeName,
        arguments: ActorViewArguments(
            actor: Actor(
                name: result.name,
                image: result.image,
                roleName: "roleName",
                id: int.parse(result.id)),
            movies: movies,
            fontSize: fontSize),
      );
    } else if (result.type == 'movie' || result.type == 'tv') {
      try {
        Movie movie = await _getMovie(result.id, result.type);
        Providers providers = await _getProviders(movie);
        List<String> trailers = await _getTrailers(movie);
        if (!context.mounted) return;
        Navigator.pushNamed(context, MovieView.routeName,
            arguments: MovieViewArguments(
                movie: movie, providers: providers, trailers: trailers));
      } on Exception catch (e) {
        throw Exception('Fehler beim Laden des Films: $e');
      }
    } else {
      logger.e('Unbekannter Typ: ${result.type}');
    }
  }

  Future<void> search(String text) async {
    try {
      _model.results = await tmdbService.combinedSearch(text);
    } on Exception catch (e) {
      logger.e('Fehler beim Suchen: $e');
    }
  }

  Future<List<Movie>> _getMovies(int actorId) async {
    try {
      return await tmdbService.getCombinedCredits(actorId);
    } on Exception catch (e) {
      logger.e('Fehler beim Laden der Filme: $e');
    }
    return [];
  }

  Future<Movie> _getMovie(String id, String mediaType) async {
    try {
      Movie movie = await _db.getMovie(id, mediaType);
      if (movie.firebaseId == '') {
        movie = await tmdbService.getMovieWithCredits(movie);
      }
      return movie;
    } on Exception catch (e) {
      throw Exception('Fehler beim Laden des Films: $e');
    }
  }

  Future<void> getPopular() async {
    try {
      _model.results = await tmdbService.getPopular();
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der beliebtesten Filme: $e');
    }
  }

  Future<Providers> _getProviders(Movie item) async {
    try {
      return await tmdbService.getProviders(item.id.toString(), item.mediaType);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Provider: $e');
      return Providers(providers: [], link: '');
    }
  }

  Future<List<String>> _getTrailers(Movie movie) async {
    try {
      return await tmdbService.getTrailers(
          movie.id.toString(), movie.mediaType);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Trailer: $e');
      return [];
    }
  }
}
