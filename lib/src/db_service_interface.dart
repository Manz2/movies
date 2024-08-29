import 'package:movies/src/home/movie.dart';

abstract class DbServiceInterface {
  Future<List<Movie>> getMovies();
  Future<void> setMovies(List<Movie> movies);
}
