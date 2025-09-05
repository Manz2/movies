import 'package:flutter/material.dart';
import 'package:movies/src/Actor/actor_controller.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/home/home_view.dart';
import 'package:movies/src/shared_widgets/expandable_text.dart';
import 'package:movies/src/shared_widgets/recommendation_list.dart';

class ActorView extends StatelessWidget {
  final Actor actor;
  final List<Movie> movies;
  final double fontSize;
  late final ActorController controller;

  static const routeName = '/actor_details';

  ActorView({
    super.key,
    required this.actor,
    required this.movies,
    required this.fontSize,
    required String uid,
    required bool isDirector,
  }) {
    controller = ActorController(
      uid: uid,
      actor: actor,
      movies: movies,
      isDirector: isDirector,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.model.actor.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeView.routeName,
                (route) => false,
              );
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
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: controller.model.actor.image != ''
                      ? Image.network(
                          controller.model.actor.image,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const Padding(padding: EdgeInsets.all(8)),
                ),
              ),
              controller.model.actor.biography != ''
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 4),
                      child: ExpandableText(
                        text: controller.model.actor.biography,
                        fontSize: fontSize,
                      ),
                    )
                  : const SizedBox(),
              controller.model.actor.birthday != null &&
                      controller.model.actor.deathday == null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 4),
                      child: Text(
                        "Alter: ${DateTime.now().year - controller.model.actor.birthday!.year - (DateTime.now().month < controller.model.actor.birthday!.month || (DateTime.now().month == controller.model.actor.birthday!.month && DateTime.now().day < controller.model.actor.birthday!.day) ? 1 : 0)}",
                        style: TextStyle(fontSize: fontSize),
                      ),
                    )
                  : const SizedBox(),
              controller.model.actor.deathday != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                      child: Text(
                        "Verstorben am: ${controller.model.actor.deathday!.day.toString().padLeft(2, '0')}.${controller.model.actor.deathday!.month.toString().padLeft(2, '0')}.${controller.model.actor.deathday!.year} "
                        "(${controller.model.actor.deathday!.year - controller.model.actor.birthday!.year - (controller.model.actor.deathday!.month < controller.model.actor.birthday!.month || (controller.model.actor.deathday!.month == controller.model.actor.birthday!.month && controller.model.actor.deathday!.day < controller.model.actor.birthday!.day) ? 1 : 0)} Jahre)",
                        style: TextStyle(fontSize: fontSize),
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                child: controller.model.isDirector
                    ? Text("Directed:", style: TextStyle(fontSize: fontSize))
                    : Text(
                        "Filmografie:",
                        style: TextStyle(fontSize: fontSize),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 15, 4),
                child: RecommendationList(
                  movies: controller.model.movies,
                  controller: controller,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
