# Agentische Entwicklung

## Ziel

Mehrere AI- oder CLI-Werkzeuge koordiniert einsetzen, ohne dass Kontext, Verantwortung oder Ergebnisqualitaet verschwimmen.

## Grundprinzipien

- Rolle und Mechanismus trennen.
- Komplexe Aufgaben in kleine, pruefbare Arbeitspakete schneiden.
- Schreibarbeit, Review und Security moeglichst trennen.
- Gen-AI beschleunigt Arbeit, Verantwortung bleibt beim Dev und Koordinator.
- Menschliche Staerken und AI-Staerken bewusst kombinieren: AI fuer Fleißarbeit und Analyse, Menschen fuer Zielbild, Historie, Trade-offs und Ownership.
- Nur dauerhaftes Wissen dokumentieren; Chat-Verlauf nicht in Dauerwissen kippen.

## Rollenbild

| Rolle | Fokus |
|---|---|
| Koordination | Ziel, Reihenfolge, Entscheidungen |
| Exploration | Bestand lesen, Risiken finden |
| Umsetzung | Dateien aendern |
| Test | Verifikation |
| Review | Qualitaet, Architektur, Security |
| Doku | Dauerwissen aktualisieren |

## Kontexttrennung und Handoffs

Worker-Auftragsformat, Blocker-Regel und Mehrschicht-Schleifen (Umsetzung, Test,
Review, Security, Doku) sind in `01-arbeitsweise\richtlinien\koordination-und-worker.md` beschrieben. Kurz:
ein Worker bekommt genau eine Aufgabe, Handoffs nennen Scope/Regeln/erwartetes
Ergebnis/Verbote, und ein Abschluss-Review sollte unabhaengig vom Umsetzer bleiben.

## Produktionsgrenzen

Coding Agents bekommen keinen autonomen Zugriff auf Production. Details und
Beispiele: `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md`.

## Wissensquellen

| Ebene | Inhalt |
|---|---|
| Globale Instruktionen | Tooling, Spawn-Regeln, Guardrails |
| Repo-Dateien wie `AGENTS.md` | Build, Test, lokale Konventionen |
| Wissensdatenbank | wiederverwendbare Regeln und Architekturwissen |
| Planordner | sitzungsbezogene Entscheidungen und Status |

## Handoff-Regeln

Kurzfassung: Ziel/Scope explizit, betroffene Dateien nennen, Output-Format
vorgeben, Verbote benennen (kein Commit, kein Loeschen, read-only, keine Secrets).
Vollstaendiges Worker-Auftragsformat mit Beispiel: `01-arbeitsweise\richtlinien\koordination-und-worker.md`.

## Review-Check

- Ist klar, wer entscheidet und wer nur ausfuehrt?
- Bleibt der Koordinationskontext klein?
- Sind Findings und Ergebnisse reproduzierbar dokumentiert?
- Versteht ein verantwortlicher Dev den generierten Code und kann ihn im Incident betreuen?
- Gibt es ein Pflicht-Review durch einen unbeteiligten Agenten, und vor Push zusaetzlich durch eine unbeteiligte Person?
