import 'package:movies/src/db_service_firebase.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/db_service_local.dart';
import 'package:movies/src/home/movie.dart';

class DbCombinator implements DbServiceInterface {
  final DbServiceInterface _dbServiceLocal = DbServiceLocal();
  final DbServiceInterface _dbServiceFirebase = DbServiceFirebase();

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
    _dbServiceLocal.setMovies(movies);
    return movies;
  }

  
}
