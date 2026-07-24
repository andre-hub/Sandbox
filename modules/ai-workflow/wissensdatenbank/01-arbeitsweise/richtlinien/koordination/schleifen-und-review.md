# Koordination — Parallele Worker, Mehrschicht-Schleifen, Review

Teil von `01-arbeitsweise\richtlinien\koordination-und-worker.md` (Hub).

## Parallele Worker und Merge-Konflikte vermeiden

- Aufgabenschnitt = Koordinator-Verantwortung: Teilaufgaben so abgrenzen, dass parallele Worker moeglichst unterschiedliche Dateien/Module anfassen.
- Breite Refactorings (Umbenennungen, Struktur-Umbau, viele Dateien gleichzeitig) zuerst + sequenziell — erst danach die parallele Arbeit starten.
- Unvermeidbare Ueberlappung: betroffene Teilaufgaben sequenziell statt parallel einplanen, statt Merge-Konflikte in Kauf zu nehmen.
- Technisches Muster (eigener Worktree/Branch je Worker, Merge in gemeinsamen Feature-Branch durch Koordinator): `02-softwareentwicklung\richtlinien\git-workflow.md`.

## Mehrschicht-Schleifen

Fuer groessere Aenderungen Normalfall:

```text
Umsetzung -> Test -> Review -> Security (falls relevant)   (Doku laeuft parallel mit)
```

- Schleifen wiederholbar, bis Findings abgearbeitet sind.
- Review immer ueber frischen CLI-Worker (eigener CLI-Agent, eigener Tab, eigener Kontext) — nie Subagent der Umsetzungs-Session, nie umsetzender Worker selbst. So bleibt das Review unabhaengig, besonders bei Gen-AI-Code/riskanten Aenderungen.
- **Der Review-Worker selbst darf/soll bei parallelisierbarer Pruefarbeit 4+ eigene Subagenten einsetzen** (je Datei/Modul/Aspekt parallel — billiger + schneller). Das Subagent-Verbot betrifft nur die **Herkunft** (kein Subagent der Umsetzungs-Session), nicht die interne Parallelisierung. **Ausnahme:** braucht eine Teilpruefung Zugriff auf externe Dateien (ausserhalb des Worker-Scopes/`--add-dir`), ist ein eigener CLI-Worker besser als ein Subagent (Subagent teilt Berechtigungs-Scope des Eltern-Workers). Faustregel: Subagenten fuer Paralleles im eigenen Scope; CLI-Worker bei externem Datei-/Repo-Zugriff. Details/Entscheidung Subagent vs. CLI-Worker: `koordination\begriffe.md`.
- Finaler Commit erst nach gruenen Checks + abgeschlossenem Review.

### Dokumentation laeuft parallel, nicht erst am Ende

Doku entsteht **parallel** zu Umsetzung/Review, nicht als nachgelagerter letzter Schritt:

- Waehrend ein Worker umsetzt, haelt die Doku (arc42, Steckbriefe, Schnittstellen, Projektartikel, `regeln.md`, READMEs) Schritt — durch den umsetzenden Worker selbst oder einen mitlaufenden `documenter`-Worker.
- Aendert sich Verhalten/Signatur/Datenfluss/Konfiguration -> passende Doku im selben Zug anpassen, nicht vertagen.
- Review prueft Code **und** mitgezogene Doku gemeinsam; fehlende/veraltete Doku = Review-Finding, kein optionaler Nachtrag.
- So bleibt das Fertig-Kriterium (`01-arbeitsweise\plaene.md`) erfuellbar, ohne am Ende einen grossen fehleranfaelligen Doku-Block nachzuziehen.

### TDD-Variante (wenn Anforderungen vollstaendig sind)

Anforderungen vollstaendig + pruefbar (durch `anforderer`/`architect` geklaert) -> TDD bevorzugt, mit strikter Rollentrennung ueber getrennte CLI-Agenten:

```text
Anforderungen (vollstaendig)
  -> Tests-first  (Worker A: tester, schreibt Tests nur aus Anforderungen)
  -> Implementierung (Worker B / Koordinator: developer, macht Tests gruen)
  -> Abschluss-Review (Worker C: reviewer, prueft Anforderungen <-> Tests <-> Code)
     (Doku laeuft ueber alle Stufen parallel mit)
```

- **Tests zuerst, aus den Anforderungen abgeleitet** — nicht aus vorhandener Implementierung. Test-Worker kennt Akzeptanzkriterien, nicht den spaeteren Code.
- **Implementierung durch ganz anderen CLI-Worker/Koordinator** als den Test-Autor. Code an Tests anpassen, nicht Tests an Code; Implementierer kann Tests nicht "passend" umbiegen.
- **Abschluss-Review durch dritten, unbeteiligten Worker**: prueft die drei Ebenen gemeinsam — decken Tests die Anforderungen ab, erfuellt Code die Tests, passt Ergebnis zum fachlichen Ziel? Testaenderung durch Implementierer = ausdrueckliches Review-Thema (Begruendung noetig).
- Testautor / Implementierer / Reviewer = drei eigene CLI-Agenten (siehe `koordination\koordinator-vs-worker.md`), koordiniert/ueberwacht vom Koordinator.
- Anforderungen unvollstaendig -> zuerst klaeren (`anforderer`/`architect`), statt spekulativ Tests/Code zu schreiben.

## AI- und Menschen-Staerken kombinieren

| Staerke | Typische Nutzung |
|---|---|
| AI | Fleissarbeit, Stacktraces lesen, Varianten skizzieren, Querverweise, erste Tests |
| Mensch | Zielbild, Historie, Fachprioritaeten, Trade-offs, Nebenwirkungen, Ownership |

Gute Nutzung: AI arbeitet vor, Mensch korrigiert Ziel/Kontext/Entscheidung. Genug manuelle Arbeit erhalten, damit Motivation, Ownership und Systemkenntnis nicht sinken.

## Produktionsgrenzen fuer Worker

Coding Agents bekommen keinen autonomen Zugriff auf Production, auch nicht als Worker in einer Schleife. Details: `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md`.

## Review-Check

- Hat jeder Worker genau eine Aufgabe und einen klaren Scope ohne Ueberlappung?
- Hat jeder Worker **vor der Fertigmeldung eine Selbst-Verifikation** gemacht (Akzeptanzkriterien einzeln durch, Tests/Checks gruen, Diff gegen Scope, bei fachlichen Aenderungen Abgleich Fachanforderung<->Code)?
- Wurde die **fachliche Konformitaet** gegen die `spec.md` (Anforderungs-Abdeckungsmatrix) geprueft, nicht nur gegen die Akzeptanzkriterien?
- Wurden Worker mit **explizitem Modell und Effort** (zwei Werte aus der Plan-Zeile) gestartet, statt auf dem globalen Default einer interaktiven Session (grosses Modell/hoher Effort) zu laufen?
- Wurde die Paketgroesse am Kontext-Budget (~100k Token) ausgerichtet — kleine kohaerente Aenderungen gebuendelt, statt je triviale Teilaufgabe einen frischen CLI-Worker zu starten?
- Hat der Koordinator die inhaltliche Arbeit (Planen, Analysieren, Programmieren) an Worker delegiert, statt sie selbst zu erledigen?
- War fuer jeden Worker/Mini-Koordinator ein Ueberwachungsintervall (30 s – 30 min) festgelegt und wurde es eingehalten bzw. bei Problemen sofort eingegriffen?
- Halten Koordinator und Worker resume-faehige Checkpoints (Status/Handoff) aktuell, sodass nach Compact/Pause weitergearbeitet werden kann?
- Wurde der Plan zuerst aus der Wissensdatenbank abgeleitet, dann auf Code-Ebene ergaenzt und erst danach umgesetzt (Planung von Umsetzung getrennt)?
- Wurden Blocker zurueckgemeldet statt mit Annahmen ueberdeckt?
- Ist der Abschluss-Review ueber einen frischen, unbeteiligten CLI-Worker (eigene Herkunft, nicht Subagent der Umsetzungs-Session, nicht umsetzender Worker) erfolgt? (Interne Subagenten *im* Review-Worker sind erlaubt/erwuenscht.)
- Haben Worker (insb. Review-Worker) parallelisierbare Fleissarbeit an **4+ eigene Subagenten** delegiert (billiger/schneller), statt alles sequenziell selbst zu erledigen oder den Koordinator unnoetig viele CLI-Worker starten zu lassen? (Ausnahme: externe Datei-/Repo-Zugriffe → eigener CLI-Worker statt Subagent)
- Wurde kein Subagent faelschlich als eigenstaendiger Worker/Koordinator behandelt (fernsteuern, eigener Auftrag, Statusmeldung)?
- War die Agent-zu-Agent-Kommunikation (Auftraege, Status, Handoffs) nach Caveman-Prinzip komprimiert, ausser bei den dokumentierten Ausnahmen?
- Ist genug manuelle Arbeit erhalten geblieben?
- Hatte kein Worker autonomen Production-Zugriff?
- Wurde der Aufgabenschnitt so gewaehlt, dass Merge-Konflikte unwahrscheinlich sind (unterschiedliche Dateien/Module je Worker, breite Refactorings vorab)?
- War die Planung vollstaendig (alle Fragen/Entscheidungen vorab gebuendelt), sodass die Umsetzung ohne Rueckfragen autonom laufen konnte? Rueckfrage zwischen Planung und Umsetzung = Planungsmangel.
- Liefen Worker autonom in den Trusted Trees (Autonomie-Flags), statt an Einzelfreigaben zu haengen?
- Hat jeder fertige Worker sein Ergebnis gemeldet und sein Fenster geschlossen (Selbstschliessung/`aidone`), sodass nur aktive Fenster offen bleiben?
- Wurde Fernsteuern ueber Session-Resume (`aisend`) statt Fenster-/Tastaturbedienung genutzt und blieb es die Ausnahme?
- Hat der Koordinator bei Teilaufgaben-Abschluss/knappem Kontext an einen Nachfolger uebergeben (`aihandoff`) und sich danach geschlossen?
