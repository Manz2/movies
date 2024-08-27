// Testdaten für Schauspieler
import 'package:movies/src/home/movie.dart';

Actor testActor1 = Actor(
  name: "John Doe",
  yearOfBirth: 1980,
  image: "assets/images/ActorPlaceholder.jpg",
);

Actor testActor2 = Actor(
  name: "Jane Smith",
  yearOfBirth: 1985,
  image: "assets/images/ActorPlaceholder.jpg",
);

// Testfilm erstellen
Movie testMovie = Movie(
  id: "1",
  title: "Test Movie",
  description: "This is a test movie description.",
  fsk: "12",
  rating: 4,
  year: 2022,
  duration: 120, // Dauer in Minuten
  image: "assets/images/moviePlaceholder.png",
  actors: [testActor1, testActor2],
);
