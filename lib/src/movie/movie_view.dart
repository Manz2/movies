import 'package:flutter/material.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
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
        padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    controller.model.movie.image,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text(
                controller.model.movie.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              const Text("Actors:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                height: 400, // Höhe des Containers für die Schauspielerliste
                child: ListView.builder(
                  scrollDirection: Axis.vertical, // Horizontale Scrollrichtung
                  itemCount: controller.model.movie.actors.length,
                  itemBuilder: (BuildContext context, int index) {
                    final actor = controller.model.movie.actors[index];
                    return Container(
                      width: 100, // Breite eines ListTiles
                      child: ListTile(
                          leading: CircleAvatar(
                            foregroundImage: actor.image.isNotEmpty
                                ? NetworkImage(actor.image)
                                : const AssetImage(
                                    "assets/images/ActorPlaceholder.jpg"),
                          ),
                          title: Text(actor.name),
                          subtitle: Text("Figur: ${actor.roleName}"),
                          onTap: () async {
                            Navigator.pushNamed(
                              context,
                              ActorView.routeName,
                              arguments: ActorViewArguments(
                                actor: actor, // Dein Actor-Objekt
                                movies: await controller.getMovies(
                                    actor.id), // Deine Liste von Movies
                              ),
                            );
                          }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
