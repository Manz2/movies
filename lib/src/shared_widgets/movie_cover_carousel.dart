import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies/src/home/movie.dart';

class MovieCoverCarousel extends StatelessWidget {
  final List<Movie> movies;
  final void Function(Movie movie) onTap;

  const MovieCoverCarousel({
    super.key,
    required this.movies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children:
            movies.map((movie) {
              return GestureDetector(
                onTap: () => onTap(movie),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 600,
                      child:
                          movie.image.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: movie.image,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                "assets/images/Movie.png",
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
