class FilterModel {
  Filter filter;
  FilterModel({required this.filter});
}

class Filter {
  int movie; //1=movie 2=tv 3=both
  List<String> fsk;
  int durationFrom;
  int durationTo;
  double rating;
  int yearFrom;
  int yearTo;
  String sortBy;
  bool accending;

  Filter({
    required this.movie,
    required this.fsk,
    required this.durationFrom,
    required this.durationTo,
    required this.rating,
    required this.yearFrom,
    required this.yearTo,
    required this.sortBy,
    required this.accending,
  });
}
