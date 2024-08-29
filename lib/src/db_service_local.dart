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
}
