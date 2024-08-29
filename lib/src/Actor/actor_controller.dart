import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class ActorController {
  final ActorModel _model;
  final TmdbService tmdbService = TmdbService();
  ActorController({required Actor actor, required movies})
      : _model = ActorModel(actor: actor, movies: movies);

  ActorModel get model => _model;

  Future<void> loadMovies(int actorId) async {
    try {
      _model.setMovies(await tmdbService.getCombinedCredits(actorId));
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
    }
  }

  Future<Movie> getMovieWithCredits(Movie movie) async {
    try {
      return await tmdbService.getMovieWithCredits(
          int.parse(movie.id), movie.mediaType);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
      return testMovie; //Fehlerbehandlung
    }
  }
}
