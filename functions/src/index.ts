import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import axios from "axios";

admin.initializeApp();

const TMDB_API_KEY = process.env.TMDB_API_KEY;

export const checkAvailability = onSchedule(
    {
        schedule: "0 9 * * *",
        timeZone: "Europe/Berlin",
    },
    async () => {
        const db = admin.database();
        const usersSnap = await db.ref("users").once("value");
        const users = usersSnap.val();

        if (!users) {
            console.log("Keine Nutzer gefunden");
            return;
        }

        for (const uid of Object.keys(users)) {
            const user = users[uid];
            const userNotifications = user.notifications ?? {};

            for (const token of Object.keys(userNotifications)) {
                const movies = userNotifications[token];

                for (const key of Object.keys(movies)) {
                    const [movieId, mediaType] = key.split("_");
                    const movieData = movies[key];

                    try {
                        const url = `https://api.themoviedb.org/3/${mediaType}/${movieId}/watch/providers`;
                        const response = await axios.get(url, {
                            params: { api_key: TMDB_API_KEY },
                        });

                        const providersDE = response.data.results?.DE?.flatrate ?? [];

                        if (providersDE.length > 0) {
                            console.log(
                                `Sende Notification an uid=${uid}, token=${token}, movie=${movieId} (${mediaType})`
                            );
                            const names = (providersDE ?? []).map((p: { provider_name: any; }) => p.provider_name).filter(Boolean);

                            await admin.messaging().send({
                                token,
                                data: {
                                    id: movieId,
                                    mediaType: mediaType,
                                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                                },
                                notification: {
                                    title: `${movieData.title} jetzt verfügbar!`,
                                    body: names.length > 0
                                        ? `Ab sofort zum Streamen bei ${names.join(", ")} verfügbar! 🎉`
                                        : "Ab sofort zum Streamen verfügbar! 🎉",
                                },
                            });
                        }
                    } catch (err) {
                        console.error(
                            `Fehler bei TMDB-Call für ${movieId} (${mediaType}):`,
                            err
                        );
                    }
                }
            }
        }
    }
);
