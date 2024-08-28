import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();

  HomeController() : _model = HomeModel(movies: []);

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    try {
      Movie movie = await tmdbService.getMovie(268,'movie');
      _model.addMovie(movie);
      Movie movie2 = await tmdbService.getMovie(98,'movie');
      _model.addMovie(movie2);
      Movie movie3 = await tmdbService.getMovie(13,'movie');
      _model.addMovie(movie3);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
    }
  }

  Future<Movie> getMovieWithCredits(String id, String mediaType) async {
    try {
      return await tmdbService.getMovieWithCredits(int.parse(id),mediaType); 
    } on Exception catch (e) {
      return testMovie; //Fehlerbehandlung
      print('Fehler beim Laden des Films: $e');
    }
  }
}
