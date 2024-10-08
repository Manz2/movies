import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/Filter/filter_model.dart';
import 'package:movies/src/Filter/filter_view.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/Watchlist/watchlist_view.dart';
import 'package:movies/src/home/home_controller.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/search/search_view.dart';
import 'package:movies/src/settings/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const routeName = '/';

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final HomeController _controller = HomeController();
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
    _loadMovies();
    _syncMovies();
  }

  void _syncMovies() async {
    await _controller.syncMovies();
    setState(() {});
  }

  void _loadMovies() async {
    await _controller.loadMovies();
    _loadFontSize();
    setState(() {}); // Aktualisiert die UI nach dem Laden der Filme
  }

  void _applyFilter(Filter filter) {
    _controller.model.filter = filter;
    _loadMovies();
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
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          Text(_controller.model.movies.length.toString(),
              style: TextStyle(fontSize: _fontSize)),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_rounded),
            onPressed: () async {
              Watchlist watchlist = await _controller.getCurrentWatchlist();
              if (!context.mounted) return;
              Navigator.pushNamed(context, WatchlistView.routeName,
                      arguments: watchlist)
                  .then((val) => _loadMovies());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsView.routeName)
                  .then((val) => _loadMovies());
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              Navigator.pushNamed(context, FilterView.routeName,
                      arguments: _controller.model.filter)
                  .then((filter) => _applyFilter(filter as Filter));
            },
          ),
        ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            _syncMovies();
          },
          child: ListView.builder(
            restorationId: 'sampleItemListView',
            itemCount: _controller.model.movies.length,
            itemBuilder: (BuildContext context, int index) {
              final item = _controller.model.movies[index];

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
                    await _controller.removeMovie(item);
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: true).pop();
                    setState(() {});
                    String title = item.title;
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$title wurde gelöscht"),
                      action: SnackBarAction(
                          label: "undo",
                          onPressed: () async => {
                                await _controller.addMovie(context, item),
                                setState(() {})
                              }),
                    ));
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                      title: Text(item.title,
                          style: TextStyle(fontSize: _fontSize + 2)),
                      leading: CircleAvatar(
                        radius: 35,
                        foregroundImage: item.image.isNotEmpty
                            ? CachedNetworkImageProvider(item.image)
                            : const AssetImage(
                                "assets/images/Movie.png"),
                      ),
                      onTap: () async {
                        Providers providers =
                            await _controller.getProviders(item);
                        List<String> trailers =
                            await _controller.getTrailers(item);
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, MovieView.routeName,
                                arguments: MovieViewArguments(
                                    movie: item,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.pushNamed(
            context,
            SearchView.routeName,
          ).then((val) => _loadMovies())
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
