import 'package:flutter/material.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/Filter/filter_model.dart';
import 'package:movies/src/Filter/filter_view.dart';
import 'package:movies/src/Watchlist/watchlist_model.dart';
import 'package:movies/src/Watchlist/watchlist_view.dart';
import 'package:movies/src/home/home_view.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/search/search_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          supportedLocales: const [Locale('en', '')],
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          debugShowCheckedModeBanner: false,
          title: 'movies',

          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case MovieView.routeName:
                    final args = routeSettings.arguments as MovieViewArguments;
                    return MovieView(
                      movie: args.movie,
                      providers: args.providers,
                      trailers: args.trailers,
                    );
                  case SearchView.routeName:
                    return const SearchView();
                  case ActorView.routeName:
                    final args = routeSettings.arguments as ActorViewArguments;
                    return ActorView(
                      actor: args.actor,
                      movies: args.movies,
                      fontSize: args.fontSize,
                    );
                  case FilterView.routeName:
                    final args = routeSettings.arguments as Filter;
                    return FilterView(filter: args);
                  case WatchlistView.routeName:
                    final args = routeSettings.arguments as Watchlist;
                    return WatchlistView(currentWatchlist: args);
                  case HomeView.routeName:
                  default:
                    return const HomeView();
                }
              },
            );
          },
        );
      },
    );
  }
}
