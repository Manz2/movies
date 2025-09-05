import 'package:movies/src/home/movie.dart';

class ActorModel {
  Actor actor;
  List<Movie> movies;
  bool isDirector;

  ActorModel({
    required this.actor,
    required this.movies,
    required this.isDirector,
  });

  void setMovies(List<Movie> moviesM) {
    movies = moviesM;
  }
}

class ActorViewArguments {
  final Actor actor;
  final List<Movie> movies;
  final double fontSize;
  final bool isDirector;

  ActorViewArguments({
    required this.actor,
    required this.movies,
    required this.fontSize,
    required this.isDirector,
  });
}
