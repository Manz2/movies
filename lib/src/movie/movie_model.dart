import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/home/movie.dart';

class MovieModel {
  Movie movie;
  List<Watchlist> watchlists = [];
  Providers providers;
  List<String> trailers;
  List<Movie> recommendations = [];
  MovieModel({
    required this.movie,
    required this.providers,
    required this.trailers,
    required this.recommendations,
  });
}

class Provider {
  String icon;
  String type;
  String id;
  Provider({required this.icon, required this.type, required this.id});
  Provider.fromJson(Map<String, dynamic> json)
    : icon = json['icon'],
      type = json['type'],
      id = json['id'];
  Map<String, dynamic> toJson() => {'icon': icon, 'type': type, 'id': id};
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
  List<Movie> recommendations;
  MovieViewArguments({
    required this.movie,
    required this.providers,
    required this.trailers,
    required this.recommendations,
    this.autoplay,
  });
}
