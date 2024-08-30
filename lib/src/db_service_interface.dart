import 'package:movies/src/home/movie.dart';

abstract class DbServiceInterface {
  Future<List<Movie>> getMovies();
  Future<void> setMovies(List<Movie> movies);
  Future<Movie> getMovie(String id, String mediaType);
  Future<void> addMovie(movie);
  Future<void> removeMovie(Movie movie);
  Future<void> setMovie(Movie movie2);
  Future<bool> movieExists(String id, String mediaType);
}
