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
  Actor director;
  bool onList = false;

  Movie({
    required this.id,
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
    required this.addedAt,
    required this.director,
  });

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, description: $description, fsk: $fsk, rating: $rating, year: $year, duration: $duration, image: $image, actors: $actors, genre: $genre, popularity: $popularity, privateRating: $privateRating, FirebaseId: $firebaseId, addedAt: $addedAt, director: $director}';
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
      'director': director.toJson(),
    };
  }

  // fromJson Methode
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fsk: json['fsk'] ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      year: json['year'] ?? 0,
      duration: json['duration'] ?? 0,
      image: json['image'] ?? '',
      actors: (json['actors'] is List)
          ? (json['actors'] as List)
                .map((a) => Actor.fromJson(Map<String, dynamic>.from(a)))
                .toList()
          : [],
      genre: json['genre'] != null ? List<String>.from(json['genre']) : [],
      popularity: (json['popularity'] ?? 0).toDouble(),
      mediaType: json['MediaType'] ?? '',
      privateRating: (json['privateRating'] ?? 0).toDouble(),
      firebaseId: json['firebaseId'] ?? '',
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      director: (json['director'] is Map)
          ? Actor.fromJson(Map<String, dynamic>.from(json['director']))
          : Actor(
              name: json['director']?.toString() ?? '',
              image: '',
              roleName: '',
              id: 0,
              biography: '',
              birthday: null,
              deathday: null,
            ),
    );
  }
}

class Actor {
  String name;
  String image;
  String roleName;
  int id;
  String biography;
  DateTime? birthday;
  DateTime? deathday;
  Actor({
    required this.name,
    required this.image,
    required this.roleName,
    required this.id,
    required this.biography,
    required this.birthday,
    required this.deathday,
  });

  @override
  String toString() {
    return 'Actor{name: $name, image: $image, roleName: $roleName, id $id}';
  }

  // toJson Methode
  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image, 'roleName': roleName, 'id': id};
  }

  // fromJson Methode
  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'],
      image: json['image'],
      roleName: json['roleName'],
      id: json['id'],
      biography: json['biography'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      deathday: json['deathday'] != null
          ? DateTime.parse(json['deathday'])
          : null,
    );
  }
}
