# Gen-AI-Threat-Modelling

## Ziel

Bevor ein Agent breite Rechte bekommt (Dateisystem, Shell, Netzwerk, MCP-Server,
Skills), kurz die typischen Gen-AI-Risiken durchgehen. Ziel ist keine vollstaendige
Bedrohungsanalyse, sondern eine schnelle, wiederholbare Checkliste.

## Bedrohungskategorien

| Kategorie | Risiko | Beispiel-Warnzeichen | Gegenmassnahme |
|---|---|---|---|
| Prompt Injection | Externer Inhalt gibt sich als Anweisung aus | `ignore previous instructions` in Webseite/Issue/PDF | Externe Quellen als Daten behandeln, nicht ausfuehren; siehe `01-arbeitsweise\recherche.md` |
| Secret Exfiltration | Agent liest oder gibt Tokens/Keys/Passwoerter aus | `.env`, Kubeconfig oder Zugangsdaten im Arbeitsverzeichnis | Keine Secrets im Arbeitsbaum/Prompt-Kontext; Secret-Scanner vor Commit |
| Sensitive-/PII-Data-Exfiltration | Personenbezogene oder interne Daten landen im AI-Kontext oder in Logs | Echte Kundendaten in Testdateien oder Prompts | Nur synthetische Beispieldaten; siehe `04-sicherheit\sicherheit.md` |
| Insecure/Vulnerable Code Generation | Generierter Code enthaelt Schwachstellen oder unsichere Defaults | Fehlende Input-Validierung, hartkodierte Secrets, unsichere Deserialisierung | Human Review durch unbeteiligten Dev; Tests fuer Fehlerfaelle |
| Excessive Agency / zu breite Tool-Rechte | Agent darf mehr, als die Aufgabe braucht | `allow-all`-Modus fuer eine Lese-Aufgabe, Schreibrecht auf Produktionsordner | Minimale Tool-Rechte je Aufgabe; Production-Grenzen aus `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md` |
| Supply-Chain-Risiko bei Skills/MCP/Erweiterungen | Ungeprueftes Drittanbieter-Tool fuehrt Code aus oder liest Kontext | Unbekannter MCP-Server, ungeprueftes Skill/Plugin, Paket ohne Herkunftspruefung | Nur freigegebene/bekannte Tools nutzen; Herkunft und Rechte pruefen, bevor sie aktiv sind |
| Halluzinierte Abhaengigkeiten/APIs | Agent nutzt erfundene Pakete, Funktionen oder Endpunkte | Paketname existiert nicht oder stammt aus falscher Registry | Vor Uebernahme Existenz und Quelle pruefen, nicht blind installieren |
| Autonome Production-Aktionen | Agent greift ohne Freigabe auf produktive Systeme zu | Agent zieht Prod-Logs oder fuehrt PRD-Befehle selbst aus | Siehe Produktionsgrenzen in `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md` |

## Vorgehen (kurz)

1. Aufgabe und noetige Rechte benennen (Datei-, Shell-, Netzwerk-, Tool-Zugriff).
2. Kategorien oben durchgehen: Welche sind fuer diese Aufgabe realistisch?
3. Rechte auf das Minimum kuerzen, das die Aufgabe wirklich braucht.
4. Gegenmassnahmen im Plan oder Handoff kurz notieren, nicht nur einzelne Tool-Calls abnicken.
5. Bei Unsicherheit: `security` einschalten statt zu improvisieren.

## Review-Check

- Sind Secrets und Prod-Daten aus dem Arbeitskontext ferngehalten?
- Hat der Agent nur die Rechte, die die Aufgabe braucht?
- Wurden externe Inhalte als Daten behandelt, nicht als Befehl?
- Wurden neue Abhaengigkeiten/Tools auf Herkunft geprueft?
- Ist Human Review fuer generierten Code eingeplant?

Mehr zu Verantwortung, Human Review und Production-Grenzen: `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md`.
