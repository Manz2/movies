import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/db_service_interface.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/test_movie.dart';

class DbServiceFirebase implements DbServiceInterface {
  final String uid;
  DbServiceFirebase(this.uid);

  Logger logger = Logger();

  DatabaseReference get userRef =>
      FirebaseDatabase.instance.ref().child("users").child(uid);
  DatabaseReference get movieRef => userRef.child("movies");
  DatabaseReference get watchlistRef => userRef.child("watchlists");
  DatabaseReference get junkRef => userRef.child("junk");
  DatabaseReference get notificationRef => userRef.child("notifications");
  DatabaseReference get providersRef => userRef.child("providers");

  @override
  Future<void> initializeUserData() async {
    try {
      await userRef.set({
        "movies": {},
        "watchlists": {},
        "junk": {},
        "notifications": {},
      });
      logger.d("Initialized user data for UID: $uid");
    } catch (e) {
      throw Exception("Error initializing user data: $e");
    }
  }

  @override
  Future<Movie> addMovie(Movie movie) async {
    try {
      final newPostKey = movieRef.push().key;
      await movieRef.child(newPostKey!).update(movie.toJson());
      await movieRef.child(newPostKey).update({"firebaseId": newPostKey});
      final snapshot = await movieRef.child(newPostKey).get();
      return Movie.fromJson(jsonDecode(jsonEncode(snapshot.value)));
    } catch (e) {
      throw Exception("Error creating movie: $e");
    }
  }

  @override
  Future<Movie> getMovie(String id, String mediaType) async {
    final movies = await getMovies();
    return movies.firstWhere(
      (m) => m.id == id && m.mediaType == mediaType,
      orElse: () => Movie(
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
        director: testActor1,
      ),
    );
  }

  @override
  Future<List<Movie>> getMovies() async {
    final snapshot = await movieRef.get();
    if (snapshot.exists) {
      return snapshot.children.map((e) {
        return Movie.fromJson(jsonDecode(jsonEncode(e.value)));
      }).toList();
    } else {
      logger.d("No data available in the database");
      return [];
    }
  }

  @override
  Future<void> removeMovie(Movie movie) async {
    try {
      await movieRef.child(movie.firebaseId).remove();
      final newPostKey = junkRef.child('deleted').push().key;
      await junkRef.child('deleted').child(newPostKey!).update(movie.toJson());
    } catch (e) {
      throw Exception("Error removing movie: $e");
    }
  }

  @override
  Future<void> setMovie(Movie movie) async {
    if (movie.firebaseId.isEmpty) {
      throw Exception("Movie does not have a Firebase ID");
    }
    try {
      await movieRef.child(movie.firebaseId).update(movie.toJson());
    } catch (e) {
      throw Exception("Error updating movie: $e");
    }
  }

  @override
  Future<void> setMovies(List<Movie> movies) async {
    for (var movie in movies) {
      await setMovie(movie);
    }
  }

  @override
  Future<List<Movie>> syncMovies() {
    throw UnimplementedError();
  }

  @override
  Future<Watchlist> addMovieToWatchlist(
    Watchlist watchlist,
    Movie movie,
  ) async {
    final newPostKey = watchlistRef
        .child(watchlist.id)
        .child('entries')
        .push()
        .key;
    final entry = Entry(
      name: movie.title,
      id: movie.id,
      type: movie.mediaType,
      firebaseId: newPostKey!,
      image: movie.image,
      addedAt: DateTime.now(),
    );
    watchlist.entries.add(entry);
    try {
      await watchlistRef
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
    final newPostKey = watchlistRef.push().key;
    final watchlist = Watchlist(entries: [], name: name, id: newPostKey!);
    try {
      await watchlistRef.child(newPostKey).update(watchlist.toJson());
      logger.d("created Watchlist with id:$newPostKey");
      return watchlist;
    } catch (e) {
      throw Exception("Error creating Watchlist: $e");
    }
  }

  @override
  Future<Watchlist> getWatchlistMovies(String id) async {
    final snapshot = await watchlistRef.child(id).get();
    final watchlist = Watchlist.fromJson(
      jsonDecode(jsonEncode(snapshot.value)),
    );
    watchlist.entries.sort((a, b) => b.addedAt.compareTo(a.addedAt));

    return watchlist;
  }

  @override
  Future<List<Watchlist>> getWatchlists() async {
    try {
      final snapshot = await watchlistRef.get();
      if (snapshot.exists) {
        return snapshot.children.map((e) {
          return Watchlist.fromJson(jsonDecode(jsonEncode(e.value)));
        }).toList();
      } else {
        logger.d("No data available in the database");
        return [];
      }
    } catch (e) {
      logger.e("Error fetching watchlists: $e");
      return [];
    }
  }

  @override
  Future<void> removeMovieFromWatchlist(
    Watchlist watchlist,
    Entry entry,
  ) async {
    try {
      await watchlistRef
          .child(watchlist.id)
          .child('entries')
          .child(entry.firebaseId)
          .remove();
    } catch (e) {
      throw Exception("Error removing entry: $e");
    }
  }

  @override
  Future<void> removeWatchlist(String id) async {
    try {
      await watchlistRef.child(id).remove();
    } catch (e) {
      throw Exception("Error removing watchlist: $e");
    }
  }

  @override
  Future<Watchlist> setWatchlist(Watchlist watchlist2) async {
    final newPostKey = watchlistRef.push().key;
    final watchlist = Watchlist(
      entries: [],
      name: watchlist2.name,
      id: newPostKey!,
    );
    try {
      await watchlistRef.child(newPostKey).update(watchlist.toJson());
      for (var entry in watchlist2.entries) {
        await addMovieToWatchlist(
          watchlist,
          await getMovie(entry.id, entry.type),
        );
      }
      return watchlist;
    } catch (e) {
      throw Exception("Error creating Watchlist: $e");
    }
  }

  Future<List<Movie>> removeDuplicates() async {
    final movies = await getMovies();
    final seen = <String>{};
    final duplicates = <Movie>[];

    for (final movie in movies) {
      final key = '${movie.id}_${movie.mediaType}';
      if (seen.contains(key)) {
        duplicates.add(movie);
      } else {
        seen.add(key);
      }
    }

    for (final movie in duplicates) {
      await movieRef.child(movie.firebaseId).remove();
      logger.f("Removed duplicate: ${movie.title}");
      final newPostKey = junkRef.child('doubles').push().key;
      await junkRef.child('doubles').child(newPostKey!).update(movie.toJson());
    }

    return duplicates;
  }

  @override
  Future<void> setNotification(
    Movie movie,
    String token,
    List<String> providers,
  ) async {
    try {
      final notificationData = {
        'title': movie.title,
        'addedAt': DateTime.now().toIso8601String(),
        'mediaType': movie.mediaType,
        'providers': providers,
        'id': movie.id,
      };
      await notificationRef
          .child(token)
          .child(_notificationKey(movie))
          .set(notificationData);
    } catch (e) {
      throw Exception("Error setting notification: $e");
    }
  }

  String _notificationKey(Movie movie) {
    final key = '${movie.id}_${movie.mediaType}';
    return key;
  }

  @override
  Future<void> removeAllNotifications(String token) async {
    try {
      await notificationRef.child(token).remove();
    } catch (e) {
      throw Exception("Error removing all notifications for token $token: $e");
    }
  }

  @override
  Future<void> removeNotification(String token, Movie movie) async {
    try {
      await notificationRef
          .child(token)
          .child(_notificationKey(movie))
          .remove();
    } catch (e) {
      throw Exception("Error removing notification: $e");
    }
  }

  @override
  Future<bool> isNotificationSet(String token, Movie movie) async {
    try {
      final snapshot = await notificationRef
          .child(token)
          .child(_notificationKey(movie))
          .get();
      return snapshot.exists;
    } catch (e) {
      throw Exception("Error checking notification: $e");
    }
  }
}
