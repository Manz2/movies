import { useEffect, useState } from "react";
import type { Schema } from "../amplify/data/resource";
import { generateClient } from "aws-amplify/data";

import { Authenticator } from '@aws-amplify/ui-react'
import '@aws-amplify/ui-react/styles.css'

const client = generateClient<Schema>();

function App() {
  const [movies, setMovies] = useState<Array<Schema["movie"]["type"]>>([]);
  const [actors, setActors] = useState<Array<Schema["actor"]["type"]>>([]);
  const [actorXmovie, setactorXmovie] = useState<Array<Schema["actorXmovie"]["type"]>>([]);

  useEffect(() => {
    client.models.movie.observeQuery().subscribe({
      next: (data) => setMovies([...data.items]),
    });
    client.models.actor.observeQuery().subscribe({
      next: (data) => setActors([...data.items]),
    });
    client.models.actorXmovie.observeQuery().subscribe({
      next: (data) => setactorXmovie([...data.items]),
    });
  }, []);

  async function createMovie() {
    const actorId: string | undefined = await createActor();
    if (actorId === undefined) {
      throw new Error("Actor ID is undefined");
    	}
    const movie = await client.models.movie.create({ 
      title: "Gladiator",
      description: "movie description",
      fsk: "FSK_16",

    });

    const movieId: string | undefined = movie.data?.id; // Extrahiere die movieId aus dem zurückgegebenen Objekt

    // Überprüfe, ob movieId nicht undefined ist
    if (movieId === undefined) {
        throw new Error("Movie ID is undefined");
    }


    client.models.actorXmovie.create({
      actorId: actorId,
      movieId: movieId,
    })
  }

  async function createActor() {
    const actor = await client.models.actor.create({
      name: "Russell Crowe"  // Korrigieren Sie den Namen hier
    });
    return actor.data?.id;
  }

  function deleteMovie(id: string) {
    client.models.movie.delete({ id })
  }

  function getActors(movie: any) {
    movie.actors;

    return ""
  }

  return (
    <Authenticator>
      {({ signOut, user }) => (
        <main>
                  <h1>{user?.signInDetails?.loginId}'s todos</h1>
        <button onClick={createMovie}>+ new</button>
        <ul>
          {movies.map((movie) => (
            <li 
            onClick={() => deleteMovie(movie.id)}
            key={movie.id}>
            {movie.title} - {movie.fsk} - {movie.description} - {getActors(movie)}
        </li>
          ))}
        </ul>
        <div>
          🥳 App successfully hosted. Try creating a new todo.
          <br />
          <a href="https://docs.amplify.aws/react/start/quickstart/#make-frontend-updates">
            Review next step of this tutorial.
          </a>
        </div>
        <button onClick={signOut}>Sign out</button>
      </main>
      )}
      
    </Authenticator>
  );
}

export default App;
