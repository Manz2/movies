import 'package:json_store/json_store.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/home/movie.dart';

class DbServiceLocal implements DbServiceInterface {
  final _jsonStore = JsonStore(dbName: 'movies');
  Logger logger = Logger();

  @override
  Future<List<Movie>> getMovies() async {
    List<Movie> movies = [];
    try {
      List<Map<String, dynamic>>? allItems = await _jsonStore.getListLike(
        'movie_%',
      );
      if (allItems == null) {
        logger.d('No movies found');
        return movies;
      }
      for (var item in allItems) {
        movies.add(Movie.fromJson(item));
      }
    } on Exception catch (e) {
      logger.e('Error getting movies: $e');
    }
    return movies;
  }

  @override
  Future<void> setMovies(List<Movie> movies) async {
    try {
      await _jsonStore.deleteLike('movie_%');
      for (var movie in movies) {
        _jsonStore.setItem(
          'movie_${movie.firebaseId}',
          movie.toJson(),
          encrypt: false,
        );
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
      orElse:
          () => Movie(
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
            firebaseId: '',
            addedAt: DateTime.now(),
          ),
    );
  }

  @override
  Future<Movie> addMovie(movie) async {
    _jsonStore.setItem(
      'movie_${movie.firebaseId}',
      movie.toJson(),
      encrypt: false,
    );
    return movie;
  }

  @override
  Future<void> removeMovie(Movie movie) async {
    _jsonStore.deleteItem('movie_${movie.firebaseId}');
  }

  @override
  Future<void> setMovie(Movie movie2) async {
    _jsonStore.setItem(
      'movie_${movie2.firebaseId}',
      movie2.toJson(),
      encrypt: false,
    );
  }

  @override
  Future<List<Movie>> syncMovies() {
    throw UnimplementedError();
  }

  @override
  Future<Watchlist> addMovieToWatchlist(Watchlist watchlist, Movie movie) {
    throw UnimplementedError();
  }

  @override
  Future<Watchlist> addWatchlist(String name) {
    throw UnimplementedError();
  }

  @override
  Future<Watchlist> getWatchlistMovies(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Watchlist>> getWatchlists() {
    throw UnimplementedError();
  }

  @override
  Future<void> removeMovieFromWatchlist(Watchlist watchlist, Entry entry) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeWatchlist(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Watchlist> setWatchlist(Watchlist watchlist) {
    throw UnimplementedError();
  }

  @override
  Future<void> initializeUserData() {
    throw UnimplementedError();
  }
  
  @override
  Future<void> setNotification(Movie movie, String token, List<String> providers) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> removeAllNotifications(String token) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> removeNotification(String token, Movie movie) {
    throw UnimplementedError();
  }
  
  @override
  Future<bool> isNotificationSet(String token, Movie movie) {
    throw UnimplementedError();
  }
}
