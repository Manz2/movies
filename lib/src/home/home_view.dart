import 'package:flutter/material.dart';
import 'package:movies/src/home/home_controller.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/settings/settings_view.dart';

class HomeView extends StatefulWidget{
  const HomeView({super.key});
  static const routeName = '/';

  @override
  HomeViewState createState() => HomeViewState();
}



class HomeViewState extends State<HomeView> {
  final HomeController _controller = HomeController();

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
    body:  Center(
      child: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: _controller.model.movies.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _controller.model.movies[index];

          return ListTile(
            title: Text('SampleItem ${item.title}'),
            leading: CircleAvatar(
              // Display the Flutter Logo image asset.
              foregroundImage: AssetImage(item.image),
            ),
            onTap: () {
              // Navigate to the details page. If the user leaves and returns to
              // the app after it has been killed while running in the
              // background, the navigation stack is restored.
              
              Navigator.pushNamed(
                context,
                MovieView.routeName,
                arguments: item
              );
            }
          );
        },
      ),
    ),
   );
  }
  
}