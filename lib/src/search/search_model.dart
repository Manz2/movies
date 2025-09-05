class SearchModel {
  List<Result> results;
  SearchModel({required this.results});
}

class Result {
  String name;
  String image;
  String type;
  String id;

  Result({
    required this.name,
    required this.image,
    required this.type,
    required this.id,
  });
}
