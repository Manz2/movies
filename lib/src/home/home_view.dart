import 'package:flutter/material.dart';
import 'package:movies/src/home/home_controller.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/search/search_view.dart';
import 'package:movies/src/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const routeName = '/';

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() async {
    await _controller.loadMovies();
    setState(() {}); // Aktualisiert die UI nach dem Laden der Filme
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          // Providing a restorationId allows the ListView to restore the
          // scroll position when a user leaves and returns to the app after it
          // has been killed while running in the background.
          restorationId: 'sampleItemListView',
          itemCount: _controller.model.movies.length,
          itemBuilder: (BuildContext context, int index) {
            final item = _controller.model.movies[index];

            return Dismissible(
              key: Key(item.id),
              onDismissed: (direction) {
                _controller.removeMovie(item);
                setState(() {});
                String title = item.title;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("$title wurde gelöscht"),
                  action: SnackBarAction(
                      label: "undo",
                      onPressed: () async => {
                            await _controller.addMovieWithId(
                                context, item.id, item.mediaType),
                            setState(() {})
                          }),
                ));
              },
              background: Container(color: Colors.red),
              child: ListTile(
                  title: Text(item.title),
                  leading: CircleAvatar(
                    // Display the Flutter Logo image asset.
                    foregroundImage: item.image.isNotEmpty
                        ? NetworkImage(item.image)
                        : const AssetImage(
                            "assets/images/moviePlaceholder.png"),
                  ),
                  onTap: () async {
                    final movieFuture =
                        await _controller.getMovieWithCredits(item);
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, MovieView.routeName,
                            arguments: movieFuture)
                        .then((val) => _loadMovies());
                  }),
            );
          },
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
