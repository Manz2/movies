import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/search/search_model.dart';
import 'package:movies/src/secrets.dart';

class TmdbService {
  final String apiKey = tmdbAPIKey;
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<Movie> getMovie(int id, String mediaType) async {
    final url = '$baseUrl/$mediaType/$id?api_key=$apiKey&language=de-DE';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return movieFromTmdb(json.decode(response.body), mediaType);
    } else {
      throw HttpException("Failed to load movie with id=$id");
    }
  }

  Future<Movie> getMovieWithCredits(int id, String mediaType) async {
    Movie movie = await getMovie(id, mediaType);
    final url;
    if (mediaType == 'movie') {
      url = '$baseUrl/$mediaType/$id/credits?api_key=$apiKey&language=de-DE';
    } else {
      url =
          '$baseUrl/$mediaType/$id/aggregate_credits?api_key=$apiKey&language=de-DE';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<Actor> actors =
          creditsFromTmdb(json.decode(response.body), mediaType);
      movie.actors = actors;
    } else {
      throw HttpException("Failed to load credits for movie with id=$id");
    }

    if (mediaType == 'movie') {
      movie.fsk = await getMovieFsk(id);
    } else if (mediaType == 'tv') {
      movie.fsk = await getTvFsk(id);
    }

    return movie;
  }

  Future<String> getMovieFsk(int id) async {
    final url2 =
        '$baseUrl/movie/$id/release_dates?api_key=$apiKey&language=de-DE';
    final response2 = await http.get(Uri.parse(url2));
    Map<String, dynamic> json2 = json.decode(response2.body);
    if (response2.statusCode == 200) {
      String desiredIsoCode = "DE";
      for (var result in json2['results']) {
        if (result['iso_3166_1'] == desiredIsoCode) {
          List<dynamic> releaseDates = result['release_dates'];
          if (releaseDates.isNotEmpty) {
            for (var releaseDate in releaseDates) {
              String fsk = releaseDate['certification'];
              if (fsk == '0' ||
                  fsk == '6' ||
                  fsk == '12' ||
                  fsk == '16' ||
                  fsk == '18') {
                return releaseDate['certification'];
              }
            }
          }
          break; // Abbrechen, da der gewünschte Eintrag gefunden wurde
        }
      }
    }
    print("Failed to load fsk for movie with id=$id");
    return 'Unbekannt';
  }

  Future<String> getTvFsk(int id) async {
    final url2 =
        '$baseUrl/tv/$id/content_ratings?api_key=$apiKey&language=de-DE';
    final response2 = await http.get(Uri.parse(url2));
    Map<String, dynamic> json2 = json.decode(response2.body);
    if (response2.statusCode == 200) {
      String desiredIsoCode = "DE";
      for (var result in json2['results']) {
        if (result['iso_3166_1'] == desiredIsoCode) {
          if (result.isNotEmpty) {
            String fsk = result['rating'];
            if (fsk == '0' ||
                fsk == '6' ||
                fsk == '12' ||
                fsk == '16' ||
                fsk == '18') {
              return result['rating'];
            } else {
              return 'unbekannt';
            }
          }
        }
      }
    }
    print("Failed to load fsk for movie with id=$id");
    return 'Unbekannt';
  }

  Movie movieFromTmdb(Map<String, dynamic> json, String mediaType2) {
    // Extrahieren der Basisinformationen aus dem JSON-Objekt
    String id = json['id'].toString();
    String title = json['title'] ??
        json['original_title'] ??
        json['original_name'] ??
        "kein Titel";
    String description = json['overview'] ?? 'Keine Beschreibung verfügbar';
    String fsk = json['age_rating'] ??
        'Unbekannt'; // Hier könnte eine spezifische Logik für FSK notwendig sein
    int rating = (json['vote_average'] * 10)
        .round(); // Umwandlung des Ratings in Prozent
    int year = json['release_date'] != null && json['release_date'].isNotEmpty
        ? DateTime.parse(json['release_date']).year
        : 0;
    int duration =
        json['runtime'] ?? 0; // Default auf 0, wenn keine Dauer angegeben
    String image = json['poster_path'] != null
        ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
        : '';
    double popularity = json['popularity'] ?? 0;
    String mediaType = json['media_type'] ?? mediaType2;

    // Extrahieren der Genres
    List<String> genre = json['genres'] != null
        ? List<String>.from(json['genres'].map((g) => g['name']))
        : [];

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
        popularity: popularity,
        mediaType: mediaType);
  }

  List<Actor> creditsFromTmdb(Map<String, dynamic> json, String mediaType) {
    List<Actor> actors = [];
    if (json['cast'] != null) {
      for (var actorJson in json['cast']) {
        Actor actor = Actor(
          name: actorJson['name'],
          image: actorJson['profile_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${actorJson['profile_path']}'
              : '',
          roleName: actorJson['character'] ?? 'Unbekannt',
          id: actorJson['id'] ?? 0, //Hier sollte nicht 0 stehen
        );
        if (mediaType == 'tv' && actorJson['roles'] != null) {
          final buffer = StringBuffer();
          bool first = true;
          for (var role in actorJson['roles']) {
            if (role['character'] != null) {
              buffer.write(role['character']);
              if (first) {
                buffer.write(' ');
                first = false;
              } else {
                buffer.write('/');
              }
            }
          }
          actor.roleName = buffer.toString().substring(0, buffer.length - 1);
        }
        actors.add(actor);
      }
    }
    return actors;
  }

  Future<List<Movie>> getCombinedCredits(int id) async {
    final url =
        '$baseUrl/person/$id/combined_credits?api_key=$apiKey&language=de-DE';

    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> moviesJson = json.decode(response.body);
    List<Movie> movies = [];

    if (response.statusCode == 200) {
      for (var movie in moviesJson['cast']) {
        movies.add(movieFromTmdb(movie, 'unbekannt'));
      }
    } else {
      throw HttpException("Failed to load movie with id=$id");
    }
    return movies;
  }

  Future<List<Result>> combinedSearch(String search) async {
    final url =
        '$baseUrl/search/multi?api_key=$apiKey&language=de-DE&query=$search';

    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> resultJson = json.decode(response.body);
    List<Result> results = [];

    if (response.statusCode == 200) {
      for (var result in resultJson['results']) {
        results.add(resultFromTmdb(result));
      }
    } else {
      throw HttpException("Failed search with querry=$search");
    }
    return results;
  }

  Result resultFromTmdb(Map<String, dynamic> json) {
    String id = json['id'].toString();
    String name = json['name'] ??
        json['original_name'] ??
        json['original_title'] ??
        "kein Name";
    String image = json['poster_path'] ?? json['profile_path'] ?? '';
    if (image != '') {
      image = 'https://image.tmdb.org/t/p/w500$image';
    }
    String mediaType = json['media_type'] ?? 'Unbekannt';

    return Result(name: name, image: image, type: mediaType, id: id);
  }

  Future<List<Result>> getPopular() async {
    final url =
        '$baseUrl/movie/popular?api_key=$apiKey&language=de-DE&region=Deutschland';

    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> resultJson = json.decode(response.body);
    List<Result> results = [];

    if (response.statusCode == 200) {
      for (var result in resultJson['results']) {
        Result rs = resultFromTmdb(result);
        // This is necessary because popular does not have a modia_type field.
        rs.type = 'movie';
        results.add(rs);
      }
    } else {
      throw const HttpException("Failed to get popular movies");
    }
    return results;
  }
}
