import 'package:flutter/material.dart';
import 'package:movies/src/Watchlist/watchlist_controller.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistView extends StatefulWidget {
  static const routeName = '/watchlist';
  final Watchlist currentWatchlist;

  const WatchlistView({super.key, required this.currentWatchlist});

  @override
  State<StatefulWidget> createState() => WatchlistViewState();
}

class WatchlistViewState extends State<WatchlistView> {
  late final WatchlistController controller;
  double _fontSize = 16.0;

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('font_size') ?? 16.0; // Standardwert
    });
  }

  @override
  void initState() {
    controller = WatchlistController(currentWatchlist: widget.currentWatchlist);
    setState(() {});
    _loadFontSize();
    super.initState();
  }

  _loadState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.model.currentWatchlist.name),
        actions: [
          Text(controller.model.currentWatchlist.entries.length.toString(),
              style: TextStyle(fontSize: _fontSize)),
          IconButton(
              onPressed: () async {
                await controller.getWatchlists();
                if (!context.mounted) return;
                await showDialog(
                    context: context,
                    builder: (context) {
                      return WatchlistDialog(
                          fontSize: _fontSize,
                          controller: controller,
                          function: _loadState);
                    }).then((_) {
                  _loadState();
                });
              },
              icon: const Icon(Icons.remove_red_eye_rounded)),
          (controller.model.currentWatchlist.id != '')
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Watchlist löschen',
                                style: TextStyle(fontSize: _fontSize)),
                            content: Text(
                              "Möchten Sie ${controller.model.currentWatchlist.name} wirklich löschen?",
                              style: TextStyle(fontSize: _fontSize),
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
                                child: Text('Löschen',
                                    style: TextStyle(fontSize: _fontSize)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller.removeWatchlist(
                                      controller.model.currentWatchlist);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "${controller.model.currentWatchlist.name} wurde gelöscht"),
                                    action: SnackBarAction(
                                        label: "undo",
                                        onPressed: () async => {
                                              await controller.addWatchlist(
                                                  controller
                                                      .model.currentWatchlist),
                                            }),
                                  ));
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  })
              : const Text("")
        ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getMoviesForCurrentWatchlist(
                controller.model.currentWatchlist);
            setState(() {});
          },
          child: ListView.builder(
            restorationId: 'sampleItemListView',
            itemCount: controller.model.currentWatchlist.entries.length,
            itemBuilder: (BuildContext context, int index) {
              final item = controller.model.currentWatchlist.entries[index];

              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Dismissible(
                  key: Key(item.id),
                  onDismissed: (direction) async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext dialogContext) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    await controller.removeMovieFromWatchlist(item);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    setState(() {});
                    String title = item.name;
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$title wurde gelöscht"),
                      action: SnackBarAction(
                          label: "undo",
                          onPressed: () async => {
                                await controller.addMovieToWatchlist(item),
                                setState(() {})
                              }),
                    ));
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                      title: Text(item.name,
                          style: TextStyle(fontSize: _fontSize + 2)),
                      leading: CircleAvatar(
                        radius: 35,
                        foregroundImage: item.image.isNotEmpty
                            ? NetworkImage(item.image)
                            : const AssetImage(
                                "assets/images/moviePlaceholder.png"),
                      ),
                      onTap: () async {
                        Movie movie = await controller.getMovie(item);
                        Providers providers =
                            await controller.getProviders(item);
                        List<String> trailers =
                            await controller.getTrailers(item);
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, MovieView.routeName,
                                arguments: MovieViewArguments(
                                    movie: movie,
                                    providers: providers,
                                    trailers: trailers))
                            .then((val) => _loadMovies());
                      }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _loadMovies() async {
    await controller
        .getMoviesForCurrentWatchlist(controller.model.currentWatchlist);
    setState(() {});
  }
}

class WatchlistDialog extends StatelessWidget {
  const WatchlistDialog({
    super.key,
    required double fontSize,
    required this.controller,
    required this.function,
  }) : _fontSize = fontSize;

  final Function() function;

  final double _fontSize;
  final WatchlistController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Watchlist auswählen', style: TextStyle(fontSize: _fontSize)),
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
                      await controller.changeWatchlist(watchlist);
                      if (!context.mounted) return;
                      function();
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
                          await controller.addNewWatchlist(textController.text);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return WatchlistDialog(
                                    fontSize: _fontSize,
                                    controller: controller,
                                    function: function);
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
