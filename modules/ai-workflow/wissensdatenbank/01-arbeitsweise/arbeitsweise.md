# Arbeitsweise

Arbeitsweise fuer Programmierung, Verwaltung, Plaene (Artikelsammlung). Spezialisierte Rollen, klare Schritte, sichtbare Windows-Terminal-Tabs, Planordner -> Aufgaben wiederaufnehmbar + pruefbar.

## Ziel der Arbeitsweise

1. **Orientierung** — Ziel? Naechster Schritt? Welche Rolle hilft?
2. **Wiederaufnehmbar** — Plaene/Status in `C:\wissensdatenbank\plan`, nicht nur im Chat.
3. **Risiko klein** — keine Secrets, keine PII, keine unkontrollierten Loesch-/Installationsaktionen.
4. **Verantwortung** — Gen-AI erzeugt Code, aber Devs verantworten/verstehen/testen/reviewen ihn wie handgeschrieben.

Zielumgebung: lokale Windows-Rechner. WSL, Minikube, Git, Windows Terminal, AI-CLIs erlaubt; Windows bleibt sichtbarer Bedienrahmen.

## Grundablauf

Einfacher Zyklus je Aufgabe; keine Phase komplett ueberspringen. Logische Reihenfolge, kein starrer Wasserfall. Zwei Punkte:

- **Dokumentieren laeuft parallel** zu Umsetzen/Testen/Review, nicht erst am Ende (Schritt 6 buendelt nur die Pflichten).
- **TDD, wenn Anforderungen vollstaendig:** zuerst Tests aus Anforderungen (Schritt 4 vor 3), dann Umsetzung durch anderen CLI-Worker/Koordinator, am Ende Review Anforderungen/Tests/Code. Rollentrennung: `01-arbeitsweise\richtlinien\koordination-und-worker.md`.

1. **Verstehen**
   - Ziel in eigenen Worten wiedergeben.
   - Betroffene Dateien/Programme/Ordner nennen.
   - Offene Fragen markieren, keine Annahmen verstecken.
   - Wenn eine Ticket-URL gegeben ist: Ticketinhalt zuerst direkt aus dem internen Ticketsystem lesen (mit bestehendem Login), nicht in der Wissensdatenbank nach Ticketdateien suchen. Gesamtablauf Ticket -> PR: `01-arbeitsweise\richtlinien\ticket-bis-pr.md`.
   - Docs-first: erst Wissensdatenbank-/Doku-Artikel; Quellcode erst bei fehlender/unzureichender Doku oder unbekanntem Code (`01-arbeitsweise\richtlinien\docs-first-recherche.md`).
   - Unbekannten Code zuerst lesen, nicht sofort aendern.

2. **Planen**
   - Aufgabe in kleine, pruefbare Schritte schneiden.
   - Akzeptanzkriterien notieren (Woran erkennt man fertig?).
   - Datenschutz bei Ticket-/Wiki-Quellen: Autoren-/Personenfelder (Name, E-Mail, User-ID, Mention-Handles) nicht in Plan/Status/Handoffs uebernehmen; nur rollenbasierte Angaben (z. B. "Product Owner", "Team Abrechnung") falls fachlich noetig.
   - Front-Loading: alle Fragen/Entscheidungen **gebuendelt** nach Ausschoepfen aller autonom beschaffbaren Infos (Doku/Code) klaeren — einzeln nacheinander interaktiv, mit Auswahloptionen und Product-Owner-tauglich (fachlich, ohne Tech-Jargon) -> Umsetzung moeglichst lange autonom ohne Rueckfragen (Ziel: bis 1 Arbeitstag). Rueckfrage zwischen Planung/Umsetzung = Planungsmangel (`01-arbeitsweise\plaene.md`, `01-arbeitsweise\richtlinien\koordination-und-worker.md`).
   - Docs-first, dann Code-Beleg: Doku als Quelle, dann Plan **konkret an bestehender Implementierung verifizieren** (Typen/Signaturen/Dateien, Namenskonventionen, Reuse-vs-Neu, Abstraktionsebene) — **vor** Umsetzung. Erfundene/ungepruefte Annahmen = Planungsmangel + Hauptursache weggeworfener Umsetzungen (`01-arbeitsweise\plaene.md`, Stufe 2).
   - Risiken benennen: Datenverlust, Firmenfreigabe, Secrets, Abhaengigkeiten, Windows-Version.
   - Laengere Aufgaben: Planordner `C:\wissensdatenbank\plan\<name>`.

3. **Umsetzen**
   - Nur vereinbarten Scope.
   - Bestehende Pfade + Software-Stack respektieren.
   - Kleine Aenderungen bevorzugen, keine unnoetigen Umbauten.
   - Loeschen/Ueberschreiben: immer Backup oder klare Zustimmung.
   - Gen-AI-Code nur uebernehmen, wenn Dev ihn fachlich + technisch versteht.

4. **Testen**
   - Mind. einen passenden Check ausfuehren/beschreiben.
   - Windows-Skripte: Syntax, Pfade, Quoting, Adminrechte, Idempotenz.
   - Echter Windows-Probelauf noetig -> als offenen manuellen Test dokumentieren.

5. **Review**
   - Ergebnis gegen Ziel + Akzeptanzkriterien.
   - Nebenwirkungen suchen: kaputte Aliase, geaenderte Defaults, geloeschte Daten, neue Geheimnisse.
   - Code/Skripte: mind. zweiter Blick `reviewer`; bei Datenschutz/Security zusaetzlich `security`.
   - Generierter Code: Pflicht-Review durch unbeteiligten Agenten; nach "fertig + reviewt" darf Push + PR automatisch erfolgen, menschliches Review startet am PR und bleibt Pflicht vor Merge.

6. **Dokumentieren** (laufend, nicht erst am Ende)
   - Nur dauerhaft nuetzliches Wissen festhalten.
   - Kurze Anleitungen, Pfade, Kommandos, bekannte Einschraenkungen.
   - Status aktualisieren (fertig / offen / vom Menschen zu pruefen).
   - Pflicht: betroffene Software-Doku (README, arc42/Steckbriefe, je Anwendung `spec.md` mit Fachanforderungen, Schnittstellen, Glossar) + Wissensdatenbank-Artikel aktuell halten bei geaendertem Verhalten/Pfaden/Ablauf. Ohne aktualisierte Doku nicht fertig (`01-arbeitsweise\plaene.md`, Fertig-Kriterium).
   - SSoT (nur eine Wahrheit je Inhalt): Projekt-/Firmenregeln (`<Firma>\...\regeln.md`) beschreiben nur echte Abweichungen/Ergaenzungen zur generischen Basis + verweisen darauf, statt generische Ablaeufe/Gates/Vorlagen neu aufzuschreiben. Vor Anlegen/Erweitern pruefen, ob Inhalt schon generisch existiert.

## Wann reicht ein kurzer Chat?

Kurzer Chat statt Planordner, wenn **alle** zutreffen:

- Keine produktiven Daten, keine Firmengeheimnisse.
- Keine globalen Einstellungen/Rollenordner/Systempfade geloescht.
- Aenderung in wenigen Minuten erklaerbar + rueckgaengig machbar.
- Keine offenen Fachentscheidungen.

Mehrere Dateien / Installationen / Backups / Recherche / Review -> kleinen Plan schreiben.

## Home und Company

### Setup-Home

Pragmatischer, aber:

- Keine privaten Zugangsdaten in Prompts/Logs/Testdateien.
- Vor globalen Installationen pruefen, ob wirklich noetig.
- Backups vor Ueberschreiben persoenlicher Konfiguration.

### Setup-Company

Gleicher Workflow, mehr Pruefung:

- Arbeitsquellen klar trennen: internes Ticketsystem = Aufgaben-/Plan-Backlog (SSoT fuer Tickets), internes Unternehmenswiki = Fach-/Hintergrundwissen (Kontextquelle).
- Firmenfreigabe fuer Cloud-AI, CLI-Tools, npm-Pakete, Telemetrie.
- Keine Kundendaten/Tickets/Quellcode-Geheimnisse/Zugangsdaten in nicht freigegebene AI-Dienste.
- Lizenz-/Datenschutzanforderungen bei Tool-Einfuehrung dokumentieren.
- Coding Agents: kein autonomer Prod-Zugriff (keine Prod-Logs, keine DB-Tabellen, keine PRD-Befehle); Dev-/Testumgebungen autonom ok.
- Ausgewaehlte, bereinigte Logs darf Dev in AI-Kontext kopieren.
- Bei Unsicherheit nicht improvisieren -> Freigabe einholen.

## Koordinator und Worker

- Koordinator = keine eigene Subagenten-Rolle, keine eigene Datei -> normaler CLI-Agent (Hauptsession), kennt Plaene/Status/Rollen/Worker, strukturiert lange Arbeitsfenster.
- Koordinator + Worker = immer ganze CLI-Agenten mit sichtbarem Windows-Terminal-Tab. Worker = eigene Tabs im gemeinsamen Fenster (`ai-workers`), Koordinator = eigenes Fenster.
- Koordinator startet/fernsteuert nur weitere Koordinatoren/Worker — nie Subagenten direkt.
- Koordinator orchestriert nur: **kein Quellcode**, **keine inhaltlichen Dokumente/Wissensartikel**; pflegt nur Orchestrierungs-Dateien (Status/Checkpoints/Registry), ueberfliegt Plan/Doku hoechstens lesend.
- Inhaltliche Arbeit -> Worker (kurzlebiger als der Koordinator, aber nicht kuenstlich zerstueckelt: mehrere kleine, kohaerente Teilaufgaben je Lauf bis Kontext-Richtgroesse ~100k Token, Subagenten halten den Kontext schlank); Koordinator langlebig, arbeitet Plaene ueber Stunden autonom ab (`01-arbeitsweise\richtlinien\koordination-und-worker.md`).
- Subagenten (z. B. Task-Tool) gehoeren zum Worker-Kontext, kein eigenes Fenster.
- Worker **nutzen Subagenten aktiv**: parallelisierbare Fleissarbeit im eigenen Kontext an Subagenten delegieren (billiger + schneller, echte Parallelitaet, oft kleineres Modell), statt alles sequenziell selbst zu machen oder den Koordinator fuer jede Facette einen neuen CLI-Worker starten zu lassen. Faustregel: Teilschritt innerhalb einer Aufgabe -> Subagent; eigenstaendige Aufgabe/Teilplan oder unabhaengiges Review -> neuer CLI-Worker (`01-arbeitsweise\richtlinien\koordination\begriffe.md`).
- Worker laufen autonom in Trusted Trees (`C:\projects`, `C:\wissensdatenbank`, Worker-Austauschordner `%AI_WORKER_HOME%`), melden Ergebnis + schliessen ihr Fenster selbst; der Koordinator darf nach Erhalt des Handoffs den Tab genau dieses Workers gezielt schliessen (`aiclose <id>`) (Lebenszyklus/Fernsteuern/Staffeluebergabe: `01-arbeitsweise\richtlinien\koordination-und-worker.md`).
- Abschluss-Review immer ueber frischen CLI-Worker, nie Subagent oder umsetzender Worker selbst.
- Mehrschicht-Schleifen (Umsetzung/Test/Review/Security/Doku) erwuenscht; genug manuelle Arbeit erhalten.

Weiterlesen: Mechanik/Worker-Auftrag/Blocker-Regel `C:\wissensdatenbank\01-arbeitsweise\richtlinien\koordination-und-worker.md`; Verantwortung/Human-Review/Prod-Grenzen `C:\wissensdatenbank\01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md`; Gen-AI-Risiken systematisch `C:\wissensdatenbank\04-sicherheit\gen-ai-threat-modelling.md`.

## Windows-Konventionen

- Standard-Wissensdatenbank: `C:\wissensdatenbank`
- Windows-Terminal-Hilfsdateien: `%USERPROFILE%\Documents\windows-terminal`
- AI-Workflow-Modul im Setup-Paket: `modules\ai-workflow`
- Neue AI-Tabs: `aispawn <tool> [prompt]`
- Mehrere AI-Tabs: `aimulti <tool> "Aufgabe 1" -- "Aufgabe 2"`
- Installierte Software/Aliase/Dev-Maschine sind firmenspezifisch dokumentiert, nicht raten: firmenspezifische Infrastruktur-Doku (`<Firma>\...`).
- Prompts mit Sonderzeichen/Anfuehrungszeichen/`!`/`^`/mehrzeilig nicht direkt ueber `cmd.exe` -> Promptdatei + `ai-spawn-direct.ps1 -PromptFile`.

## Ergebnisformat fuer Agenten

Am Ende kurz melden:

```text
Ergebnis: <was wurde erreicht?>
Geaendert: <wichtige Dateien oder Einstellungen>
Geprueft: <Checks oder manueller Testbedarf>
Offen: <naechster Schritt oder keine offenen Punkte>
```
