class Movie {
  String id;
  String title;
  String description;
  String fsk;
  int rating;
  int year;
  int duration;
  String image;
  List<Actor> actors;
  Movie({required this.id, required this.title, required this.description, required this.fsk, required this.rating, required this.year, required this.duration,required this.image, required this.actors});
}

class Actor {
  String name;
  int yearOfBirth;
  String image;

  Actor({required this.name, required this.yearOfBirth, required this.image});
}