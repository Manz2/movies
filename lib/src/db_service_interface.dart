import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/home/movie.dart';

abstract class DbServiceInterface {
  Future<void> initializeUserData();
  Future<List<Movie>> getMovies();
  Future<void> setMovies(List<Movie> movies);
  Future<Movie> getMovie(String id, String mediaType);
  Future<Movie> addMovie(Movie movie);
  Future<void> removeMovie(Movie movie);
  Future<void> setMovie(Movie movie2);
  Future<List<Movie>> syncMovies();
  Future<List<Watchlist>> getWatchlists();
  Future<Watchlist> addWatchlist(String name);
  Future<void> removeWatchlist(String id);
  Future<Watchlist> addMovieToWatchlist(Watchlist watchlist, Movie movie);
  Future<void> removeMovieFromWatchlist(Watchlist watchlist, Entry entry);
  Future<Watchlist> getWatchlistMovies(String id);
  Future<Watchlist> setWatchlist(Watchlist watchlist);
  Future<void> setNotification(Movie movie, String token, List<String> providers);
  Future<void> removeNotification(String token, Movie movie);
  Future<void> removeAllNotifications(String token);
  Future<bool> isNotificationSet(String token, Movie movie);
}
