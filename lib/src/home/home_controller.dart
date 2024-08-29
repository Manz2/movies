import 'package:flutter/material.dart';
import 'package:movies/src/db_service_local.dart';
import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();
  final _db = DbServiceLocal();

  HomeController() : _model = HomeModel(movies: []);

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    _model.movies = await _db.getMovies();
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
        _db.setMovies(_model.movies);
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
      _db.setMovies(_model.movies);
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
    _db.setMovies(_model.movies);
  }
}
