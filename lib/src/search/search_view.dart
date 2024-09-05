import 'package:flutter/material.dart';
import 'package:movies/src/search/search_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchView extends StatefulWidget {
  static const routeName = '/search';

  const SearchView({super.key});

  @override
  State<StatefulWidget> createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  SearchPageController controller = SearchPageController();
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
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
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          hintText: "suche",
          hintStyle: WidgetStateProperty.all<TextStyle>(
              TextStyle(fontSize: _fontSize)),
          constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).size.width) - 140),
          onSubmitted: (text) async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
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
            child: ListTile(
              leading: CircleAvatar(
                radius: 35,
                foregroundImage: result.image.isNotEmpty
                    ? NetworkImage(result.image)
                    : const AssetImage("assets/images/ActorPlaceholder.jpg"),
              ),
              title:
                  Text(result.name, style: TextStyle(fontSize: _fontSize + 2)),
              onTap: () {
                try {
                  controller.getResult(context, result, _fontSize);
                } on Exception catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fehler beim aufrufen der Seite"),
                    ),
                  );
                  print('Fehler beim aufrufen der Seite: $e');
                }
              },
            ),
          );
        },
      ),
    );
  }
}
