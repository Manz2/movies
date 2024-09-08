import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie.controller.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieView extends StatefulWidget {
  final Movie movie;
  final Providers providers;
  final List<String> trailers;

  static const routeName = '/movie_details';

  const MovieView(
      {super.key,
      required this.movie,
      required this.providers,
      required this.trailers});

  @override
  MovieViewState createState() => MovieViewState();
}

class MovieViewState extends State<MovieView> {
  late final MovieController controller;
  late final YoutubePlayerController _trailerController;
  bool _isFabVisible = false;
  double _fontSize = 16.0;
  bool _isPlayerReady = false;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;

  set rating(double rating) {
    controller.setRating(rating);
  }

  @override
  void initState() {
    super.initState();
    controller = MovieController(
        movie: widget.movie,
        providers: widget.providers,
        trailers: widget.trailers);
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

  _launchURL(String url2) async {
    final Uri url = Uri.parse(url2);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
      _videoMetaData = const YoutubeMetaData();
      _playerState = PlayerState.unknown;
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
      _videoMetaData = const YoutubeMetaData();
      _playerState = PlayerState.unknown;
    }
  }

  void listener() {
    if (_isPlayerReady && mounted && !_trailerController.value.isFullScreen) {
      setState(() {
        _playerState = _trailerController.value.playerState;
        _videoMetaData = _trailerController.metadata;
      });
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
          bottomActions: [
            ProgressBar(
                isExpanded: true,
                colors: const ProgressBarColors(
                    playedColor: Colors.blue,
                    handleColor: Colors.blue,
                    bufferedColor: Colors.white))
          ],
          topActions: const [],
        ),
        builder: (context, player) => Scaffold(
              floatingActionButton: _isFabVisible
                  ? FloatingActionButton(
                      onPressed: () async {
                        await controller.addMovie();
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
                                fontSize: _fontSize, controller: controller);
                          });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      controller.model.movie.image != ''
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: Image.network(
                                  controller.model.movie.image,
                                  height: 300,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const Padding(padding: EdgeInsets.all(16)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    controller.model.movie.title,
                                    style: TextStyle(
                                      fontSize: _fontSize + 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow
                                        .visible, // Kürzt den Text, wenn er zu lang ist
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        10), // Abstand zwischen Titel und Bild
                                controller.model.movie.fsk == '0' ||
                                        controller.model.movie.fsk == '6' ||
                                        controller.model.movie.fsk == '12' ||
                                        controller.model.movie.fsk == '16' ||
                                        controller.model.movie.fsk == '18'
                                    ? SizedBox(
                                        height: 30, // Höhe anpassen
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images/FSK${controller.model.movie.fsk}.png'),
                                          fit: BoxFit
                                              .contain, // Bild innerhalb des SizedBox skalieren
                                        ),
                                      )
                                    : const SizedBox(), // Leerraum, wenn FSK unbekannt
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(controller.model.movie.description,
                                style: TextStyle(fontSize: _fontSize)),
                            const SizedBox(height: 8),
                            Text("FSK: ${controller.model.movie.fsk}",
                                style: TextStyle(fontSize: _fontSize)),
                            const SizedBox(height: 8),
                            Text(
                                "Öffentliches Rating: ${controller.model.movie.rating}",
                                style: TextStyle(fontSize: _fontSize)),
                            const SizedBox(height: 8),
                            Text("Jahr: ${controller.model.movie.year}",
                                style: TextStyle(fontSize: _fontSize)),
                            const SizedBox(height: 8),
                            Text(
                                "Genre: ${controller.model.movie.genre.join(', ')}",
                                style: TextStyle(fontSize: _fontSize)),
                            const SizedBox(height: 8),
                            controller.model.movie.mediaType == 'movie'
                                ? Text(
                                    "Dauer: ${controller.model.movie.duration} Minuten",
                                    style: TextStyle(fontSize: _fontSize))
                                : Text(
                                    "Dauer: ${controller.model.movie.duration} Staffeln",
                                    style: TextStyle(fontSize: _fontSize)),
                            const SizedBox(height: 8),
                            !_isFabVisible
                                ? Text("Privates Rating: ",
                                    style: TextStyle(fontSize: _fontSize))
                                : const SizedBox(height: 0),
                            const SizedBox(height: 8),
                            !_isFabVisible
                                ? StarRating(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    size: 40.0,
                                    rating:
                                        controller.model.movie.privateRating,
                                    color: Colors.orange,
                                    borderColor: Colors.grey,
                                    allowHalfRating: true,
                                    starCount: 5,
                                    onRatingChanged: (rating) => setState(() {
                                      this.rating = rating;
                                    }),
                                  )
                                : const SizedBox(height: 0),
                            const SizedBox(height: 8),
                            Text("Anbieter:",
                                style: TextStyle(fontSize: _fontSize)),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: GestureDetector(
                                onTap: () async {
                                  _launchURL(controller.model.providers.link);
                                },
                                child: Row(
                                  children: [
                                    for (final provider
                                        in controller.model.providers.providers)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Image.network(
                                          provider.icon,
                                          height: 50,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            controller.model.trailers.isNotEmpty
                                ? Text("Trailer:",
                                    style: TextStyle(fontSize: _fontSize))
                                : const Text(""),
                            const SizedBox(height: 8),
                            controller.model.trailers.isNotEmpty
                                ? player
                                : const Text(""),
                            const SizedBox(height: 16),
                            Text("Schauspieler:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _fontSize)),
                            SizedBox(
                              height: 400,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: controller.model.movie.actors.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final actor =
                                      controller.model.movie.actors[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      foregroundImage: actor.image.isNotEmpty
                                          ? NetworkImage(actor.image)
                                          : const AssetImage(
                                              "assets/images/ActorPlaceholder.jpg"),
                                    ),
                                    title: Text(actor.name,
                                        style: TextStyle(fontSize: _fontSize)),
                                    subtitle: Text(actor.roleName,
                                        style:
                                            TextStyle(fontSize: _fontSize - 4)),
                                    onTap: () async {
                                      final movies =
                                          await controller.getMovies(actor.id);
                                      if (!context.mounted) return;
                                      Navigator.pushNamed(
                                        context,
                                        ActorView.routeName,
                                        arguments: ActorViewArguments(
                                            actor: actor,
                                            movies: movies,
                                            fontSize: _fontSize),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}

class WatchlistDialog extends StatelessWidget {
  const WatchlistDialog({
    super.key,
    required double fontSize,
    required this.controller,
  }) : _fontSize = fontSize;

  final double _fontSize;
  final MovieController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Zur Watchlist hinzufügen?',
          style: TextStyle(fontSize: _fontSize)),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final watchlist in controller.model.watchlists)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () async {
                      await controller.addMovieToWatchlist(watchlist, context);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 400,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                          child: Text(
                        watchlist.name,
                        style: TextStyle(fontSize: _fontSize),
                      )),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Abbrechen', style: TextStyle(fontSize: _fontSize)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('Neue Liste', style: TextStyle(fontSize: _fontSize)),
          onPressed: () async {
            Navigator.pop(context);
            TextEditingController textController = TextEditingController();
            await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Neue Watchlist erstellen?',
                        style: TextStyle(fontSize: _fontSize)),
                    content: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        labelText: 'Name der Watchlist',
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text('Abbrechen',
                            style: TextStyle(fontSize: _fontSize)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text('Erstellen',
                            style: TextStyle(fontSize: _fontSize)),
                        onPressed: () async {
                          await controller.addWatchlist(textController.text);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return WatchlistDialog(
                                    fontSize: _fontSize,
                                    controller: controller);
                              });
                        },
                      ),
                    ],
                  );
                });
          },
        ),
      ],
    );
  }
}
