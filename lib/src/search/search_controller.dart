import 'package:flutter/material.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/search/search_model.dart';
import 'package:movies/src/tmdb_service.dart';

class SearchPageController {
  final SearchModel _model;
  final TmdbService tmdbService = TmdbService();
  SearchPageController() : _model = SearchModel(results: []);

  SearchModel get model => _model;

  Future<void> getResult(BuildContext context, Result result) async {
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
            movies: movies),
      );
    } else if (result.type == 'movie' || result.type == 'tv') {
      Movie movie = await _getMovie(result.id, result.type);
      if (!context.mounted) return;
      Navigator.pushNamed(context, MovieView.routeName, arguments: movie);
    } else {
      print('Unbekannter media_type: ${result.type}');
    }
  }

  Future<void> search(String text) async {
    try {
      _model.results = await tmdbService.combinedSearch(text);
    } on Exception catch (e) {
      print('Fehler beim kombinierten suchen: $e');
    }
  }

  Future<List<Movie>> _getMovies(int actorId) async {
    try {
      return await tmdbService.getCombinedCredits(actorId);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
    }
    return [];
  }

  Future<Movie> _getMovie(String id, String mediaType) async {
    try {
      return await tmdbService.getMovieWithCredits(int.parse(id), mediaType);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
      return testMovie; //Fehlerbehandlung
    }
  }

  Future<void> getPopular() async {
    try {
      _model.results = await tmdbService.getPopular();
    } on Exception catch (e) {
      print('Failed to get popular movies $e');
    }
  }
}
