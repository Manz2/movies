import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/tmdb_service.dart';

class MovieController {
  final MovieModel _model;

  MovieController({required Movie movie}) : _model = MovieModel(movie: movie);
final TmdbService tmdbService = TmdbService();
  MovieModel get model => _model;

  Future<List<Movie>> getMovies(String actorId) async {
    try {
      return await tmdbService.getCombinedCredits(actorId);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
    }
    return [];
  }
}