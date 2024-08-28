import 'package:flutter/material.dart';
import 'package:movies/src/home/home_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';
import 'package:movies/src/tmdb_service.dart';

class HomeController {
  final HomeModel _model;
  final TmdbService tmdbService = TmdbService();

  HomeController() : _model = HomeModel(movies: []);

  HomeModel get model => _model;

  Future<void> loadMovies() async {
    try {
      Movie movie = await tmdbService.getMovie(268, 'movie');
      _model.addMovie(movie);
      Movie movie2 = await tmdbService.getMovie(98, 'movie');
      _model.addMovie(movie2);
      Movie movie3 = await tmdbService.getMovie(13, 'movie');
      _model.addMovie(movie3);
    } on Exception catch (e) {
      print('Fehler beim Laden des Films: $e');
    }
  }

  Future<Movie> getMovieWithCredits(String id, String mediaType) async {
    try {
      return await tmdbService.getMovieWithCredits(int.parse(id), mediaType);
    } on Exception catch (e) {
      return testMovie; //Fehlerbehandlung
      print('Fehler beim Laden des Films: $e');
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
      } on Exception catch (e) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Film mit der id $id konnte nicht hinzugefügt werden"),
        ),
      );
    }
  }

  void removeMovie(Movie movie) {
    _model.removeMovie(movie);
  }
}
