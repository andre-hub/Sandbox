# Koordination — Aufgabenteilung Koordinator vs. Worker

Teil von `01-arbeitsweise\richtlinien\koordination-und-worker.md` (Hub). Begriffe: `koordination\begriffe.md`.

## Grundprinzipien

- **Auto-Koordinator-Trigger (verbindlich):** bekommt ein CLI-Agent ein **Ticket aus dem internen Ticket-/Aufgabensystem** als Eingabe/Aufgabe, ist er damit automatisch Koordinator — er setzt nicht selbst um, sondern zerlegt in Plan/Teilaufgaben und startet/fernsteuert frische Worker. Ebenso: teilt der Nutzer einem CLI-Agenten einen **Umsetzungsauftrag** mit ("mache ABC ...", "setze X um", "baue Y"), ist er damit automatisch Koordinator, der Worker fernsteuert statt selbst umzusetzen. Koordinator orchestriert nur (Plan/Status/Worker/Integration), schreibt keinen Produktcode/keine Inhaltsdokumente. Enge Ausnahme: triviale Einzelfrage/Kleinstauskunft ohne Datei-/Code-/Doku-Aenderung -> Agent antwortet direkt (kein Worker noetig). Bestehendes Prinzip bleibt gueltig: kleine, kohaerente Aenderungen duerfen gebuendelt, nicht kuenstlich zerstueckelt werden.
- Koordinator strukturiert lange Arbeitsfenster, steuert mehrere Worker.
- Jeder Worker: genau 1 klar benannter, **kohaerenter** Auftrag mit klaren Grenzen — das darf ein **Buendel eng zusammenhaengender kleiner Aenderungen** sein (gleiches Modul/Datenmodell, z. B. ein paar Klassen/Properties), aber kein beliebiger Sammelauftrag ueber unzusammenhaengende Bereiche.
- Unabhaengige Aufgaben parallel; ueberlappenden Scope vermeiden.
- Ziel = massiv parallel: Aufgaben so schneiden, dass Worker moeglichst unterschiedliche Dateien/Module bearbeiten, Merge-Konflikte selten (Worktree/Branch-Muster: `02-softwareentwicklung\richtlinien\git-workflow.md`).
- Worker melden Blocker/offene Fragen zurueck, nie Annahmen verstecken.
- Koordinator entscheidet Integration, Prioritaeten, Stopps.
- Koordinator schliesst Worker bei Bedarf selbst (`aiclose`): **nach Erhalt/Sichtung des Handoffs den passenden Tab genau dieses Workers** sowie verwaiste/haengende/aus dem Scope driftende Worker beenden, damit nur aktive saubere Laeufe offen bleiben und Kontext/Ressourcen frei sind — verlaesst sich nicht auf zuverlaessige Selbstschliessung.
- Menschen entscheiden Zielbild, Historie, Trade-offs, Ownership, Stopps.

## Aufgabenteilung: Koordinator vs. Worker

Sobald ein Plan mit Workern erstellt/abgearbeitet wird (nicht bei kurzer Einzelaufgabe): klare Trennung. Koordinator orchestriert, Worker arbeiten inhaltlich. Koordinator zieht die Arbeit nicht an sich, auch wenn er sie technisch koennte — sonst verschwimmt der Kontext, das Arbeitsfenster laeuft voll.

| Bereich | Koordinator (macht) | Koordinator (macht nicht) |
|---|---|---|
| Fokus | Worker starten, fernsteuern, beobachten | Selbst planen, recherchieren, analysieren, programmieren |
| Dateien schreiben | Nur Orchestrierungs-Dateien: `status.md`, Checkpoints/Handoff-Uebersicht, Worker-Registry | Inhaltliche Dokumente, Wissensartikel, Plan-Inhalt oder Quellcode bearbeiten (Worker-Arbeit) |
| Dateien lesen | Orchestrierungs-Kontext (Status/Handoff/Registry); Plan-Inhalte und Doku ueberfliegen, um Fortschritt/Drift zu beurteilen | **Quellcode lesen** oder Dateien zum Bearbeiten oeffnen |
| Steuerung | Reihenfolge, Prioritaeten, Integration, Stopps festlegen | Den Scope eines Workers heimlich selbst umsetzen |
| Qualitaet | Drift erkennen und korrigieren, Worker neu ausrichten | Findings eines Workers ungeprueft uebernehmen |
| Status | Status-/Checkpoint-/Registry-Dateien aktuell halten, Handoffs sichtbar machen | Blocker verstecken oder Status raten; Plan-Inhalt selbst schreiben |
| Review | Unabhaengiges Review ueber frischen Worker anstossen | Umsetzung eines Workers selbst reviewen |

**Harte Trennung (verbindlich):** Koordinator liest/schreibt **keinen Quellcode** und bearbeitet **keine inhaltlichen Dokumente oder Wissensartikel** — auch nicht kurz oder „schnell selbst". Dateizugriff nur Orchestrierung (`status.md`, Checkpoints/Handoff-Uebersicht, Worker-Registry); Plan-Inhalte und Doku nur lesend ueberfliegen (Fortschritt/Drift beurteilen). Jede Datei-Aenderung an Code/Doku/Wissensartikeln/Plan-Inhalt geht an einen Worker — auch wenn der Koordinator es technisch koennte. So bleibt sein Kontext schlank, Plaene ueber viele Stunden autonom orchestrierbar.

**Lebensdauer:** Worker **kurzlebiger als der Koordinator**, aber **nicht kuenstlich zerstueckelt**: ein Worker darf laenger laufen und **mehrere kleine, kohaerente Teilaufgaben** in einem Lauf erledigen (z. B. ein paar Klassen/Properties im selben Modul), solange sein nutzbarer Kontext (Richtgroesse ~100k Token) sauberes Arbeiten erlaubt — Subagenten halten dabei den Haupt-Kontext schlank (nur kompakte Handoffs zurueck). Frisch gestartet wird ein Worker erst, wenn der Kontext wirklich knapp/voll wird oder die Aufgabe bzw. der (Teil-)Plan fertig ist (davor Resume-Checkpoint in `status.md`), sowie fuer einen unabhaengigen Blick (Review). **Nicht fuer jede triviale Teilaufgabe** einen neuen CLI-Worker — der wiederholte Kontext-Neuaufbau (Doku+Plan+Code neu lesen) kostet mehr, als die Kontexttrennung spart, und erzeugt Integrationsfehler durch Kontextverlust. Koordinator **langlebig**: viele Stunden aktiv, arbeitet Plaene autonom ab, ohne selbst in Code oder inhaltliche Dokumente einzugreifen. Bei knappem eigenem Kontext: Staffeluebergabe an frischen Koordinator (unten).

Worker = CLI-Agent der inhaltlichen Arbeit: **schreibt Plan bzw. Unterplan**, untersucht/analysiert die Codebasis, schreibt/programmiert, nutzt bei Schreibzugriff eigenen Worktree/Branch (`02-softwareentwicklung\richtlinien\git-workflow.md`), testet und meldet Ergebnis/Blocker/offene Fragen zurueck. Plan erstellen/ausarbeiten = ebenfalls Worker-Arbeit; Koordinator gibt nur Ziel/Scope/Rahmen vor und prueft danach das Ergebnis.

Ausnahme: kurze, klar abgegrenzte Einzelaufgabe -> kein zweiter CLI-Agent noetig, ein einzelner CLI-Agent macht alles selbst (`01-arbeitsweise\arbeitsweise.md`). Trennung greift, sobald ein Plan angelegt wird oder mehrere Worker im Spiel sind.

## Ueberwachungsintervall (Monitoring-Schleife)

Koordinator laesst Worker/Mini-Koordinatoren nicht unbeaufsichtigt durchlaufen, sondern schaut in festem Intervall nach: Fortschritt lesen, Status/Blocker pruefen, bei Problemen eingreifen — neu ausrichten, Drift entfernen, Status nachbessern, Reihenfolge/Prioritaet aendern, notfalls stoppen.

Intervall **30 s – 30 min**, abhaengig von Aufgabenart/Komplexitaet/Risiko/Autonomiegrad. Pro Plan/Worker festlegen, im Status notieren, darf sich waehrend der Arbeit aendern (kuerzer in kritischen Phasen, laenger bei langen stabilen Laeufen).

| Intervall | Wann sinnvoll |
|---|---|
| ~30 s – 2 min | riskante/kritische Phase, enge Abhaengigkeiten, neuer/instabiler Worker, produktionsnahe Vorbereitung |
| ~2 – 10 min | normale Umsetzungs-/Testarbeit mit ueberschaubarem Risiko |
| ~10 – 30 min | lange, stabile, klar abgegrenzte Laeufe (z. B. grosse Refactor-Batches, umfangreiche Recherche) |

Bei jedem Check: nur eingreifen wenn noetig — laeuft der Worker sauber im Scope, reicht ein kurzer Blick auf Status/Fortschritt. Haeufen sich Drift/Blocker/Scope-Ueberschreitung -> sofort nachsteuern, nicht bis zum naechsten Intervall warten.

## Koordinator-Staffeluebergabe

Koordinator laeuft nicht unbegrenzt in vollgelaufenem Fenster/Kontext weiter. Nach Teilaufgaben-Abschluss (oder bei knappem Kontext): Uebergabe an frischen Nachfolge-Koordinator:

1. Resume-Checkpoint/Plan-Status aktuell halten (`01-arbeitsweise\plaene.md`), damit der Nachfolger nahtlos weitermacht.
2. Nachfolger starten: `aihandoff -PromptFile <plan>\status.md` (oder `-Prompt` mit Resume-Kontext, optional `-ResumeSession <id>`).
3. Sobald Nachfolger in Registry als laufend bestaetigt: urspruenglicher Koordinator schliesst sich (mit `-SelfId <eigene-id>` automatisch, sonst manuell).

So ist immer nur ein aktiver Koordinator sichtbar; die Kette bleibt wiederaufnehmbar, der Fenster-Ueberblick erhalten.
