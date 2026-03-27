import sqlite3
import pandas as pd
import os

def convert_oscar_tsv_to_db(csv_filename, db_filename):
    base_path = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(base_path, csv_filename)
    db_path = os.path.join(base_path, db_filename)

    if not os.path.exists(csv_path):
        print(f"Fehler: '{csv_filename}' nicht gefunden!")
        return

    print(f"Lese {csv_filename} mit Tab-Separator ein...")
    
    try:
        # Hier ist die wichtige Änderung: sep='\t' für Tabs
        df = pd.read_csv(csv_path, sep='\t', engine='python')

        # Spaltennamen säubern
        df.columns = df.columns.str.strip()

        # Winner-Spalte zu 1 und 0 konvertieren
        # Da im Text 'True' steht oder leer ist:
        df['Winner'] = df['Winner'].fillna(False)
        df['Winner'] = df['Winner'].apply(lambda x: 1 if str(x).lower() == 'true' else 0)

        # Verbindung zur Datenbank
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # Daten schreiben
        df.to_sql('oscars', conn, if_exists='replace', index=False)

        # Indizes für die Performance
        print("Erstelle Indizes für FilmId und Namen...")
        # Wir indizieren jetzt auch die FilmId, da dein CSV diese hat!
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_film_id ON oscars (FilmId);")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_film_name ON oscars (Film);")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_actor_name ON oscars (Name);")
        
        conn.commit()
        conn.close()

        print(f"Erfolg! '{db_filename}' wurde sauber erstellt.")
        print(f"Einträge: {len(df)}")

    except Exception as e:
        print(f"Fehler beim Konvertieren: {e}")

if __name__ == "__main__":
    # Falls deine Datei anders heißt, hier anpassen:
    SOURCE_FILE = "oscars.csv" 
    TARGET_DB = "oscars_data.db"
    convert_oscar_tsv_to_db(SOURCE_FILE, TARGET_DB)