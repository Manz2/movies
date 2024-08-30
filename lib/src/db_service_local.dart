import 'package:json_store/json_store.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/home/movie.dart';

class DbServiceLocal implements DbServiceInterface {
  final _jsonStore = JsonStore(dbName: 'movies');

  @override
  Future<List<Movie>> getMovies() async {
    //await _jsonStore.clearDataBase();
    Map<String, dynamic>? storedData = await _jsonStore.getItem('movies');

    if (storedData != null && storedData.containsKey('movies')) {
      List<dynamic> moviesJson = storedData['movies'];

      // JSON-Liste in Movie-Objekte konvertieren
      return moviesJson.map((json) => Movie.fromJson(json)).toList();
    } else {
      print("unable to get Movies from db");
      return [];
    }
  }

  @override
  Future<void> setMovies(List<Movie> movies) async {
    try {
      List<Map<String, dynamic>> moviesJson =
          movies.map((m) => m.toJson()).toList();
      await _jsonStore.setItem('movies', {'movies': moviesJson},
          encrypt: false);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<Movie> getMovie(String id, String mediaType) async {
    List<Movie> movies = await getMovies();
    return movies.firstWhere(
      (movie) => movie.id == id && movie.mediaType == mediaType,
      orElse: () => Movie(
          id: id,
          title: "title",
          description: "description",
          fsk: "fsk",
          rating: 1,
          year: 1,
          duration: 1,
          image: "image",
          actors: [],
          genre: [],
          popularity: 1,
          mediaType: mediaType,
          privateRating: 0,
          firebaseId: ''),
    );
  }

  @override
  Future<void> addMovie(movie) async {
    List<Movie> movies = await getMovies();
    movies.add(movie);
    await setMovies(movies);
  }

  @override
  Future<void> removeMovie(Movie movie) async {
    List<Movie> movies = await getMovies();
    movies
        .removeWhere((m) => m.id == movie.id && m.mediaType == movie.mediaType);
    await setMovies(movies);
  }

  @override
  Future<void> setMovie(Movie movie2) async {
    List<Movie> movies = await getMovies();

    // Den Index des Films finden, der ersetzt werden soll
    int index = movies.indexWhere(
      (movie) => movie.id == movie2.id && movie.mediaType == movie2.mediaType,
    );

    if (index == -1) {
      throw Exception('Movie not found');
    }

    // Den Film ersetzen
    movies[index] = movie2;

    // Falls notwendig, speichere die geänderte Liste zurück
    await setMovies(movies);
  }

  @override
  Future<bool> movieExists(String id, String mediaType) async {
    List<Movie> movies = await getMovies();
    return movies
        .any((movie) => movie.id == id && movie.mediaType == mediaType);
  }
}
