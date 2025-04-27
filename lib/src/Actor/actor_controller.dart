import 'package:logger/logger.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/tmdb_service.dart';

class ActorController {
  final ActorModel _model;
  final TmdbService tmdbService = TmdbService();
  final String uid;
  final DbCombinator _db;
  ActorController({required Actor actor, required movies, required this.uid})
    : _db = DbCombinator(uid: uid),
      _model = ActorModel(actor: actor, movies: movies);

  ActorModel get model => _model;
  Logger logger = Logger();

  Future<Movie> getMovieWithCredits(Movie movie2) async {
    try {
      Movie movie = await _db.getMovie(movie2.id, movie2.mediaType);
      if (movie.firebaseId == '') {
        movie = await tmdbService.getMovieWithCredits(movie);
      }
      return movie;
    } on Exception catch (e) {
      throw Exception('Fehler beim Laden des Films: $e');
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
