import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies/src/home/movie.dart';

class MovieListTileView extends StatelessWidget {
  final Movie movie;
  final double fontSize;
  final void Function()? onTap;
  final void Function()? onDismissed;
  final Future<bool?> Function()? confirmDismiss;

  const MovieListTileView({
    super.key,
    required this.movie,
    required this.fontSize,
    this.onTap,
    this.onDismissed,
    this.confirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(movie.id),
        confirmDismiss: (_) => confirmDismiss?.call() ?? Future.value(false),
        onDismissed: (_) => onDismissed?.call(),
        background: Container(color: Colors.red),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 40,
                foregroundImage:
                    movie.image.isNotEmpty
                        ? CachedNetworkImageProvider(movie.image)
                        : const AssetImage("assets/images/Movie.png")
                            as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  movie.title,
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
