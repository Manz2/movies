import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/search/search_model.dart';
import 'package:movies/src/secrets.dart';

class TmdbService {
  final String apiKey = tmdbAPIKey;
  final String baseUrl = 'https://api.themoviedb.org/3';
  Logger logger = Logger();

  Future<Movie> getMovie(
    int id,
    String mediaType,
    double privateRating,
    String firebaseId,
    DateTime addedAt,
  ) async {
    final url = '$baseUrl/$mediaType/$id?api_key=$apiKey&language=de-DE';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return _movieFromTmdb(
        json.decode(response.body),
        mediaType,
        privateRating,
        firebaseId,
        addedAt,
      );
    } else {
      throw HttpException("Failed to load movie with id=$id");
    }
  }

  Future<Movie> getMovieWithCredits(Movie movie1) async {
    int id = int.parse(movie1.id);
    String mediaType = movie1.mediaType;
    double privateRating = movie1.privateRating;
    Movie movie = await getMovie(
      id,
      mediaType,
      privateRating,
      movie1.firebaseId,
      movie1.addedAt,
    );
    String url;
    if (mediaType == 'movie') {
      url = '$baseUrl/$mediaType/$id/credits?api_key=$apiKey&language=de-DE';
    } else {
      url =
          '$baseUrl/$mediaType/$id/aggregate_credits?api_key=$apiKey&language=de-DE';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<Actor> actors = _creditsFromTmdb(
        json.decode(response.body),
        mediaType,
      );
      movie.actors = actors;
    } else {
      throw HttpException("Failed to load credits for movie with id=$id");
    }

    if (mediaType == 'movie') {
      movie.fsk = await _getMovieFsk(id);
    } else if (mediaType == 'tv') {
      movie.fsk = await _getTvFsk(id);
    }

    movie.director = await getDirector(id, mediaType);

    return movie;
  }

  Future<Actor> getDirector(int id, String mediaType) async {
    String url;
    if (mediaType == 'movie') {
      url = '$baseUrl/movie/$id/credits?api_key=$apiKey&language=de-DE';
    } else if (mediaType == 'tv') {
      url = '$baseUrl/tv/$id/aggregate_credits?api_key=$apiKey&language=de-DE';
    } else {
      return Actor(
        name: '',
        image: '',
        roleName: '',
        id: 0,
        biography: '',
        birthday: null,
        deathday: null,
      );
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      if (mediaType == 'movie') {
        if (jsonMap['crew'] != null) {
          for (var crewMember in jsonMap['crew']) {
            if (crewMember['job'] == 'Director') {
              return Actor(
                name: crewMember['name'],
                image: crewMember['profile_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${crewMember['profile_path']}'
                    : '',
                roleName: crewMember['character'] ?? 'Unbekannt',
                id: crewMember['id'] ?? 0,
                biography: '',
                birthday: null,
                deathday: null,
              );
            }
          }
        }
      } else if (mediaType == 'tv') {
        if (jsonMap['crew'] != null) {
          for (var crewMember in jsonMap['crew']) {
            if (crewMember['jobs'] != null) {
              for (var job in crewMember['jobs']) {
                if (job['job'] == 'Director') {
                  return Actor(
                    name: crewMember['name'],
                    image: crewMember['profile_path'] != null
                        ? 'https://image.tmdb.org/t/p/w500${crewMember['profile_path']}'
                        : '',
                    roleName: crewMember['character'] ?? 'Unbekannt',
                    id: crewMember['id'] ?? 0,
                    biography: '',
                    birthday: null,
                    deathday: null,
                  );
                }
              }
            }
          }
        }
      }
    }
    return Actor(
      name: '',
      image: '',
      roleName: '',
      id: 0,
      biography: '',
      birthday: null,
      deathday: null,
    );
  }

  Future<String> _getMovieFsk(int id) async {
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
    logger.d("Failed to load fsk for movie with id=$id");
    return 'Unbekannt';
  }

  Future<String> _getTvFsk(int id) async {
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
    logger.d("Failed to load fsk for movie with id=$id");
    return 'Unbekannt';
  }

  Movie _movieFromTmdb(
    Map<String, dynamic> json,
    String mediaType2,
    double privateRating,
    String firebaseId,
    DateTime addedAt,
  ) {
    // Extrahieren der Basisinformationen aus dem JSON-Objekt
    String id = json['id'].toString();
    String title =
        json['title'] ??
        json['name'] ??
        json['original_title'] ??
        json['original_name'] ??
        "kein Titel";
    String description = json['overview'] ?? 'Keine Beschreibung verfügbar';
    String fsk =
        json['age_rating'] ??
        'Unbekannt'; // Hier könnte eine spezifische Logik für FSK notwendig sein
    int rating = (json['vote_average'] * 10)
        .round(); // Umwandlung des Ratings in Prozent
    int year = json['release_date'] != null && json['release_date'].isNotEmpty
        ? DateTime.parse(json['release_date']).year
        : 0;
    int duration =
        json['runtime'] ??
        json["number_of_seasons"] ??
        0; // Default auf 0, wenn keine Dauer angegeben
    String image = json['poster_path'] != null
        ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
        : '';
    double popularity = json['popularity'] ?? 0;
    String mediaType = json['media_type'] ?? mediaType2;

    if (year == 0 &&
        json['first_air_date'] != null &&
        json['first_air_date'].isNotEmpty) {
      year = DateTime.parse(json['first_air_date']).year;
    }

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
      mediaType: mediaType,
      privateRating: privateRating,
      firebaseId: firebaseId,
      addedAt: addedAt,
      director: testActor1,
    );
  }

  List<Actor> _creditsFromTmdb(Map<String, dynamic> json, String mediaType) {
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
          biography: '',
          birthday: null,
          deathday: null,
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

  Future<List<Movie>> getCombinedCredits(
    int id, {
    bool isDirector = false,
  }) async {
    final url =
        '$baseUrl/person/$id/combined_credits?api_key=$apiKey&language=de-DE';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw HttpException("Failed to load credits for person with id=$id");
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);

    // Wenn Director → crew filtern, sonst cast nehmen
    final List<dynamic> credits;
    if (isDirector) {
      credits = (jsonMap['crew'] as List<dynamic>)
          .where((c) => c['job'] == 'Director')
          .toList();
    } else {
      credits = jsonMap['cast'] as List<dynamic>;
    }

    // Nach vote_count sortieren (Absteigend)
    credits.sort((a, b) {
      final popA = (a['vote_count'] ?? 0).toDouble();
      final popB = (b['vote_count'] ?? 0).toDouble();
      return popB.compareTo(popA);
    });

    // Duplikate entfernen basierend auf der ID
    final Map<int, Movie> uniqueMovies = {};

    for (var json in credits) {
      final movie = _movieFromTmdb(json, 'unbekannt', 0, '', DateTime.now());
      uniqueMovies[int.parse(movie.id)] = movie;
    }

    return uniqueMovies.values.toList();
  }

  Future<List<Result>> combinedSearch(String search) async {
    final url =
        '$baseUrl/search/multi?api_key=$apiKey&language=de-DE&query=$search';

    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> resultJson = json.decode(response.body);
    List<Result> results = [];

    if (response.statusCode == 200) {
      for (var result in resultJson['results']) {
        results.add(_resultFromTmdb(result));
      }
    } else {
      throw HttpException("Failed search with querry=$search");
    }
    return results;
  }

  Result _resultFromTmdb(Map<String, dynamic> json) {
    String id = json['id'].toString();
    String name =
        json['name'] ??
        json['title'] ??
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
        Result rs = _resultFromTmdb(result);
        // This is necessary because popular does not have a modia_type field.
        rs.type = 'movie';
        results.add(rs);
      }
    } else {
      throw const HttpException("Failed to get popular movies");
    }
    return results;
  }

  Future<Providers> getProviders(String id, String mediaType) async {
    final url =
        '$baseUrl/$mediaType/$id/watch/providers?api_key=$apiKey&language=de-DE';

    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> resultJson = json.decode(response.body);
    List<Provider> providers = [];
    String link = '';

    if (response.statusCode == 200) {
      if (resultJson['results'] != null &&
          resultJson['results']['DE'] != null) {
        if (resultJson['results']['DE']['flatrate'] != null) {
          for (var provider in resultJson['results']['DE']['flatrate']) {
            providers.add(
              Provider(
                icon: provider['logo_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${provider['logo_path']}'
                    : '',
                id: provider['provider_id'].toString(),
                type: 'flatrate',
              ),
            );
          }
        }
        if (resultJson['results']['DE']['rent'] != null) {
          for (var provider in resultJson['results']['DE']['rent']) {
            providers.any((p) => p.id == provider['provider_id'].toString()) ==
                    false
                ? providers.add(
                    Provider(
                      icon: provider['logo_path'] != null
                          ? 'https://image.tmdb.org/t/p/w500${provider['logo_path']}'
                          : '',
                      id: provider['provider_id'].toString(),
                      type: 'rent',
                    ),
                  )
                : null;
          }
        }
        if (resultJson['results']['DE']['buy'] != null) {
          for (var provider in resultJson['results']['DE']['buy']) {
            providers.any((p) => p.id == provider['provider_id'].toString()) ==
                    false
                ? providers.add(
                    Provider(
                      icon: provider['logo_path'] != null
                          ? 'https://image.tmdb.org/t/p/w500${provider['logo_path']}'
                          : '',
                      id: provider['provider_id'].toString(),
                      type: 'buy',
                    ),
                  )
                : null;
          }
        }
        link = resultJson['results']['DE']['link'];
      }
    } else {
      throw HttpException("Failed to get providers for id=$id");
    }
    return Providers(providers: providers, link: link);
  }

  Future<List<String>> getTrailers(String id, String mediaType) async {
    final url = '$baseUrl/$mediaType/$id/videos?api_key=$apiKey&language=de-DE';

    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> resultJson = json.decode(response.body);
    List<String> trailers = [];

    if (response.statusCode == 200) {
      if (resultJson['results'] != null) {
        for (var trailer in resultJson['results']) {
          if (trailer['site'] == 'YouTube') {
            trailers.add(trailer['key']);
          }
        }
      } else {
        final url2 =
            '$baseUrl/$mediaType/$id/videos?api_key=$apiKey&language=en-US';
        final response2 = await http.get(Uri.parse(url2));
        Map<String, dynamic> resultJson2 = json.decode(response2.body);
        if (response2.statusCode == 200) {
          if (resultJson2['results'] != null) {
            for (var trailer in resultJson2['results']) {
              if (trailer['site'] == 'YouTube') {
                trailers.add(trailer['key']);
              }
            }
          }
        }
      }
    } else {
      throw HttpException("Failed to get trailers for id=$id");
    }
    return trailers;
  }

  Future<List<Movie>> getRecommendations(String id, String mediaType) async {
    final url =
        '$baseUrl/$mediaType/$id/recommendations?api_key=$apiKey&language=de-DE';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw HttpException("Failed to load recommendations for id=$id");
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    final List<dynamic> results = jsonMap['results'];

    List<Movie> recommendedMovies = [];

    for (var result in results) {
      Movie movie = _movieFromTmdb(result, mediaType, 0, '', DateTime.now());
      recommendedMovies.add(movie);
    }

    return recommendedMovies;
  }

  Future getActor(Actor actor) async {
    final url = '$baseUrl/person/${actor.id}?api_key=$apiKey&language=de-DE';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      actor.biography = jsonMap['biography'] ?? '';
      actor.birthday = jsonMap['birthday'] != null
          ? DateTime.parse(jsonMap['birthday'])
          : null;
      actor.deathday = jsonMap['deathday'] != null
          ? DateTime.parse(jsonMap['deathday'])
          : null;
      return actor;
    } else {
      throw HttpException("Failed to load actor with id=${actor.id}");
    }
  }
}
