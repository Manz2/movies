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
  final DbCombinator _db;
  final String uid;

  SearchPageController({required this.uid})
    : _model = SearchModel(results: []),
      _db = DbCombinator(uid: uid);

  SearchModel get model => _model;
  Logger logger = Logger();

  Future<void> getResult(
    BuildContext context,
    Result result,
    double fontSize,
  ) async {
    if (result.type == 'person') {
      final movies = await _getMovies(int.parse(result.id));
      final actor = await tmdbService.getActor(Actor(name: result.name, image: result.image, roleName: "", id: int.parse(result.id), biography: '', birthday: null, deathday: null));
      if (!context.mounted) return;
      Navigator.pushNamed(
        context,
        ActorView.routeName,
        arguments: ActorViewArguments(
          actor: actor,
          movies: movies,
          fontSize: fontSize,
          isDirector: false,
        ),
      );
    } else if (result.type == 'movie' || result.type == 'tv') {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        Movie movie = await getMovie(result.id, result.type);
        Providers providers = await getProviders(movie);
        List<String> trailers = await getTrailers(movie);
        List<Movie> recommendations = await getRecommendations(movie);
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        Navigator.pushNamed(
          context,
          MovieView.routeName,
          arguments: MovieViewArguments(
            movie: movie,
            providers: providers,
            trailers: trailers,
            recommendations: recommendations
          ),
        );
      } on Exception catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
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
      // Lokale Movies laden
      List<Movie> localMovies = await _db.getMovies();

      // Set aus kombinierten "id|mediaType"-Strings erstellen
      Set<String> localMovieKeys =
          localMovies.map((m) => '${m.id}|${m.mediaType}').toSet();

      List<Movie> combinedCredits = await tmdbService.getCombinedCredits(
        actorId,
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
    }
    return [];
  }

  Future<Movie> getMovie(String id, String mediaType) async {
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

  Future<Providers> getProviders(Movie item) async {
    try {
      return await tmdbService.getProviders(item.id.toString(), item.mediaType);
    } on Exception catch (e) {
      logger.d('Fehler beim Laden der Provider: $e');
      return Providers(providers: [], link: '');
    }
  }

  Future<List<String>> getTrailers(Movie movie) async {
    try {
      return await tmdbService.getTrailers(
        movie.id.toString(),
        movie.mediaType,
      );
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
