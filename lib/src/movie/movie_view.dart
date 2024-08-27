import 'package:flutter/material.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie.controller.dart';

class MovieView extends StatelessWidget {
  final Movie movie;
  late final MovieController controller;

  static const routeName = '/movie_details';

  MovieView({super.key, required this.movie}) {
    controller = MovieController(movie: movie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.model.movie.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              controller.model.movie.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(controller.model.movie.description),
            const SizedBox(height: 8),
            Text("FSK: ${controller.model.movie.fsk}"),
            const SizedBox(height: 8),
            Text("Rating: ${controller.model.movie.rating}"),
            const SizedBox(height: 8),
            Text("Year: ${controller.model.movie.year}"),
            const SizedBox(height: 8),
            Text("Duration: ${controller.model.movie.duration} minutes"),
            const SizedBox(height: 16),
            const Text("Actors:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...controller.model.movie.actors.map((actor) => ListTile(
                  leading: CircleAvatar(foregroundImage: AssetImage(actor.image),),
                  title: Text(actor.name),
                  subtitle: Text("Born: ${actor.yearOfBirth}"),
                )),
          ],
        ),
      ),
    );
  }
}
