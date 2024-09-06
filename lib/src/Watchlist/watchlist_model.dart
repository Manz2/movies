class WatchlistModel {
  List<Watchlist> watchlists = [];
  Watchlist currentWatchlist;
  WatchlistModel({required this.currentWatchlist});
}

class Watchlist {
  List<Entry> entries;
  String name;
  String id;
  Watchlist({required this.entries, required this.name, required this.id});

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'id': id
    };
  }

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      name: json['name'],
      entries: (json['entries'] != null)
          ? (json['entries'] as Map<String, dynamic>)
              .values
              .map((element) => Entry.fromJson(element))
              .toList()
          : [],
      id: json['id'],
    );
  }
}

class Entry {
  String name;
  String image;
  String type;
  String id;
  String firebaseId;

  Entry(
      {required this.name,
      required this.image,
      required this.type,
      required this.id,
      required this.firebaseId});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'type': type,
      'id': id,
      'firebaseId': firebaseId
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
        name: json['name'],
        image: json['image'],
        type: json['type'],
        id: json['id'],
        firebaseId: json['firebaseId']);
  }
}
