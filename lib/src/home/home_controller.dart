import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/test_movie.dart';

class HomeController {
  final HomeModel _model;

  HomeController() : _model = HomeModel(movies: [testMovie]);

  HomeModel get model => _model;
}