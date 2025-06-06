import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Actor/actor_controller.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/home/home_view.dart';

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
  }) {
    controller = ActorController(uid: uid, actor: actor, movies: movies);
  }

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
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
                  child:
                      controller.model.actor.image != ''
                          ? Image.network(
                            controller.model.actor.image,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                          : const Padding(padding: EdgeInsets.all(8)),
                ),
              ),
              SizedBox(
                height: 400, // Höhe des Containers für die Schauspielerliste
                child: ListView.builder(
                  scrollDirection: Axis.vertical, // Vertikale Scrollrichtung
                  itemCount: controller.model.movies.length,
                  itemBuilder: (BuildContext context, int index) {
                    final movie = controller.model.movies[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 35,
                          foregroundImage:
                              movie.image.isNotEmpty
                                  ? NetworkImage(movie.image)
                                  : const AssetImage("assets/images/Movie.png"),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                movie.title,
                                style: TextStyle(fontSize: fontSize + 2),
                              ),
                            ),
                            if (movie.onList) ...[
                              const Icon(Icons.check, color: Colors.green),
                            ],
                          ],
                        ),
                        onTap: () async {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );
                            final movieWithCredits = await controller
                                .getMovieWithCredits(movie);
                            Providers providers = await controller.getProviders(
                              movie,
                            );
                            List<String> trailers = await controller
                                .getTrailers(movie);
                            List<Movie> recommendations = await controller
                                .getRecommendations(movie);
                            if (!context.mounted) return;
                            Navigator.of(context, rootNavigator: true).pop();
                            if (!context.mounted) return;
                            Navigator.pushNamed(
                              context,
                              MovieView.routeName,
                              arguments: MovieViewArguments(
                                movie: movieWithCredits,
                                providers: providers,
                                trailers: trailers,
                                recommendations: recommendations,
                              ),
                            );
                          } on Exception catch (e) {
                            logger.log(Level.error, e.toString());
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                      ),
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
