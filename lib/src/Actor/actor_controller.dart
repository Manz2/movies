import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/db_combinator.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class ActorController {
  final ActorModel _model;
  final TmdbService tmdbService = TmdbService();
  final DbCombinator _db = DbCombinator();
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
}
