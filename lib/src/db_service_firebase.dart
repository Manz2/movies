import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/home/movie.dart';
import 'package:firebase_database/firebase_database.dart';

class DbServiceFirebase implements DbServiceInterface {
  final databaseRef =
      FirebaseDatabase.instance.ref().child("movies/"); // Database reference
  Logger logger = Logger();
  @override
  Future<Movie> addMovie(Movie movie) async {
    try {
      final newPostKey = databaseRef.child('posts').push().key;
      await databaseRef.child(newPostKey!).update(movie.toJson());
      logger.d("created recipe with id:$newPostKey");
      await databaseRef.child(newPostKey).update({"firebaseId": newPostKey});
      Movie movie2 = await databaseRef.child(newPostKey).get().then((value) {
        return Movie.fromJson(jsonDecode(jsonEncode(value.value)));
      });
      return movie2;
    } on Exception catch (e) {
      throw Exception("Error creating movie: $e");
    }
  }

  @override
  Future<Movie> getMovie(String id, String mediaType) async {
    List<Movie> movies = await getMovies();

    for (Movie movie in movies) {
      if (movie.id == id && movie.mediaType == mediaType) {
        return movie;
      }
    }
    return Movie(
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
        firebaseId: '');
  }

  @override
  Future<List<Movie>> getMovies() async {
    List<Movie> movies = [];
    final DataSnapshot snapshot = await databaseRef.get();
    if (snapshot.exists) {
      for (DataSnapshot element in snapshot.children) {
        movies.add(Movie.fromJson(jsonDecode(jsonEncode(element.value))));
      }
      return movies;
    } else {
      logger.d("No data available in the database");
      return movies;
    }
  }

  @override
  Future<void> removeMovie(Movie movie) async {
    try {
      await databaseRef.child(movie.firebaseId).remove();
    } on Exception catch (e) {
      throw Exception("Error removing movie: $e");
    }
  }

  @override
  Future<void> setMovie(Movie movie2) async {
    if (databaseRef.child(movie2.firebaseId).key == null) {
      throw Exception("Movie does not exist in database");
    }
    try {
      await databaseRef.child(movie2.firebaseId).update(movie2.toJson());
    } on Exception catch (e) {
      throw Exception("Error updating movie: $e");
    }
  }

  @override
  Future<void> setMovies(List<Movie> movies) async {
    for (Movie movie in movies) {
      await setMovie(movie);
    }
  }

  @override
  Future<List<Movie>> syncMovies() {
    // TODO: implement syncMovies
    throw UnimplementedError();
  }
}
