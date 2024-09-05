import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/home/movie.dart';
import 'package:firebase_database/firebase_database.dart';

class DbServiceFirebase implements DbServiceInterface {
  final databaseRef =
      FirebaseDatabase.instance.ref().child("movies/"); // Database reference
  final databaseRefWatchlist =
      FirebaseDatabase.instance.ref().child("watchlists/");
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

  @override
  Future<Watchlist> addMovieToWatchlist(
      Watchlist watchlist, Movie movie) async {
    String? newPostKey = databaseRefWatchlist
        .child(watchlist.id)
        .child('entries')
        .child('posts')
        .push()
        .key;
    Entry entry = Entry(
        name: movie.title,
        id: movie.id,
        type: movie.mediaType,
        firebaseId: newPostKey!,
        image: movie.image);
    watchlist.entries.add(entry);
    try {
      await databaseRefWatchlist
          .child(watchlist.id)
          .child('entries')
          .child(newPostKey)
          .update(entry.toJson());
      return watchlist;
    } catch (e) {
      throw Exception("Error adding movie to Watchlist: $e");
    }
  }

  @override
  Future<Watchlist> addWatchlist(String name) async {
    try {
      String? newPostKey = databaseRefWatchlist.child('posts').push().key;
      Watchlist watchlist = Watchlist(entries: [], name: name, id: newPostKey!);
      await databaseRefWatchlist.child(newPostKey).update(watchlist.toJson());
      logger.d("created Watchlist with id:$newPostKey");
      return watchlist;
    } catch (e) {
      throw Exception("Error creating Watchlist: $e");
    }
  }

  @override
  Future<Watchlist> getWatchlistMovies(String id) async {
    return await databaseRefWatchlist
        .child(id)
        .child('entries')
        .get()
        .then((value) {
      return Watchlist.fromJson(jsonDecode(jsonEncode(value.value)));
    });
  }

  @override
  Future<List<Watchlist>> getWatchlists() async {
    List<Watchlist> watchlists = [];
    final DataSnapshot snapshot = await databaseRefWatchlist.get();
    if (snapshot.exists) {
      for (DataSnapshot element in snapshot.children) {
        watchlists
            .add(Watchlist.fromJson(jsonDecode(jsonEncode(element.value))));
      }
      return watchlists;
    } else {
      logger.d("No data available in the database");
      return watchlists;
    }
  }

  @override
  Future<void> removeMovieFromWatchlist(
      Watchlist watchlist, Entry entry) async {
    try {
      await databaseRefWatchlist
          .child(watchlist.id)
          .child('entries')
          .child(entry.firebaseId)
          .remove();
    } on Exception catch (e) {
      throw Exception("Error removing entry: $e");
    }
  }

  @override
  Future<void> removeWatchlist(String id) async {
    try {
      await databaseRefWatchlist.child(id).remove();
    } on Exception catch (e) {
      throw Exception("Error removing entry: $e");
    }
  }
}
