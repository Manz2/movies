import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/web.dart';
import 'package:movies/src/Filter/filter_model.dart';
import 'package:movies/src/Filter/filter_view.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/Watchlist/watchlist_view.dart';
import 'package:movies/src/home/home_controller.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/search/search_view.dart';
import 'package:movies/src/settings/settings_view.dart';
import 'package:movies/src/shared_widgets/confirm_dialog.dart';
import 'package:movies/src/shared_widgets/movie_cover_carousel.dart';
import 'package:movies/src/shared_widgets/movie_list_tile_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const routeName = '/';

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  late final HomeController _controller;
  final ScrollController _carouselScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _showSearchBar = true;
  bool _loading = false;
  Logger logger = Logger();

  double _fontSize = 16.0;
  bool _showCoverView = false;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return;
    }

    _controller = HomeController(uid: uid);
    _loadFontSize();
    _loadMovies();
    _syncMovies();
    _listScrollController.addListener(() {
      // Wenn gescrollt wird
      if (_listScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showSearchBar) {
          setState(() {
            _showSearchBar = false;
          });
        }
      } else if (_listScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showSearchBar) {
          setState(() {
            _showSearchBar = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _carouselScrollController.dispose();
    _searchController.dispose();
    _listScrollController.dispose(); // nicht vergessen!
    super.dispose();
  }

  Future<void> _syncMovies() async {
    setState(() {
      _loading = true;
    });
    await _controller.syncMovies();
    setState(() {});
    setState(() {
      _loading = false;
    });
  }

  void _loadMovies() async {
    await _controller.loadMovies();
    _loadFontSize();
    _applySearchFilter();
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

  void _applySearchFilter() {
    setState(() {
      if (_searchText.isEmpty) {
        _controller.model.filteredMovies = _controller.model.movies;
      } else {
        _controller.model.filteredMovies =
            _controller.model.movies
                .where(
                  (m) =>
                      m.title.toLowerCase().contains(_searchText.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Movies'),
        actions: [
          IconButton(
            icon: Icon(_showCoverView ? Icons.view_list : Icons.image),
            onPressed: () {
              setState(() {
                _showCoverView = !_showCoverView;
              });
            },
          ),
          Text(
            _controller.model.movies.length.toString(),
            style: TextStyle(fontSize: _fontSize),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_rounded),
            onPressed: () async {
              try {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => const Center(child: CircularProgressIndicator()),
                );
                Watchlist watchlist = await _controller.getCurrentWatchlist(
                  context,
                );
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true).pop();
                if (!context.mounted || watchlist.id == '') return;
                Navigator.pushNamed(
                  context,
                  WatchlistView.routeName,
                  arguments: watchlist,
                ).then((val) => _loadMovies());
              } on Exception catch (e) {
                logger.log(Level.error, e.toString());
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(
                context,
                SettingsView.routeName,
              ).then((val) => _loadMovies());
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              Navigator.pushNamed(
                context,
                FilterView.routeName,
                arguments: _controller.model.filter,
              ).then((filter) => _applyFilter(filter as Filter));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_controller.model.movies.isEmpty) ...[
            if (_loading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Center(child: CircularProgressIndicator()),
              )
            else ...[
              Text(
                "Keine Filme gefunden",
                style: TextStyle(fontSize: _fontSize),
              ),
              IconButton(icon: const Icon(Icons.sync), onPressed: _syncMovies),
            ],
          ],

          if (!_showCoverView &&
              _showSearchBar &&
              _controller.model.movies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Suche nach Filmtitel', // <- ersetzt labelText
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  _searchText = value;
                  _applySearchFilter();
                },
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _syncMovies,
              child:
                  _showCoverView
                      ? MovieCoverCarousel(
                        movies: _controller.model.movies,
                        onTap: (movie) async {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );
                            final providers = await _controller.getProviders(
                              movie,
                            );
                            final trailers = await _controller.getTrailers(
                              movie,
                            );
                            final recomendartions = await _controller.getRecommendations(
                              movie,
                            );
                            if (!context.mounted) return;
                            Navigator.of(context, rootNavigator: true).pop();
                            if (!context.mounted) return;
                            Navigator.pushNamed(
                              context,
                              MovieView.routeName,
                              arguments: MovieViewArguments(
                                movie: movie,
                                providers: providers,
                                trailers: trailers,
                                recommendations: recomendartions,
                              ),
                            ).then((val) => _loadMovies());
                          } on Exception catch (e) {
                            logger.log(Level.error, e.toString());
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                        scrollController: _carouselScrollController,
                      )
                      : ListView.builder(
                        controller: _listScrollController,
                        restorationId: 'sampleItemListView',
                        itemCount: _controller.model.filteredMovies.length,
                        itemBuilder: (context, index) {
                          final item = _controller.model.filteredMovies[index];
                          return MovieListTileView(
                            movie: item,
                            fontSize: _fontSize,
                            onTap: () async {
                              try {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder:
                                      (_) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                );
                                final providers = await _controller
                                    .getProviders(item);
                                final trailers = await _controller.getTrailers(
                                  item,
                                );
                                final recomendartions = await _controller.getRecommendations(
                                  item,
                                );
                                if (!context.mounted) return;
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                if (!context.mounted) return;
                                Navigator.pushNamed(
                                  context,
                                  MovieView.routeName,
                                  arguments: MovieViewArguments(
                                    movie: item,
                                    providers: providers,
                                    trailers: trailers,
                                    recommendations: recomendartions
                                  ),
                                ).then((val) => _loadMovies());
                              } on Exception catch (e) {
                                logger.log(Level.error, e.toString());
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              }
                            },
                            confirmDismiss:
                                () => showConfirmDialog(
                                  context: context,
                                  message:
                                      'Möchtest du "${item.title}" wirklich löschen?',
                                ),
                            onDismissed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              );
                              await _controller.removeMovie(item);
                              if (!context.mounted) return;
                              Navigator.of(context, rootNavigator: true).pop();
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.title} wurde gelöscht'),
                                  action: SnackBarAction(
                                    label: 'undo',
                                    onPressed: () async {
                                      await _controller.addMovie(context, item);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            SearchView.routeName,
          ).then((val) => _loadMovies());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
