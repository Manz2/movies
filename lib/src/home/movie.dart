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
  List<String> genre;
  double popularity;
  String mediaType;
  double privateRating;
  String firebaseId;
  DateTime addedAt;
  bool onList = false;
  Movie(
      {required this.id,
      required this.title,
      required this.description,
      required this.fsk,
      required this.rating,
      required this.year,
      required this.duration,
      required this.image,
      required this.actors,
      required this.genre,
      required this.popularity,
      required this.mediaType,
      required this.privateRating,
      required this.firebaseId,
      required this.addedAt});

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, description: $description, fsk: $fsk, rating: $rating, year: $year, duration: $duration, image: $image, actors: $actors, genre: $genre, popularity: $popularity, privateRating: $privateRating, FirebaseId: $firebaseId, addedAt: $addedAt}';
  }

  bool get getOnList => onList;

  void setOnList(bool value) {
    onList = value;
  }

  // toJson Methode
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fsk': fsk,
      'rating': rating,
      'year': year,
      'duration': duration,
      'image': image,
      'actors': actors.map((actor) => actor.toJson()).toList(),
      'genre': genre,
      'popularity': popularity,
      'MediaType': mediaType,
      'privateRating': privateRating,
      'firebaseId': firebaseId,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // fromJson Methode
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fsk: json['fsk'],
      rating: json['rating'],
      year: json['year'],
      duration: json['duration'],
      image: json['image'],
      actors: (json['actors'] as List)
          .map((actorJson) => Actor.fromJson(actorJson))
          .toList(),
      genre: List<String>.from(json['genre']),
      popularity: json['popularity'],
      mediaType: json['MediaType'],
      privateRating: json['privateRating'].toDouble() ?? 0,
      firebaseId: json['firebaseId'] ?? '',
      addedAt: json['addedAt'] != null ?DateTime.parse(json['addedAt']) : DateTime.now(),
    );
  }
}

class Actor {
  String name;
  String image;
  String roleName;
  int id;
  Actor(
      {required this.name,
      required this.image,
      required this.roleName,
      required this.id});

  @override
  String toString() {
    return 'Actor{name: $name, image: $image, roleName: $roleName, id $id}';
  }

  // toJson Methode
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'roleName': roleName,
      'id': id,
    };
  }

  // fromJson Methode
  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'],
      image: json['image'],
      roleName: json['roleName'],
      id: json['id'],
    );
  }
}
