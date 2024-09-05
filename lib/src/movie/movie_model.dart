import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/home/movie.dart';

class MovieModel {
  Movie movie;
  List<Watchlist> watchlists = [];
  MovieModel({required this.movie});
}
