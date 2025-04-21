import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/home/movie.dart';

class MovieModel {
  Movie movie;
  List<Watchlist> watchlists = [];
  Providers providers;
  List<String> trailers;
  MovieModel({
    required this.movie,
    required this.providers,
    required this.trailers,
  });
}

class Provider {
  String icon;
  String type;
  String id;
  Provider({required this.icon, required this.type, required this.id});
}

class Providers {
  List<Provider> providers = [];
  String link;
  Providers({required this.providers, required this.link});
}

class MovieViewArguments {
  Movie movie;
  Providers providers;
  List<String> trailers;
  bool? autoplay;
  MovieViewArguments({
    required this.movie,
    required this.providers,
    required this.trailers,
    this.autoplay,
  });
}
