# Koordination und Worker

Referenz fuer Koordinator/Worker-Mechanik. **Hub** — Details in `koordination\*`, nur bei Bedarf laden. `01-arbeitsweise\arbeitsweise.md` und `01-arbeitsweise\rollen.md` verlinken kurz hierher.

## Ziel

- Laengere Aufgaben: 1 Koordinator + mehrere kleine Worker.
- Kontext/Verantwortung/Scope nicht verwischen.
- **Auto-Koordinator (verbindlich):** CLI-Agent bekommt ein Ticket aus dem internen Ticket-/Aufgabensystem ODER Umsetzungsauftrag ("mache ABC ...", "setze X um", "baue Y") -> automatisch Koordinator, nicht selbst umsetzen. Details: `koordination\koordinator-vs-worker.md`.

## Kette (Kurz)

**Koordinator -> startet/fernsteuert -> Mini-Koordinatoren und/oder Worker (immer eigene CLI-Agenten). Mini-Koordinator -> eigene Worker. Worker -> beliebig viele Subagenten (eigener Kontext, kein eigenes Fenster).**

- Koordinator: orchestriert nur, kein Quellcode/keine Inhaltsdokumente, langlebig. Schliesst nach Erhalt des Handoffs den Tab genau dieses Workers gezielt (`aiclose <id>`).
- Worker: inhaltliche Arbeit (planen/analysieren/programmieren), kurzlebiger als der Koordinator, aber **nicht kuenstlich zerstueckelt** (darf mehrere kleine, kohaerente Teilaufgaben in einem Lauf bis zur Kontext-Richtgroesse ~100k Token erledigen; frisch erst bei knappem Kontext oder fuer unabhaengigen Review). **Nutzt aktiv eigene Subagenten** fuer parallelisierbare Fleissarbeit (billiger + schneller, halten Haupt-Kontext schlank), statt alles selbst sequenziell oder jede Facette als neuen CLI-Worker. Review-Worker sollen 4+ eigene Subagenten parallel einsetzen; Ausnahme: externer Datei-/Repo-Zugriff → eigener CLI-Worker (Subagent teilt Scope des Eltern-Workers).
- Kleine Pakete: Teilaufgaben so klein zuschneiden, dass ein Umsetzungs-Worker wenig gleichzeitig wissen muss (kleiner, klar begrenzter Kontext je Worker); grosse Aufgaben aufteilen.
- Review immer durch frischen unbeteiligten CLI-Worker (darf intern eigene Subagenten fahren — Verbot betrifft nur die Herkunft).
- Agent-zu-Agent-Kommunikation: Caveman-komprimiert.

## Themen im Detail (Sub-Artikel)

| Thema (frueherer Abschnitt) | Datei |
|---|---|
| Begriffe (CLI-Agent/Koordinator/Worker/Subagent/Fernsteuern), Sichtbarkeit, Kommunikationsstil/Caveman | `koordination\begriffe.md` |
| Grundprinzipien, Aufgabenteilung Koordinator vs. Worker (Harte Trennung, Lebensdauer), Ueberwachungsintervall, Koordinator-Staffeluebergabe | `koordination\koordinator-vs-worker.md` |
| Autonomie-Ziel und Front-Loading, Wartepositionen minimieren, Resume-faehige Checkpoints | `koordination\front-loading-und-resume.md` |
| Autonome Worker: Berechtigungen/Flags, Worker-Lebenszyklus, Fernsteuern, Worker-Auftrag (Pflichtfelder + Beispiel), Terminal-Umsetzung (Windows), "Neuer Agent" vs. Hintergrund-Worker | `koordination\worker-lebenszyklus.md` |
| Parallele Worker/Merge-Konflikte, Mehrschicht-Schleifen (Doku parallel, TDD-Variante), AI-/Menschen-Staerken, Produktionsgrenzen, Review-Check | `koordination\schleifen-und-review.md` |

## Verweise

- Plan-Methodik/Front-Loading/Resume-Status: `01-arbeitsweise\plaene.md`
- Modell/Aufwand-Tiers (klein/standard/hoch, konkrete Modelle + Effort): `01-arbeitsweise\plaene.md` §Plan-Struktur/Modell-Aufwand
- Rollen: `01-arbeitsweise\rollen.md`
- Git/Worktree/Branch: `02-softwareentwicklung\richtlinien\git-workflow.md`
- Gen-AI-Verantwortung/Prod-Grenzen: `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md`
- Reviewzyklen: `01-arbeitsweise\richtlinien\plan-lifecycle-und-reviewzyklen.md`
