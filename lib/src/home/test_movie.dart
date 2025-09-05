// Testdaten für Schauspieler
import 'package:movies/src/home/movie.dart';

Actor testActor1 = Actor(
  name: "John Doe",
  image: "assets/images/ActorPlaceholder.png",
  roleName: "Badman",
  id: 2,
  biography: "John Doe is a talented actor known for his roles in action films. He has a background in martial arts and stunts, which he incorporates into his performances.",
  birthday: DateTime(1985, 5, 15),
  deathday: null,
);

Actor testActor2 = Actor(
  name: "Jane Smith",
  image: "assets/images/ActorPlaceholder.png",
  roleName: "joker",
  id: 1,
  biography: "Jane Smith is an acclaimed actress known for her versatile roles in both film and television. Born in Los Angeles, she began her acting career at a young age and quickly rose to fame with her captivating performances. Over the years, Jane has received numerous awards and nominations for her work, solidifying her status as one of Hollywood's leading ladies.",
  birthday: DateTime(1990, 8, 22),
  deathday: null,
);

// Testfilm erstellen
Movie testMovie = Movie(
  id: "268",
  title: "Test Movie",
  description: "This is a test movie description.",
  fsk: "12",
  rating: 4,
  year: 2022,
  duration: 120, // Dauer in Minuten
  image: "",
  actors: [testActor1, testActor2],
  genre: ["Action"],
  popularity: 10,
  mediaType: "TV",
  privateRating: 5,
  firebaseId: '',
  addedAt: DateTime.now(),
  director: testActor1,
);
