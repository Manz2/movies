import 'package:json_store/json_store.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/home/movie.dart';

class DbServiceLocal implements DbServiceInterface {
  final _jsonStore = JsonStore(dbName: 'movies');

  @override
  Future<List<Movie>> getMovies() async {
    List<Movie> movies = [];
    try {
      List<Map<String, dynamic>>? allItems =
          await _jsonStore.getListLike('movie_%');
      if (allItems == null) {
        print("no movies found locally");
        return movies;
      }
      for (var item in allItems) {
        movies.add(Movie.fromJson(item));
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return movies;
  }

  @override
  Future<void> setMovies(List<Movie> movies) async {
    try {
      await _jsonStore.deleteLike('movie_%');
      for (var movie in movies) {
        _jsonStore.setItem('movie_${movie.firebaseId}', movie.toJson(),
            encrypt: false);
      }
    } on Exception catch (e) {
      throw Exception('Error setting movies: $e');
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
  Future<Movie> addMovie(movie) async {
    _jsonStore.setItem('movie_${movie.firebaseId}', movie.toJson(),
        encrypt: false);
    return movie;
  }

  @override
  Future<void> removeMovie(Movie movie) async {
    _jsonStore.deleteItem('movie_${movie.firebaseId}');
  }

  @override
  Future<void> setMovie(Movie movie2) async {
    _jsonStore.setItem('movie_${movie2.firebaseId}', movie2.toJson(),
        encrypt: false);
  }

  @override
  Future<List<Movie>> syncMovies() {
    // TODO: implement syncMovies
    throw UnimplementedError();
  }
}
