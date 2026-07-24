# Git-Workflow

## Ziel

Kurze, nachvollziehbare Historie. Jede Aenderung soll ihren Zweck, ihren Scope und ihren
Pruefzustand klar erkennen lassen.

## Working Tree und Feature-Branch pro Plan

- Grundsaetzlich mit eigenen `git worktree`s statt Branch-Wechsel im selben
  Arbeitsverzeichnis arbeiten (kein Stashen/Wechseln mitten in der Arbeit).
- Pro Plan genau ein gemeinsamer Feature-Branch als Ziel (z. B.
  `feature/<ticket>-<kurzbeschreibung>`). Alle Aenderungen, die zu diesem Plan
  gehoeren, laufen dort am Ende zusammen.
- **Massiv parallele Verarbeitung ist das Ziel:** Jeder Worker bekommt einen
  eigenen kurzlebigen Worktree mit eigenem Arbeits-Branch, abgezweigt vom
  gemeinsamen Feature-Branch (`git worktree add ..\<worker> -b
  <feature-branch>-<worker> <feature-branch>`). Worker arbeiten parallel und
  committen in ihren eigenen Branch — kein Warten aufeinander noetig.
- Am Ende eines Worker-Auftrags (oder in regelmaessigen Zwischenschritten) merged
  der Koordinator den Worker-Branch in den gemeinsamen Feature-Branch und
  entfernt den Worker-Worktree (`git worktree remove`). Beim Zusammenfuehren die
  WIP-Historie des Workers zu **wenigen/einem Commit je Repo squashen** (siehe
  Abschnitt „Commits").
- **Aufgabenschnitt ist Koordinator-Verantwortung:** Aufgaben so zuschneiden,
  dass unterschiedliche Worker moeglichst unterschiedliche Dateien/Module
  bearbeiten — das minimiert Merge-Konflikte. Ueberlappender Scope zwischen
  parallelen Workern ist zu vermeiden.
- Sind vor der Parallelisierung breite Refactorings noetig, die viele Dateien
  gleichzeitig anfassen wuerden (z. B. Umbenennungen, Struktur-Umbau), diese
  **zuerst** und sequenziell in den gemeinsamen Feature-Branch bringen, bevor
  die eigentliche parallele Arbeit startet. Laesst sich eine Ueberlappung nicht
  vermeiden, die betroffenen Teilaufgaben stattdessen sequenziell statt
  parallel abarbeiten, statt Merge-Konflikte in Kauf zu nehmen.
- Git erlaubt nicht, denselben Branch gleichzeitig in zwei Worktrees
  auszuchecken. Deshalb bekommt jeder Worker einen eigenen Branch statt direkt
  im gemeinsamen Feature-Branch zu arbeiten; nur das Mergen in den gemeinsamen
  Feature-Branch selbst muss serialisiert werden (ein Merge nach dem anderen,
  durch den Koordinator).
- Branch-Name idealerweise mit Ticketnummer, z. B. `feature/PROJ-1234-kurzbeschreibung`.
  Fehlt beim Planstart eine Ticketnummer, danach fragen. Refactorings und Fixes duerfen
  aber auch ohne Ticketnummer umgesetzt werden, z. B. `refactor/kurzbeschreibung` oder
  `fix/kurzbeschreibung`.
- Nach Abschluss des Plans: alle Worker-Worktrees/-Branches entfernt und in den
  richtigen Ticket-/Plan-Branch integriert (siehe „Branching-Ziel"), der
  gemeinsame Feature-Branch wie gewohnt reviewen und mergen/loeschen.

## Ticket-Worktree-Konvention (Multi-Repo, Windows)

Bei Tickets mit mehreren Repos wird **pro Repo ein eigener Ticket-Worktree** angelegt —
stabil fuer die gesamte Ticket-Laufzeit, nicht mit kurzlebigen Worker-Worktrees fuer
Parallelisierung verwechseln:

- **Pfad-Konvention:** `C:\projects-wt\<repo>-<ticket>` (ausserhalb von `C:\projects\`)
- **Gemeinsame `.git`:** der Ticket-Worktree teilt die `.git` mit dem Haupt-Repo unter
  `C:\projects\<repo>` — Commits liegen dort zentral.
- **Haupt-Repo bleibt unveraendert:** `C:\projects\<repo>` steht auf seinem eigenen Branch
  (z. B. `main`); der Feature-Branch erscheint dort nicht automatisch im Arbeitsverzeichnis.
- **Commits ueberleben Worktree-Loesch:** `git worktree remove` entfernt nur das
  Arbeitsverzeichnis; Branch-Ref und Commits bleiben in der gemeinsamen `.git` erhalten,
  bis der Branch explizit geloescht wird.

### Sichere Loeschreihenfolge am Planende

1. **Integration:** Feature-Branch pushen + PR/Merge abschliessen.
2. **Paket-Abloesung:** Dev-Pakete (falls vorhanden) durch offizielle Releases ersetzen.
3. **Worktree entfernen:** `git worktree remove C:\projects-wt\<repo>-<ticket>` +
   `git worktree prune`.
4. **Aufraeumen:** verwaiste Worktrees pruefen (`git worktree list`); Haupt-Repo auf
   `main` aktualisieren.

Reihenfolge einhalten: Worktree-Loesch vor Integration verliert keine Commits (sie sind in
der gemeinsamen `.git` gesichert), aber der Stand fehlt im Arbeitsverzeichnis — deshalb
**erst integrieren, dann loeschen**.

## Push-Timing bei Cross-Repo-Kaskaden

Bei Tickets mit mehreren Repos (z. B. Lib + Consumer):

- **Variante A — Gebuendelt am Planende:** alle Repo-Branches werden erst dann gepusht,
  wenn alle lokal fertig und gruen sind. Vorteil: kein halbfertiger Zustand im Remote.
- **Variante B — Pro Repo sobald fertig:** jeder Branch wird gepusht, sobald sein Repo
  gruen + reviewed ist. Ermoeglicht frueheres CI-Feedback je Repo.
- **Entscheidung trifft der Mensch** — Koordinator klaert die Variante vor dem ersten Push.
- **Kein Push ohne explizit bestaetigte Remote-URL + Branch-Name** (besonders wichtig bei
  mehreren Repos im gleichen Terminal-Kontext; falsche Zielkombination moechte vermieden werden).
- Nach "fertig + reviewt" (unabhaengiger Agent-Review abgeschlossen) darf der Koordinator Push + PR automatisch ausfuehren; der menschliche Review beginnt am PR und bleibt Merge-Gate.
- Kein Force-Push auf gemeinsame Feature-Branches.

## Branching-Ziel (Trunk-based)

- **Richtung Trunk-based:** kurzlebige Branches, schnelle Integration, wenige
  Commits. Kein langlebiges Branch-Geflecht.
- Ein Plan/Ticket wird zunaechst auf einem **Feature-Branch** erstellt und
  umgesetzt; Worker arbeiten in kurzlebigen Worktree-/Arbeits-Branches davon ab.
- **Ist ein Plan fertig, wird der Worktree-/Arbeits-Branch in den richtigen
  Ticket-/Plan-Branch integriert** (gesquasht auf wenige/einen Commit je Repo),
  danach der Feature-Branch pro Quellcode-Repo als Merge Request / PR angeboten.
- Der **Merge Request / PR enthaelt pro Quellcode-Repo nur die Hauptbeschreibung
  und wenige Commits** — nicht die volle WIP-Historie der Worker.

## Branch-Strategie

| Branch | Zweck |
|---|---|
| `main` oder `master` | geschuetzter Integrationszweig |
| `feature/...` | neues Verhalten |
| `fix/...` | Bugfix |
| `refactor/...` | Strukturarbeit ohne Verhaltensaenderung |
| `docs/...` | Dokumentationsaenderungen |

Der konkrete Praefix ist zweitrangig; wichtiger ist ein sprechender Name.

## Commits

- Ein Commit = ein sauber abgegrenzter Gedanke.
- Keine halbfertigen oder roten Zustaende committen.
- Keine Misch-Commits aus Feature, Refactor und Fix, wenn sich das sauber trennen laesst.
- Commit-Text beschreibt die echte Aenderung, nicht nur das Ticket.

### Commit-Message: kurz halten (Pflicht)

- **Einzeiler**, hoechstens ein bis zwei Zeilen. Kein langer Fliesstext, keine
  Detail-/Stichpunkt-Aufzaehlung aller Einzelaenderungen. Zweck + Scope reichen.
- **Selbstverstaendliches nicht mit-beschreiben.** Dass Unit-Tests geschrieben/
  gruen sind, gehoert NICHT in die Message — Tests sind immer Pflicht.
- **Kein `Co-authored-by`-Trailer** (kein `Co-authored-by: Copilot ...` und kein
  anderer Agenten-/Tool-Trailer). Commits tragen keine Agenten-Signatur.

Beispiel (gut):

```text
Fix: stop workflow when validation fails
```

Beispiel (schlecht — zu lang, Selbstverstaendliches, Trailer):

```text
Feat: KETRX-Export mit Header/Trailer, Mandant-Enum, Whitelist, 46 Unit-Tests gruen,
Review durchgefuehrt, Doku aktualisiert
...
Co-authored-by: Copilot <...>
```

### Wenige Commits pro Branch/Repo (Pflicht)

- Unsere Aufgaben/Tickets sind klein — ein Worktree-/Arbeits-Branch traegt am Ende
  **wenige Commits** (im Normalfall genau einen pro Repo).
- Zwischen-/WIP-Commits waehrend der Umsetzung sind erlaubt, werden aber vor der
  Integration zu **einem (oder wenigen) Commit(s) je Repo gesquasht**; die
  Squash-Message folgt den Kurz-Regeln oben.
- Ergebnis: Der Merge Request / PR enthaelt **pro Quellcode-Repo nur die
  Hauptbeschreibung und wenige Commits**, nicht die volle WIP-Historie.

## Standardablauf

1. Aktuellen Stand holen.
2. Eigenen Branch anlegen.
3. Kleine Aenderung umsetzen.
4. Relevante Tests oder Checks ausfuehren.
5. Committen.
6. Vor Merge rebasen oder sauber synchronisieren.
7. Review einholen.
8. Branch nach Merge entfernen.

## Merge-Regeln

- Lineare Historie bevorzugen.
- Merge-Commits nur, wenn Teamregeln sie bewusst wollen.
- Review und gruenes CI vor dem Merge.
- **Vor Integration squashen:** WIP-/Zwischen-Commits eines Worktree-/Arbeits-
  Branches werden zu wenigen/einem Commit je Repo zusammengefasst, sodass der
  Merge Request / PR nur Hauptbeschreibung + wenige Commits pro Repo enthaelt.

## Nie committen

- Build-Ausgaben wie `bin/`, `obj/`, `dist/`
- IDE-Ordner
- `.env` und aehnliche Geheimnisdateien
- Lokale Dumps, Crash-Logs, Exportdateien

## Review-Check

- Ist der Branch-Name sprechend?
- Ist jeder Commit in sich korrekt?
- Ist die Commit-Message kurz (Einzeiler, max. 1-2 Zeilen) und ohne
  Selbstverstaendliches (keine „Tests gruen"-Beschreibung)?
- Kein `Co-authored-by`-/Agenten-Trailer in den Commits?
- Wenige Commits je Repo (WIP vor Integration gesquasht)?
- Ist klar, wie die Aenderung validiert wurde?
- Sind Secrets, generierte Dateien oder lokale Artefakte draussen geblieben?

Abschluss-Lauf (Definition of Done je Repo, Release-Version, Pre-Push-Hygiene, Push-Gate, Merge-Reihenfolge): `01-arbeitsweise\richtlinien\plan-abschluss-release.md`
