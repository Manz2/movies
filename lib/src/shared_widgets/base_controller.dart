
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';

abstract class BaseController<T> {
  Future<Movie> getMovie(Movie movie);
  Future<Providers> getProviders(Movie item);
  Future<List<String>> getTrailers(Movie movie);
  Future<List<Movie>> getRecommendations(Movie movie);
}
