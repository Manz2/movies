import 'package:movies/src/db_service_local.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/tmdb_service.dart';

class MovieController {
  final MovieModel _model;
  final _db = DbServiceLocal();

  MovieController({required Movie movie}) : _model = MovieModel(movie: movie);
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
    return _db.movieExists(_model.movie.id, _model.movie.mediaType);
  }

  addMovie() async {
    await _db.addMovie(_model.movie);
  }

  Future<void> setRating(double rating) async {
    _model.movie.privateRating = rating;
    await _db.setMovie(_model.movie);
  }
}
