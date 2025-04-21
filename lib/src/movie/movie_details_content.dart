import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:movies/src/movie/movie.controller.dart';
import 'package:movies/src/shared_widgets/actor_list.dart';
import 'package:movies/src/shared_widgets/expandable_text.dart';
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

  @override
  Widget build(BuildContext context) {
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
                    SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/images/FSK${movie.fsk}.png',
                        fit: BoxFit.contain,
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
              ActorList(
                actors: controller.model.movie.actors,
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
