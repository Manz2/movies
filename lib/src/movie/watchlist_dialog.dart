
import 'package:flutter/material.dart';
import 'package:movies/src/movie/movie.controller.dart';

class WatchlistDialog extends StatelessWidget {
  const WatchlistDialog({
    super.key,
    required double fontSize,
    required this.controller,
  }) : _fontSize = fontSize;

  final double _fontSize;
  final MovieController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Zur Watchlist hinzufügen?',
        style: TextStyle(fontSize: _fontSize),
      ),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final watchlist in controller.model.watchlists)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () async {
                      await controller.addMovieToWatchlist(watchlist, context);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 400,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          watchlist.name,
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Abbrechen', style: TextStyle(fontSize: _fontSize)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('Neue Liste', style: TextStyle(fontSize: _fontSize)),
          onPressed: () async {
            Navigator.pop(context);
            TextEditingController textController = TextEditingController();
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    'Neue Watchlist erstellen?',
                    style: TextStyle(fontSize: _fontSize),
                  ),
                  content: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Name der Watchlist',
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'Abbrechen',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Erstellen',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      onPressed: () async {
                        await controller.addWatchlist(textController.text);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return WatchlistDialog(
                              fontSize: _fontSize,
                              controller: controller,
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
