import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/db_service_local.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class ActorController {
  final ActorModel _model;
  final TmdbService tmdbService = TmdbService();
  final DbServiceLocal _db = DbServiceLocal();
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
      movie = await _db.getMovie(movie.id, movie.mediaType);
    } catch (e) {
      print('Film noch nicht gespeichert');
    }
    try {
      return await tmdbService.getMovieWithCredits(movie);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
      return testMovie; //Fehlerbehandlung
    }
  }
}
