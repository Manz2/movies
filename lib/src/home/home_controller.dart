import 'package:flutter/material.dart';
import 'package:json_store/json_store.dart';
import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();
  final _jsonStore = JsonStore(dbName: 'movies');

  HomeController() : _model = HomeModel(movies: []);

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    //await _jsonStore.clearDataBase();
    Map<String, dynamic>? storedData = await _jsonStore.getItem('movies');

    if (storedData != null && storedData.containsKey('movies')) {
      List<dynamic> moviesJson = storedData['movies'];

      // JSON-Liste in Movie-Objekte konvertieren
      _model.movies = moviesJson.map((json) => Movie.fromJson(json)).toList();
    } else {
      _model.movies = [];
    }
  }

  Future<Movie> getMovieWithCredits(Movie movie) async {
    try {
      return await tmdbService.getMovieWithCredits(
          int.parse(movie.id), movie.mediaType);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
      return testMovie; //Fehlerbehandlung
    }
  }

  Future<void> addMovie(BuildContext context) async {
    final TextEditingController textController = TextEditingController();
    bool cancel = false;
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Film hinzufügern'),
            content: TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: "Film Id eingeben"),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  cancel = true;
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  Navigator.pop(context, textController.text);
                },
              ),
            ],
          );
        });

    if (!cancel) {
      try {
        Movie movie = await tmdbService.getMovie(int.parse(result), 'movie');
        _model.addMovie(movie);
        List<Map<String, dynamic>> moviesJson =
            _model.movies.map((m) => m.toJson()).toList();
        await _jsonStore.setItem('movies', {'movies': moviesJson},
            encrypt: false);
      } on Exception catch (e) {
        print(e.toString());
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Film mit der id $result existiert nicht"),
          ),
        );
      }
    }
  }

  addMovieWithId(BuildContext context, String id, String mediaType) async {
    try {
      Movie movie = await tmdbService.getMovie(int.parse(id), 'movie');
      _model.addMovie(movie);
    } on Exception catch (e) {
      print(e.toString());
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Film mit der id $id konnte nicht hinzugefügt werden"),
        ),
      );
    }
  }

  Future<void> removeMovie(Movie movie) async {
    _model.removeMovie(movie);
    List<Map<String, dynamic>> moviesJson =
        _model.movies.map((m) => m.toJson()).toList();
    await _jsonStore.setItem('movies', {'movies': moviesJson}, encrypt: false);
  }
}
