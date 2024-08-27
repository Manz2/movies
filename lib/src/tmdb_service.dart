import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/secrets.dart';

class TmdbService {
  final String apiKey = tmdbAPIKey;
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<Movie> getMovie(int id) async {
    final url = '$baseUrl/movie/$id?api_key=$apiKey&lamguage=de-DE';

     final response = await http.get(Uri.parse(url));

     if (response.statusCode == 200) {
      return movieFromTmdb(json.decode(response.body));
    } else {
      throw HttpException("Failed to load movie with id=$id");
    }
  }

  Future<Movie> getMovieWithCredits(int id) async {
    Movie movie = await getMovie(id);
    final url = '$baseUrl/movie/$id/credits?api_key=$apiKey&lamguage=de-DE';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<Actor> actors =creditsFromTmdb(json.decode(response.body));
      movie.actors = actors;
      return movie;
    } else {
      throw HttpException("Failed to load credits for movie with id=$id");
    }
  }

 Movie movieFromTmdb(Map<String, dynamic> json) {
  // Extrahieren der Basisinformationen aus dem JSON-Objekt
  String id = json['id'].toString();
  String title = json['title'] ?? "kein Titel";
  String description = json['overview'] ?? 'Keine Beschreibung verfügbar';
  String fsk = json['age_rating'] ?? 'Unbekannt'; // Hier könnte eine spezifische Logik für FSK notwendig sein
  int rating = (json['vote_average'] * 10).round(); // Umwandlung des Ratings in Prozent
  int year = json['release_date'] != null && json['release_date'].isNotEmpty ? DateTime.parse(json['release_date']).year : 0;
  int duration = json['runtime'] ?? 0; // Default auf 0, wenn keine Dauer angegeben
  String image = json['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}' : '';

  // Extrahieren der Genres
  List<String> genre = json['genres']!= null ? List<String>.from(json['genres'].map((g) => g['name'])) : [];

  // Erstellen des Movie-Objekts
  return Movie(
    id: id,
    title: title,
    description: description,
    fsk: fsk,
    rating: rating,
    year: year,
    duration: duration,
    image: image,
    actors: [],
    genre: genre,
  );
}
List<Actor> creditsFromTmdb(Map<String, dynamic> json) {
  List<Actor> actors = [];
  if (json['cast'] != null) {
    for (var actorJson in json['cast']) {
      Actor actor = Actor(
        name: actorJson['name'],
        image: actorJson['profile_path'] != null ? 'https://image.tmdb.org/t/p/w500${actorJson['profile_path']}' : '',
        roleName: actorJson['character'] ?? 'Unbekannt',
        id: actorJson['credit_id'] ?? '1',
      );
      actors.add(actor);
    }
  }
  return actors;
}

Future<List<Movie>> getCombinedCredits(String id) async {
   final url = '$baseUrl/person/$id/combined_credits?api_key=$apiKey&lamguage=de-DE';

     final response = await http.get(Uri.parse(url));
     Map<String, dynamic> moviesJson = json.decode(response.body);
       List<Movie> movies = [];


     if (response.statusCode == 200) {
      for (var movie in moviesJson['cast']) {
        movies.add(movieFromTmdb(movie));
      }
    } else {
      throw HttpException("Failed to load movie with id=$id");
    }
    return movies;
}


}