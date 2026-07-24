---
type: plan
title: <Titel>
status: offen
updated: <YYYY-MM-DD>
---

# <Titel>

## Ziel
<Was soll am Ende wahr sein? 1-2 Saetze.>

## Kontext
- Ausgangslage:
- Betroffene Pfade/Programme:
- Nicht-Ziele:

## Branch
- Ticket: <Ticketnummer oder "kein Ticket (Refactoring/Fix)">
- Feature-Branch: <feature/TICKET-kurzbeschreibung oder refactor/... bzw. fix/...>
- Working Tree: <Pfad des git worktree fuer diesen Plan>

## Akzeptanzkriterien
- [ ] <pruefbares Ergebnis>
- [ ] <pruefbares Ergebnis>

## Anforderungs-Abdeckung (Fachspec -> Implementierung)
Pflicht bei fachlichen Aenderungen: jede betroffene Fachanforderung aus der `spec.md`
der Anwendung auf Akzeptanzkriterium, Test und geplante Code-Fundstelle abbilden.
Luecke = Plan nicht umsetzungsreif. Reviewer/Tester pruefen Code<->spec entlang
dieser Matrix, nicht nur gegen die Akzeptanzkriterien.

| Fachanforderung (spec.md-Ref) | Akzeptanzkriterium | Test (Fall/Datei) | Code-Fundstelle (geplant) | Status |
|---|---|---|---|---|
| <Ref/Kurzbeschreibung> | <AK> | <Testfall> | <Datei/Klasse/Methode> | offen |

Keine fachlichen Aenderungen -> "keine Fachanforderung betroffen" (begruendet).

## Doku-Update
- Betroffene Artikel/READMEs: <Pfade oder "keine Doku betroffen">
- Zu pruefen und ggf. mitzuziehen: arc42/Architektur, Steckbrief, `Spec`
  (detaillierte Fachanforderungen je Anwendung), Schnittstellen/Formate, Glossar,
  `<Firma>\<Produkt>\regeln.md`
- [ ] Doku nach Umsetzung aktualisiert (Doku laeuft parallel, nicht erst am Ende)

## Schritte
- [ ] Verstehen: docs-first — erst Wissensdatenbank-/Doku-Artikel lesen, Quellcode nur bei Bedarf
- [ ] Planen: offene Fragen und Risiken klaeren; Plan bei der Verfeinerung **konkret
      an der bestehenden Implementierung verifizieren** (Existenz von Typen/
      Signaturen/Dateien belegen, Reuse-vs-Neu, Namenskonventionen aus dem Code) —
      vor der Umsetzung. Unbelegte Annahmen = Planungsmangel.
- [ ] Umsetzen: vereinbarten Scope bearbeiten
- [ ] Testen: automatische oder manuelle Checks dokumentieren
- [ ] Selbst-Verifikation (Worker, vor Fertigmeldung): Akzeptanzkriterien einzeln durch, Tests gruen, Scope-Diff, Abgleich Fachanforderung<->Code (Anforderungs-Abdeckung)
- [ ] Review: Ergebnis gegen Ziel, fachliche Konformitaet (spec.md), Sicherheit und Doku pruefen

## Entscheidungen und Belege (vorab gebuendelt)
- Entscheidung/Annahme: <getroffen, mit Begruendung — jede Annahme aus Doku/Code belegt>
- Implementierung geprueft: <existierende Typen/Signaturen/Konventionen, Reuse-vs-Neu>
- Vor Umsetzung zu klaeren: <offene Punkte — muessen vor dem autonomen Lauf beantwortet sein>

## Zerlegung: Teilplaene und Unteraufgaben (bei mehreren Workern)
Plan → Teilplaene → Unteraufgaben. Jede Unteraufgabe muss von einem frisch
gestarteten Worker **autonom** (ohne Rueckfrage) abarbeitbar sein: eigener Scope,
betroffene Dateien, Akzeptanzkriterien, Abhaengigkeiten, Rolle, **Modell und Effort
(zwei getrennte Werte)**. Nicht ueberall das staerkste Modell nutzen; Worker mit
diesen zwei Werten starten (`--model`/`--effort`), nie auf dem globalen Default
einer interaktiven Session. Paketgroesse am Kontext-Budget (~100k Token) ausrichten:
kleine kohaerente Aenderungen buendeln statt je Teilaufgabe einen frischen Worker.
Details: `01-arbeitsweise\plaene.md`, `01-arbeitsweise\richtlinien\plan-lifecycle-und-reviewzyklen.md`.

Sind mehrere Anwendungen/Artefakte beteiligt (Repo, NuGet-Paket, JAR, Modul,
Plugin, Shared-Lib), bekommt **jede** eine eigene Sektion mit eigener Liste,
eigenem Scope/Working Tree/Branch und eigenen Akzeptanzkriterien. Abhaengigkeiten
zwischen Sektionen (z. B. Lib vor Consumer, Schnittstellenvertrag vor
Implementierung) explizit notieren.

### Anwendung/Artefakt: <Name>  (Repo/Lib/Working Tree/Branch) — Status: offen
- Scope: <Repo/Pfad/Branch>
- Akzeptanzkriterien: <pruefbar>

Jede Zeile traegt einen eigenen Status (resume-faehig, fortlaufend gepflegt):
`offen` | `in Arbeit` | `blockiert` | `fertig`. „Stand/Notiz" haelt den letzten
sicheren Stand fest (Datum/Branch/Datei), damit nach Unterbrechung (Budget-/
Ratelimit, Pause, Worker-Neustart) nahtlos weitergemacht werden kann.

| Teilplan / Unteraufgabe | Rolle | Haengt ab von | Modell | Effort | Tier/Begruendung | Status | Stand/Notiz |
|---|---|---|---|---|---|---|---|
| <Kurzbeschreibung> | <z. B. developer> | <- / andere Aufgabe> | <claude-sonnet-5> | <low\|medium\|high> | <klein\|standard\|hoch — warum?> | offen | <letzter sicherer Stand> |

<!-- Weitere Anwendungen/Artefakte je eigene Sektion; bei nur einer Anwendung genuegt eine einzelne Liste. -->

## Risiken und offene Fragen
- Risiko:
- Frage:

## Status
- Stand gesamt: offen | in Arbeit | blockiert | fertig
- Naechster Schritt:

### Resume-Checkpoint (fuer nahtlose Wiederaufnahme nach Unterbrechung)
- Aktuelle Unteraufgabe (Sektion/Zeile):
- Letzter sicherer Stand (Branch/Working Tree/Datei):
- Abhaengigkeiten erledigt?:
- Blocker:

Gesamtstatus ist erst `fertig`, wenn alle Abschnitts-/Unteraufgaben-Status auf
`fertig` stehen. Detaillierter laufender Stand: `status.md` im Planordner
(`01-arbeitsweise\plaene.md`, Abschnitt Statusdatei / Fortschritt je Abschnitt).
