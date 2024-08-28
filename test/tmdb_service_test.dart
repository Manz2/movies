// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/to/unit-testing

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/src/tmdb_service.dart';

void main() {
 group('Tmdb Service', () {
    test('should get the Batman Movie', () async {
      // ID 268 wird als Beispiel für den Film "Batman" verwendet.
      final tmdbService = TmdbService();
      final movie = await tmdbService.getMovie(268,'movie');
      // Überprüfe, ob der Titel des Films "Batman" ist
      expect(movie.title, 'Batman');
      // Weitere Tests können hinzugefügt werden, z.B. ob die ID stimmt
      expect(movie.id, '268');
      expect(movie.actors.length, 0);
    });

    test('should get the Batman Movie with credits', () async {
      // ID 268 wird als Beispiel für den Film "Batman" verwendet.
      final tmdbService = TmdbService();
      final movie = await tmdbService.getMovieWithCredits(268,'movie');
      // Überprüfe, ob der Titel des Films "Batman" ist
      expect(movie.title, 'Batman');
      // Weitere Tests können hinzugefügt werden, z.B. ob die ID stimmt
      expect(movie.id, '268');
      expect(movie.fsk, '12');
      expect(movie.actors.length, isNot(0));
    });

    test('should return combinded Credits credits', () async {
      // ID 268 wird als Beispiel für den Film "Batman" verwendet.
      final tmdbService = TmdbService();
      final movies = await tmdbService.getCombinedCredits(13);
      // Überprüfe, ob der Titel des Films "Batman" ist
      expect(movies.length, isNot(0));
    });
  });
}