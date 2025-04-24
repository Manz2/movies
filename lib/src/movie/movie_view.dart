import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie.controller.dart';
import 'package:movies/src/movie/movie_details_content.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/watchlist_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movies/src/home/home_view.dart';

class MovieView extends StatefulWidget {
  final Movie movie;
  final Providers providers;
  final List<String> trailers;

  static const routeName = '/movie_details';

  const MovieView({
    super.key,
    required this.movie,
    required this.providers,
    required this.trailers,
  });

  @override
  MovieViewState createState() => MovieViewState();
}

class MovieViewState extends State<MovieView> {
  late final MovieController controller;
  late final YoutubePlayerController _trailerController;
  bool _isFabVisible = false;
  double _fontSize = 16.0;
  bool _isPlayerReady = false;

  set rating(double rating) {
    controller.setRating(rating);
  }

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return;
    }

    controller = MovieController(
      uid: uid,
      movie: widget.movie,
      providers: widget.providers,
      trailers: widget.trailers,
    );
    _istSaved();
    _initTrailer();
    _loadFontSize();
  }

  _istSaved() async {
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

  _initTrailer() {
    if (controller.model.trailers.isNotEmpty) {
      _trailerController = YoutubePlayerController(
        initialVideoId: controller.model.trailers[0],
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          enableCaption: false,
          showLiveFullscreenButton: false,
        ),
      )..addListener(listener);
    } else {
      _trailerController = YoutubePlayerController(
        initialVideoId: 'no_trailer',
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          enableCaption: false,
          showLiveFullscreenButton: false,
        ),
      )..addListener(listener);
    }
  }

  void listener() {
    if (_isPlayerReady && mounted && !_trailerController.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _trailerController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _trailerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        _trailerController.pause();
      },
      onEnterFullScreen: () {
        _trailerController.play();
      },
      player: YoutubePlayer(
        controller: _trailerController,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {},
        bottomActions: const [
          ProgressBar(
            isExpanded: true,
            colors: ProgressBarColors(
              playedColor: Colors.blue,
              handleColor: Colors.blue,
              bufferedColor: Colors.white,
            ),
          ),
        ],
        topActions: const [],
      ),
      builder:
          (context, player) => Scaffold(
            floatingActionButton:
                _isFabVisible
                    ? FloatingActionButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext dialogContext) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                    _trailerController.pause();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MovieDetailsContent(
                        controller: controller,
                        fontSize: _fontSize,
                        isFabVisible: _isFabVisible,
                        onRatingChanged:
                            (rating) => setState(() => this.rating = rating),
                      ),
                      if (controller.model.trailers.isNotEmpty)
                        OrientationBuilder(
                          builder: (context, orientation) {
                            final isLandscape =
                                orientation == Orientation.landscape;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isLandscape) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    "Trailer:",
                                    style: TextStyle(fontSize: _fontSize),
                                  ),
                                  player,
                                ] else
                                  // nötig, damit Player geladen bleibt – aber unsichtbar
                                  Offstage(child: player),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
