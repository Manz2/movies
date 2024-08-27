import 'package:movies/src/home/movie.dart';

class ActorModel {
  Actor actor;
  List<Movie> movies;
  ActorModel({required this.actor, required this.movies});

  void setMovies(List<Movie> moviesM) {
    movies = moviesM;
  }
}

class ActorViewArguments {
  final Actor actor;
  final List<Movie> movies;

  ActorViewArguments({required this.actor, required this.movies});
}