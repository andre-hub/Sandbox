# Koordination — Begriffe, Sichtbarkeit, Kommunikationsstil

Teil von `01-arbeitsweise\richtlinien\koordination-und-worker.md` (Hub).

## Begriffe (verbindlich)

Begriffe nicht austauschbar. Verwechslung CLI-Agent/Subagent = haeufigste Quelle unklarer Auftraege.

| Begriff | Bedeutung |
|---|---|
| **CLI-Agent** | Ein ganzer, eigenstaendiger CLI-Prozess (z. B. Copilot CLI) mit eigenem Windows-Terminal-Fenster/-Tab, eigenem Kontext und eigener Session. |
| **Koordinator** | CLI-Agent, der Plaene/Status kennt und weitere CLI-Agenten (Koordinatoren oder Worker) startet und fernsteuert. Keine eigene Rolle, siehe `01-arbeitsweise\rollen.md`. Darf weitere **Mini-Koordinatoren** starten, die wieder eigene Worker fuehren (mehrstufige Kette). |
| **Worker** | CLI-Agent, der vom Koordinator eine einzelne, klar abgegrenzte Aufgabe bekommt. Immer eigener CLI-Prozess/Fenster, nie nur ein Gedankenschritt in der Koordinator-Session. |
| **Subagent** | Hilfsagent *innerhalb* der Session eines Workers (z. B. ueber ein Task-/Subagent-Tool des CLI-Tools), ohne eigenes Windows-Terminal-Fenster. Gehoert einem Worker, nicht dem Koordinator. Ein Koordinator startet/steuert nie Subagenten direkt — nur andere CLI-Agenten (Koordinatoren oder Worker). |
| **Fernsteuern** | Koordinator gibt laufendem/erledigtem Worker einen Folgeauftrag, ohne dessen Fenster selbst zu bedienen — ueber die Session (Resume), nicht ueber Tastatureingaben. Praktisch: `aisend <id> "<auftrag>"` (siehe `koordination\worker-lebenszyklus.md`). |

Kurz — mehrstufige Kette: **Koordinator -> startet/fernsteuert -> weitere Koordinatoren (Mini-Koordinatoren) und/oder Worker (immer eigene CLI-Agenten). Mini-Koordinator fuehrt wieder eigene Worker. Worker -> starten bei Bedarf -> beliebig viele Subagenten (im eigenen Kontext, kein eigenes Fenster).** Oberster Koordinator orchestriert Mini-Koordinatoren, diese ihre Worker, diese ihre Subagenten.

## Subagenten aktiv nutzen (Worker-Pflicht, nicht Kür)

Haeufiger Fehler: Worker arbeitet alles selbst sequenziell ab; Koordinator startet fuer jede Teilfacette einen eigenen CLI-Worker. Besser: **Worker delegiert parallelisierbare, abgegrenzte Teilschritte an eigene Subagenten** (Task-Tool) im eigenen Kontext und buendelt deren Ergebnisse.

Vorteil Subagent: **billiger + schneller** — frischer eigener Kontext, oft kleineres/schnelleres Modell, echte Parallelitaet, kein neuer CLI-Prozess/Fenster/Registry/Handoff-Overhead.

Subagent (im Worker) vs. neuer CLI-Worker (durch Koordinator):

| Kriterium | Subagent (im Worker) | Neuer CLI-Worker (Koordinator) |
|---|---|---|
| Unabhaengigkeit vom Auftraggeber | nicht noetig (gehoert dem Worker) | noetig (frisch/unbeteiligt: Abschluss-Review, TDD-Trennung) |
| Fenster/Sichtbarkeit | keins | eigener Tab, langlaufend, ueberwacht |
| Scope | Teilschritt in *einer* Worker-Aufgabe | eigene Gesamtaufgabe/Teilplan, eigener Worktree/Branch |
| Kosten/Tempo | billiger, schneller, parallel | teurer (Prozess/Fenster/Registry/Handoff) |
| Schreibkonflikte | Worker koordiniert Ergebnisse selbst | Koordinator schneidet Dateien/Merge |

Faustregel: **parallelisierbare Fleissarbeit innerhalb einer Aufgabe -> Subagenten**; eigenstaendige Aufgabe/Teilplan oder unabhaengiges Review -> neuer CLI-Worker.

Typische Subagent-Faelle im Worker: mehrere Dateien/Module parallel lesen/analysieren, Varianten skizzieren, Stacktraces/Logs durchgehen, breite Suchen/Querverweise, je Aspekt (Security/Tests/Stil) ein Subagent.

Review-Worker: ein Review-Worker (frischer, unbeteiligter CLI-Agent) **darf/soll intern mehrere Subagenten fahren** — z. B. je Datei/Modul/Aspekt einen — und deren Findings buendeln. Die Unabhaengigkeit gilt fuer **den Review-Worker gegenueber der Umsetzungs-Session**, nicht als Verbot interner Subagenten.

## Sichtbarkeit

- Jeder Worker = **eigener Tab im gemeinsamen, benannten Windows-Terminal-Fenster** (Default `ai-workers` bzw. `$env:AI_WORKER_WINDOW`), nicht im Koordinator-Fenster. Koordinator sieht per Tab-Leiste, welcher CLI-Agent aktiv ist. Jeder Worker = eigener CLI-Prozess (eigenes `pwsh.exe` je Tab) -> Fernsteuern (`--resume`) + gezieltes Schliessen (Prozessbaum des Tab-Shells) bleiben robust.
- Separates Fenster: `-NewWindow` (bzw. anderer `-Window`-Name, um Worker-Gruppen auf mehrere Fenster zu verteilen).
- Koordinatoren: eigenes sichtbares Fenster (getrennt vom gemeinsamen Worker-Fenster).
- Hintergrund-CLI-Agent (kein sichtbares Fenster) = Ausnahme, braucht ausdrueckliche Freigabe (siehe `koordination\worker-lebenszyklus.md`, "'Neuer Agent' vs. Hintergrund-Worker").
- Subagenten haben nie eigenes Fenster (normal, keine Ausnahme, da kein eigener CLI-Agent).

## Kommunikationsstil zwischen CLI-Agenten/Subagenten (Caveman-Prinzip)

Auftraege/Status/Handoffs/Rueckmeldungen zwischen Koordinator/Worker/Subagenten = Agent-zu-Agent -> Caveman-komprimiert:

- Stichworte statt Saetze, Tabellen statt Prosa.
- Kein "wurde/soll/ist zu", keine Einleitungen, keine Wiederholungen.
- Worker-Auftrag (Pflichtfelder in `koordination\worker-lebenszyklus.md`): so knapp wie moeglich, aber vollstaendig.
- Blocker-/Statusmeldungen: Kernaussage zuerst, Details nur bei Bedarf.

Ausnahmen (Volltext): rechtliche Fragen/Texte; Steckbriefe, arc42-Doku, Wissensartikel in der Wissensdatenbank (dort Verstaendlichkeit > Kompression).
Kompression gilt *zwischen* Agenten, nicht fuer Ergebnisse an Menschen (dort bleibt `01-arbeitsweise\arbeitsweise.md` massgeblich: klar, nachvollziehbar, mit Pfaden/Befehlen).
