import 'package:flutter/material.dart';
import 'package:movies/src/search/search_controller.dart';

class SearchView extends StatefulWidget {
  static const routeName = '/search';

  const SearchView({super.key});

  @override
  State<StatefulWidget> createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  SearchPageController controller = SearchPageController();

  @override
  void initState() {
    super.initState();
    _getPopular();
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
              title: Text(result.name),
              onTap: () {
                controller.getResult(context, result);
              },
            ),
          );
        },
      ),
    );
  }
}
