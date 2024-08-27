import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';

class MovieController {
  final MovieModel _model;

  MovieController({required Movie movie}) : _model = MovieModel(movie: movie);

  MovieModel get model => _model;
}