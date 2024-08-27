import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();

  HomeController() : _model = HomeModel(movies: [testMovie]);

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    try {
      Movie movie = await tmdbService.getMovie(268);
      _model.addMovie(movie);
      Movie movie2 = await tmdbService.getMovie(98);
      _model.addMovie(movie2);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
    }
  }

  Future<Movie> getMovieWithCredits(String id) async {
    try {
      return await tmdbService.getMovieWithCredits(int.parse(id)); 
    } on Exception catch (e) {
      return testMovie; //Fehlerbehandlung
      print('Fehler beim Laden des Films: $e');
    }
  }
}
