import 'package:movies/src/Filter/filter_model.dart';
import 'package:movies/src/home/movie.dart';

class HomeModel {
  List<Movie> movies;
  Filter filter;

  HomeModel({required this.movies, required this.filter});

  void addMovie(Movie movie) {
    movies.add(movie);
  }

  void removeMovie(Movie movie) {
    movies.remove(movie);
  }
}
