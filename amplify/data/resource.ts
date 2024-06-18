import { type ClientSchema, a, defineData } from "@aws-amplify/backend";
import { identifyUser } from "aws-amplify/analytics";

/*== STEP 1 ===============================================================
The section below creates a Todo database table with a "content" field. Try
adding a new "isDone" field as a boolean. The authorization rule below
specifies that any user authenticated via an API key can "create", "read",
"update", and "delete" any "Todo" records.
=========================================================================*/
const schema = a.schema({
  movie: a
    .model({
      movieId: a.id(),
      title: a.string(),
      description: a.string(),
      fsk: a.enum(["FSK_0","FSK_12","FSK_16","FSK_18"]),
      actors: a.hasMany("actorXmovie", "movieId"),
      //genre
    })
    .authorization((allow) => [allow.owner()]),
  actor: a
    .model({
      actorId: a.id(),
      name: a.string(),
      movies: a.hasMany("actorXmovie","actorId"),
    }).authorization((allow) => [allow.owner()]),
  actorXmovie: a
    .model({
      actorId: a.id().required(),
      movieId: a.id().required(),
      actor: a.belongsTo("actor", "actorId"),
      movie: a.belongsTo("movie", "movieId"),
    }).authorization((allow) => [allow.owner()]),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: "userPool",
  },
});

/*== STEP 2 ===============================================================
Go to your frontend source code. From your client-side code, generate a
Data client to make CRUDL requests to your table. (THIS SNIPPET WILL ONLY
WORK IN THE FRONTEND CODE FILE.)

Using JavaScript or Next.js React Server Components, Middleware, Server 
Actions or Pages Router? Review how to generate Data clients for those use
cases: https://docs.amplify.aws/gen2/build-a-backend/data/connect-to-API/
=========================================================================*/

/*
"use client"
import { generateClient } from "aws-amplify/data";
import type { Schema } from "@/amplify/data/resource";

const client = generateClient<Schema>() // use this Data client for CRUDL requests
*/

/*== STEP 3 ===============================================================
Fetch records from the database and use them in your frontend component.
(THIS SNIPPET WILL ONLY WORK IN THE FRONTEND CODE FILE.)
=========================================================================*/

/* For example, in a React component, you can use this snippet in your
  function's RETURN statement */
// const { data: todos } = await client.models.Todo.list()

// return <ul>{todos.map(todo => <li key={todo.id}>{todo.content}</li>)}</ul>
