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
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                final movies = await controller.getMovies(actor.id);
                if (!context.mounted) return;
                Navigator.pushNamed(
                  context,
                  ActorView.routeName,
                  arguments: ActorViewArguments(
                      actor: actor, movies: movies, fontSize: fontSize),
                );
              },
              child: SizedBox(
                width: 100,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      foregroundImage: actor.image.isNotEmpty
                          ? NetworkImage(actor.image)
                          : const AssetImage(
                              "assets/images/ActorPlaceholder.png",
                            ) as ImageProvider,
                    ),
                    Text(actor.name,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: fontSize,
                        )),
                    Text(actor.roleName,
                        softWrap: true,
                        style: TextStyle(fontSize: fontSize - 4)),
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
