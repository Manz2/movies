import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/home/home_view.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie.controller.dart';
import 'package:movies/src/movie/movie_details_content.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/movie/watchlist_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieViewWithoutAutoplay extends StatefulWidget {
  final Movie movie;
  final Providers providers;
  final List<String> trailers;
  final List<Movie> recommendations;

  static const routeName = '/movie_details';

  const MovieViewWithoutAutoplay({
    super.key,
    required this.movie,
    required this.providers,
    required this.trailers,
    required this.recommendations,
  });

  @override
  MovieViewState createState() => MovieViewState();
}

class MovieViewState extends State<MovieViewWithoutAutoplay> {
  late final MovieController controller;
  bool _isFabVisible = false;
  double _fontSize = 16.0;

  set rating(double rating) {
    controller.setRating(rating);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orientation = MediaQuery.of(context).orientation;

      if (widget.trailers.isNotEmpty && orientation != Orientation.landscape) {
        Navigator.of(context).pushReplacementNamed(
          MovieView.routeName,
          arguments: MovieViewArguments(
            movie: widget.movie,
            providers: widget.providers,
            trailers: widget.trailers,
            recommendations: widget.recommendations,
            autoplay: true,
          ),
        );
      }
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return;
    }

    controller = MovieController(
      uid: uid,
      movie: widget.movie,
      providers: widget.providers,
      trailers: widget.trailers,
      recommendations: widget.recommendations,
    );
    _istSaved();
    _loadFontSize();
  }

  void _istSaved() async {
    _isFabVisible = !await controller.isSaved();
    setState(() {});
  }

  void _toggleFabVisibility() {
    setState(() {
      _isFabVisible = !_isFabVisible;
    });
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('font_size') ?? 16.0; // Standardwert
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );
                await controller.addMovie();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                _toggleFabVisibility();
              },
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        title: Text(controller.model.movie.title),
        actions: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  controller.notificationSet
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: controller.notificationSet
                      ? Theme.of(context)
                            .colorScheme
                            .primary // z. B. Blau
                      : null, // Standard Icon-Farbe
                ),
                onPressed: () async {
                  await controller.toggleNotification();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        controller.notificationSet
                            ? 'Benachrichtigung gesetzt!'
                            : 'Benachrichtigung entfernt!',
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_rounded),
            onPressed: () async {
              await controller.getWatchlists();
              if (!context.mounted) return;
              await showDialog(
                context: context,
                builder: (context) {
                  return WatchlistDialog(
                    fontSize: _fontSize,
                    controller: controller,
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeView.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: MovieDetailsContent(
          controller: controller,
          fontSize: _fontSize,
          isFabVisible: _isFabVisible,
          onRatingChanged: (rating) => setState(() => this.rating = rating),
        ),
      ),
    );
  }
}
