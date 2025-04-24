import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_service_firebase.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/db_service_local.dart';
import 'package:movies/src/home/movie.dart';

class DbCombinator implements DbServiceInterface {
  final String uid;
  final DbServiceInterface _dbServiceLocal = DbServiceLocal();
  late final DbServiceInterface _dbServiceFirebase;

  DbCombinator({required this.uid}) {
    _dbServiceFirebase = DbServiceFirebase(uid);
  }

  @override
  Future<Movie> addMovie(Movie movie) async {
    Movie m = await _dbServiceFirebase.addMovie(movie);
    await _dbServiceLocal.addMovie(m);
    return m;
  }

  @override
  Future<Movie> getMovie(String id, String mediaType) async {
    return _dbServiceLocal.getMovie(id, mediaType);
  }

  @override
  Future<List<Movie>> getMovies() async {
    return await _dbServiceLocal.getMovies();
  }

  @override
  Future<void> removeMovie(Movie movie) async {
    await _dbServiceLocal.removeMovie(movie);
    await _dbServiceFirebase.removeMovie(movie);
  }

  @override
  Future<void> setMovie(Movie movie2) async {
    await _dbServiceFirebase.setMovie(movie2);
    await _dbServiceLocal.setMovie(movie2);
  }

  @override
  Future<void> setMovies(List<Movie> movies) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> syncMovies() async {
    List<Movie> movies = await _dbServiceFirebase.getMovies();
    await _dbServiceLocal.setMovies(movies);
    return movies;
  }

  @override
  Future<Watchlist> addMovieToWatchlist(
    Watchlist watchlist,
    Movie movie,
  ) async {
    return await _dbServiceFirebase.addMovieToWatchlist(watchlist, movie);
  }

  @override
  Future<Watchlist> addWatchlist(String name) async {
    return await _dbServiceFirebase.addWatchlist(name);
  }

  @override
  Future<Watchlist> getWatchlistMovies(String id) async {
    return await _dbServiceFirebase.getWatchlistMovies(id);
  }

  @override
  Future<List<Watchlist>> getWatchlists() async {
    return await _dbServiceFirebase.getWatchlists();
  }

  @override
  Future<void> removeMovieFromWatchlist(
    Watchlist watchlist,
    Entry entry,
  ) async {
    await _dbServiceFirebase.removeMovieFromWatchlist(watchlist, entry);
  }

  @override
  Future<void> removeWatchlist(String id) async {
    await _dbServiceFirebase.removeWatchlist(id);
  }

  @override
  Future<Watchlist> setWatchlist(Watchlist watchlist) async {
    return await _dbServiceFirebase.setWatchlist(watchlist);
  }

  @override
  Future<void> initializeUserData() async {
    await _dbServiceFirebase.initializeUserData();
  }
}
