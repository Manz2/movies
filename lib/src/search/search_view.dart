import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movies/src/search/search_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchView extends StatefulWidget {
  static const routeName = '/search';

  const SearchView({super.key});

  @override
  State<StatefulWidget> createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  late final SearchPageController controller;
  double _fontSize = 16.0;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      // Optional: zur Login-Page weiterleiten oder Fehlermeldung anzeigen
      logger.e("Kein Nutzer eingeloggt");
      return;
    }

    controller = SearchPageController(uid: uid);
    _getPopular();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('font_size') ?? 16.0; // Standardwert
    });
  }

  _getPopular() async {
    await controller.getPopular();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          leading: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          hintText: "suche",
          hintStyle: WidgetStateProperty.all<TextStyle>(
            TextStyle(fontSize: _fontSize),
          ),
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.of(context).size.width) - 140,
          ),
          onSubmitted: (text) async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return const Center(child: CircularProgressIndicator());
              },
            );
            await controller.search(text);
            setState(() {});
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: controller.model.results.length,
        itemBuilder: (BuildContext context, int index) {
          final result = controller.model.results[index];
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: InkWell(
              onTap: () {
                try {
                  controller.getResult(context, result, _fontSize);
                } on Exception catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fehler beim aufrufen der Seite"),
                    ),
                  );
                  logger.e('Fehler beim aufrufen der Seite: $e');
                }
              },
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 40,
                    foregroundImage:
                        result.image.isNotEmpty
                            ? NetworkImage(result.image)
                            : result.type == 'person'
                            ? const AssetImage(
                              "assets/images/ActorPlaceholder.png",
                            )
                            : const AssetImage("assets/images/Movie.png"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      result.name,
                      style: TextStyle(
                        fontSize: _fontSize + 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
