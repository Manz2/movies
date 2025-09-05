import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie.controller.dart';
import 'package:movies/src/tmdb_service.dart';

class ActorList extends StatelessWidget {
  final List<Actor> actors;
  final MovieController controller;
  final double fontSize;

  const ActorList({
    super.key,
    required this.actors,
    required this.controller,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    final double height = 100 + (fontSize) * 6;
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () async {
                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  final movies = await controller.getMovies(actor.id);
                  final fetchedActor = await TmdbService().getActor(actor);
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  if (!context.mounted) return;
                  Navigator.pushNamed(
                    context,
                    ActorView.routeName,
                    arguments: ActorViewArguments(
                      actor: fetchedActor,
                      movies: movies,
                      fontSize: fontSize,
                      isDirector: false,
                    ),
                  );
                } on Exception catch (e) {
                  logger.log(Level.error, e.toString());
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              child: SizedBox(
                width: 100,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      foregroundImage: actor.image.isNotEmpty
                          ? NetworkImage(actor.image)
                          : const AssetImage(
                                  "assets/images/ActorPlaceholder.png",
                                )
                                as ImageProvider,
                    ),
                    Tooltip(
                      message: actor.name,
                      child: Text(
                        actor.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: fontSize - 2),
                      ),
                    ),

                    Tooltip(
                      message: actor.roleName,
                      child: Text(
                        actor.roleName,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: fontSize - 4,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
