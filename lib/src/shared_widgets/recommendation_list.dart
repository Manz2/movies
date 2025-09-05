import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/home/movie.dart';
import 'package:movies/src/movie/movie_model.dart';
import 'package:movies/src/movie/movie_view.dart';
import 'package:movies/src/shared_widgets/base_controller.dart';

class RecommendationList extends StatelessWidget {
  final List<Movie> movies;
  final BaseController controller;

  final double fontSize;

  const RecommendationList({
    super.key,
    required this.movies,
    required this.controller,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
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
                  Movie newMovie = await controller.getMovie(movie);
                  Providers providers = await controller.getProviders(newMovie);
                  List<String> trailers = await controller.getTrailers(
                    newMovie,
                  );
                  List<Movie> recommendations = await controller
                      .getRecommendations(newMovie);
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.pushNamed(
                    context,
                    MovieView.routeName,
                    arguments: MovieViewArguments(
                      movie: newMovie,
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
              child: SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: movie.onList
                            ? [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.8),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: movie.image.isNotEmpty
                                ? Image.network(
                                    movie.image,
                                    height: 160,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/images/Movie.png",
                                    height: 160,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (movie.onList)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green.withValues(alpha: 0.8),
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Tooltip(
                      message: movie.title,
                      child: Text(
                        movie.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: fontSize - 2),
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
