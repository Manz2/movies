import 'package:json_store/json_store.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/tmdb_service.dart';

class MovieController {
  final MovieModel _model;
  final _jsonStore = JsonStore(dbName: 'movies');

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
    // Hol die gespeicherten Daten aus dem JsonStore
    Map<String, dynamic>? storedData = await _jsonStore.getItem('movies');

    // Überprüfen, ob gespeicherte Daten vorhanden sind und ob 'movies' enthalten ist
    if (storedData != null && storedData.containsKey('movies')) {
      List<dynamic> moviesJson = storedData['movies'];

      // Überprüfen, ob ein Film mit derselben ID und demselben mediaType existiert
      for (var movie in moviesJson) {
        if (movie['id'] == _model.movie.id &&
            movie['MediaType'] == _model.movie.mediaType) {
          return true; // Film existiert bereits
        }
      }
    }

    return false; // Kein Film mit derselben ID und demselben mediaType gefunden
  }

  addMovie() async {
    Map<String, dynamic>? storedData = await _jsonStore.getItem('movies');
    List<dynamic> moviesJson = [];

    if (storedData != null && storedData.containsKey('movies')) {
      moviesJson = storedData['movies'];
    }
    // Neuen Film zur JSON-Liste hinzufügen
    moviesJson.add(_model.movie.toJson());

    // Aktualisierte Liste im Store speichern
    await _jsonStore.setItem('movies', {'movies': moviesJson}, encrypt: false);
  }
}
