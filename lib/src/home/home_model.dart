import 'package:movies/src/home/movie.dart';

class HomeModel{
  List<Movie> movies;


  HomeModel({required this.movies});

  void addMovie(Movie movie) {
    movies.add(movie);
  }
}

