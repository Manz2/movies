// Testdaten für Schauspieler
import 'package:movies/src/home/movie.dart';

Actor testActor1 = Actor(
    name: "John Doe",
    image: "assets/images/ActorPlaceholder.jpg",
    roleName: "Badman",
    id: 2);

Actor testActor2 = Actor(
    name: "Jane Smith",
    image: "assets/images/ActorPlaceholder.jpg",
    roleName: "joker",
    id: 1);

// Testfilm erstellen
Movie testMovie = Movie(
    id: "1",
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
    mediaType: "TV");
