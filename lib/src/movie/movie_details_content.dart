import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/Actor/actor_model.dart';
import 'package:movies/src/Actor/actor_view.dart';
import 'package:movies/src/movie/movie.controller.dart';
import 'package:movies/src/shared_widgets/actor_list.dart';
import 'package:movies/src/shared_widgets/expandable_text.dart';
import 'package:movies/src/shared_widgets/recommendation_list.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsContent extends StatelessWidget {
  final MovieController controller;
  final double fontSize;
  final bool isFabVisible;
  final void Function(double)? onRatingChanged;

  const MovieDetailsContent({
    super.key,
    required this.controller,
    required this.fontSize,
    required this.isFabVisible,
    this.onRatingChanged,
  });

  void _launchURL(String url2) async {
    final Uri url = Uri.parse(url2);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  String _getFskDescription(String fsk) {
    switch (fsk) {
      case '0':
        return 'Keine Altersbeschränkung. Filme sind für Kinder absolut unbedenklich. Keine Gewalt, keine Ängstigungen, keine belastenden Themen. Geeignet für Familien und Kleinkinder.';
      case '6':
        return 'Ab 6 Jahren freigegeben. Kann erste Spannungsmomente, leichtes Gruseln oder Konflikte enthalten. Hauptfiguren müssen klar positiv dargestellt sein.';
      case '12':
        return 'Ab 12 Jahren freigegeben. Filme können Action, Bedrohungen oder ernstere Themen enthalten, aber keine drastische Gewalt. Kinder ab 6 Jahren dürfen mit Elternbegleitung ins Kino.';
      case '16':
        return 'Ab 16 Jahren freigegeben. Inhalte können intensive Gewaltszenen, Horror oder ernsthafte gesellschaftliche Konflikte zeigen.';
      case '18':
        return 'Keine Jugendfreigabe. Filme zeigen starke Gewalt, explizite Sexualität oder extrem belastende Inhalte. Nur für Erwachsene.';
      default:
        return 'Keine Information verfügbar.';
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    final movie = controller.model.movie;
    final providers = controller.model.providers;
    final orientation = MediaQuery.of(context).orientation;

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movie.image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                movie.image,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: fontSize + 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (['0', '6', '12', '16', '18'].contains(movie.fsk))
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('FSK ${movie.fsk}'),
                            content: Text(_getFskDescription(movie.fsk)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Schließen'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 30,
                        child: Image.asset(
                          'assets/images/FSK${movie.fsk}.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),
              ExpandableText(text: movie.description, fontSize: fontSize),
              const SizedBox(height: 8),
              Text("FSK: ${movie.fsk}", style: TextStyle(fontSize: fontSize)),
              const SizedBox(height: 8),
              Text(
                "Öffentliches Rating: ${movie.rating}",
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 8),
              Text("Jahr: ${movie.year}", style: TextStyle(fontSize: fontSize)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text("Director: ", style: TextStyle(fontSize: fontSize)),
                  GestureDetector(
                    onTap: () async {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        final movies = await controller.getMovies(
                          movie.director.id,
                          isDirector: true,
                        );
                        if (!context.mounted) return;
                        Navigator.of(context, rootNavigator: true).pop();
                        if (!context.mounted) return;
                        Navigator.pushNamed(
                          context,
                          ActorView.routeName,
                          arguments: ActorViewArguments(
                            actor: movie.director,
                            movies: movies,
                            fontSize: fontSize,
                            isDirector: true,
                          ),
                        );
                      } on Exception catch (e) {
                        logger.log(Level.error, e.toString());
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                    child: Text(
                      movie.director.name,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                "Genre: ${movie.genre.join(', ')}",
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 8),
              movie.mediaType == 'movie'
                  ? Text(
                      "Dauer: ${controller.getDuration()}",
                      style: TextStyle(fontSize: fontSize),
                    )
                  : Text(
                      "Dauer: ${movie.duration} Staffeln",
                      style: TextStyle(fontSize: fontSize),
                    ),
              const SizedBox(height: 8),
              if (!isFabVisible) ...[
                Text("Privates Rating:", style: TextStyle(fontSize: fontSize)),
                StarRating(
                  mainAxisAlignment: MainAxisAlignment.start,
                  size: 40.0,
                  rating: movie.privateRating,
                  color: Colors.orange,
                  borderColor: Colors.grey,
                  allowHalfRating: true,
                  starCount: 5,
                  onRatingChanged: onRatingChanged,
                ),
              ],
              const SizedBox(height: 8),
              Text("Anbieter:", style: TextStyle(fontSize: fontSize)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: GestureDetector(
                  onTap: () => _launchURL(providers.link),
                  child: Row(
                    children: [
                      for (final provider in providers.providers)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.network(provider.icon, height: 50),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (controller.model.trailers.isNotEmpty) ...[
                Text("Trailer:", style: TextStyle(fontSize: fontSize)),
                const SizedBox(height: 8),
                if (orientation != Orientation.landscape) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                      ), // gleicht das Icon vom Button aus
                      const Icon(
                        Icons.screen_rotation_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Gerät rotieren",
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
                TextButton.icon(
                  onPressed: () {
                    final videoId = controller.model.trailers[0];
                    final youtubeUrl =
                        'https://www.youtube.com/watch?v=$videoId';
                    _launchURL(youtubeUrl);
                  },
                  icon: const Icon(Icons.smart_display),
                  label: const Text("YouTube"),
                ),
                const SizedBox(height: 8),
              ],
              Text("Cast:", style: TextStyle(fontSize: fontSize)),
              const SizedBox(height: 8),
              ActorList(
                actors: controller.model.movie.actors,
                controller: controller,
                fontSize: fontSize,
              ),
              Text(
                "Das könnte dir gefallen:",
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 8),
              RecommendationList(
                movies: controller.model.recommendations,
                controller: controller,
                fontSize: fontSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
