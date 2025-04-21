import 'package:flutter/material.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie.controller.dart';

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
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () async {
                final movies = await controller.getMovies(actor.id);
                if (!context.mounted) return;
                Navigator.pushNamed(
                  context,
                  ActorView.routeName,
                  arguments: ActorViewArguments(
                    actor: actor,
                    movies: movies,
                    fontSize: fontSize,
                  ),
                );
              },
              child: SizedBox(
                width: 100,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      foregroundImage:
                          actor.image.isNotEmpty
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
