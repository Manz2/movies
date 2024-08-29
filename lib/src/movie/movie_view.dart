import 'package:flutter/material.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie.controller.dart';

class MovieView extends StatefulWidget {
  final Movie movie;

  static const routeName = '/movie_details';

  const MovieView({super.key, required this.movie});

  @override
  MovieViewState createState() => MovieViewState();
}

class MovieViewState extends State<MovieView> {
  late final MovieController controller;
  bool _isFabVisible = false;

  @override
  void initState() {
    super.initState();
    controller = MovieController(movie: widget.movie);
    _istSaved();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow
                                .visible, // Kürzt den Text, wenn er zu lang ist
                          ),
                        ),
                        const SizedBox(
                            width: 10), // Abstand zwischen Titel und Bild
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
                    Text(controller.model.movie.description),
                    const SizedBox(height: 8),
                    Text("FSK: ${controller.model.movie.fsk}"),
                    const SizedBox(height: 8),
                    Text("Rating: ${controller.model.movie.rating}"),
                    const SizedBox(height: 8),
                    Text("Year: ${controller.model.movie.year}"),
                    const SizedBox(height: 8),
                    Text(
                        "Duration: ${controller.model.movie.duration} minutes"),
                    const SizedBox(height: 16),
                    const Text("Actors:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: controller.model.movie.actors.length,
                        itemBuilder: (BuildContext context, int index) {
                          final actor = controller.model.movie.actors[index];
                          return ListTile(
                            leading: CircleAvatar(
                              foregroundImage: actor.image.isNotEmpty
                                  ? NetworkImage(actor.image)
                                  : const AssetImage(
                                      "assets/images/ActorPlaceholder.jpg"),
                            ),
                            title: Text(actor.name),
                            subtitle: Text(actor.roleName),
                            onTap: () async {
                              final movies =
                                  await controller.getMovies(actor.id);
                              if (!context.mounted) return;
                              Navigator.pushNamed(
                                context,
                                ActorView.routeName,
                                arguments: ActorViewArguments(
                                    actor: actor, movies: movies),
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
    );
  }
}
