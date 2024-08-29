import 'package:json_store/json_store.dart';
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
    // Überprüfen, ob ein Film mit derselben ID und demselben mediaType existiert
    for (var movie in await _db.getMovies()) {
      if (movie.id == _model.movie.id &&
          movie.mediaType == _model.movie.mediaType) {
        return true; // Film existiert bereits
      }
    }

    return false; // Kein Film mit derselben ID und demselben mediaType gefunden
  }

  addMovie() async {
    List<Movie> movies = await _db.getMovies();
    movies.add(_model.movie);
    await _db.setMovies(movies);
  }
}
