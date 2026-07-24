# Plan-Lifecycle und Reviewzyklen

## Ziel

Plaene machen laengere Arbeit wiederaufnehmbar. Ein Plan beschreibt Ziel, Scope,
Akzeptanzkriterien, Risiken, Entscheidungen und den aktuellen Stand.

## Minimaler Lebenszyklus

1. Plan anlegen
2. Ziel, Scope, Nicht-Ziele dokumentieren
3. Plan-Review-Schleife: Plan von mehreren Rollen reviewen lassen, offene Punkte
   und Fragen klaeren, erneut reviewen — so lange, bis keine Luecken und keine
   ungeklaerten Fragen mehr offen sind (siehe unten).
4. Umsetzung starten (erst nach umsetzungsreifem, luueckenlosem Plan)
5. Verifikation dokumentieren
6. Review einholen
7. Plan abschliessen oder archivieren (fertige Plaene nach `plan\_archiv\<name>\` verschieben)

Die Schritte 4-6 laufen nicht strikt nacheinander:

- **Doku laeuft parallel** zu Umsetzung, Test und Review, nicht erst am Schluss.
- **TDD, wenn die Anforderungen vollstaendig sind:** zuerst Tests aus den
  Anforderungen schreiben, dann die Umsetzung durch einen anderen CLI-Worker/
  Koordinator, am Ende Review von Anforderungen, Tests und Code. Details und
  Rollentrennung: `01-arbeitsweise\richtlinien\koordination-und-worker.md`.

## Plan-Review-Schleife (vor der Umsetzung)

Ein Plan wird vor der Umsetzung in einer Schleife gereift, bis er luueckenlos ist:

1. Plan-Entwurf erstellen.
2. Review durch mehrere Rollen (unabhaengig von der Planung), siehe
   Review-Rollen unten: Luecken, Widersprueche, unbelegte Annahmen, fehlende
   Akzeptanzkriterien und Sonderfaelle finden — sowie **fachliche Vollstaendigkeit**:
   deckt der Plan (Anforderungs-Abdeckungsmatrix) jede Fachanforderung der `spec.md`
   der Anwendung ab? Nicht abgebildete Fachanforderung = Luecke.
3. Offene Punkte/Fragen mit Doku, Code oder Mensch entscheiden und mit
   Begruendung im Plan dokumentieren.
4. Erneut reviewen; Schritte 2-4 wiederholen, bis kein Reviewer mehr offene
   Luecken oder Fragen findet.

**Keine erfundenen Annahmen:** Jede Annahme ist belegt (Doku/Code) oder eine offene
Frage, die vor der Umsetzung geklaert wird. Unbelegte Annahmen sind ein
Planungsmangel und Hauptursache fuer weggeworfene Implementierungen. Ausfuehrlich
und mit dem Front-Loading-Zusammenhang: `01-arbeitsweise\plaene.md` (Abschnitt Plan-Review-Schleife).

## Wann ein Plan Pflicht ist

- mehrere Dateien oder Module betroffen
- offene Fachfragen
- Review oder Testlauf noetig
- mehrere Rollen oder Worker beteiligt
- globale Konfigurationen oder Betriebsdaten betroffen

## Mehrere Rollen oder Worker

- Jede Teilaufgabe bekommt klaren Scope und ein pruefbares Ergebnis.
- Parallele Arbeit nur ohne Scope-Ueberlappung.
- Offene Fragen und Blocker zurueckmelden statt Annahmen zu verstecken.
- Koordinator-Laeufe duerfen lange arbeiten, wenn Status, Blocker und Handoffs sichtbar bleiben.
- Mehrschicht-Schleifen aus Umsetzung, Test, Review, Security und Doku sind der Normalfall fuer groessere Aenderungen.
- Abschluss-Review moeglichst unabhaengig von der Umsetzung halten.

## Modell und Aufwand pro Aufgabe

Nicht jede Teilaufgabe braucht das staerkste verfuegbare Modell. Kanonische Tier-Tabelle (Pflichtfeld je Unteraufgabe/Worker-Auftrag):

| Tier | Wofuer | Modell | Effort |
|---|---|---|---|
| `klein` (Default) | read-only Review, Tests, Doku, einfache/mechanische Analyse | `claude-sonnet-5` | `low` |
| `standard` | normale Entwicklung/Analyse/Methodik-Edits | `claude-sonnet-5` | `medium` |
| `hoch` (nur begruendet) | komplexe Architektur/kritische Logik | `claude-opus-4.8` | `high` |

Grundsatz: **so niedrig wie moeglich**; `hoch` nur mit kurzer Begruendung (Komplexitaet/Risiko). Passend zum Spawn-Skript `-Tier` (`windows-terminal\ai-spawn-direct.ps1`). Jede Zeile im Plan-Template traegt **Modell und Effort als zwei getrennte Spalten** (Tier nur als Ableitungshilfe) + kurze Begruendung; Worker werden damit gestartet (`--model`/`--effort`), nie auf dem globalen Default einer interaktiven Session. Details zum Auftragsformat: `01-arbeitsweise\richtlinien\koordination-und-worker.md`.

## Review-Rollen

| Fokus | Typische Fragen |
|---|---|
| Fachliche Konformitaet | Erfuellt der Code **jede** Fachanforderung der `spec.md` (Anforderungs-Abdeckungsmatrix), nicht nur die Akzeptanzkriterien? |
| Qualitaet | Ist die Aenderung lesbar, klein und konsistent? |
| Security | Tauchen Secrets, PII oder riskante Defaults auf? |
| Architektur | Passt die Aenderung zu Schichten, Grenzen und Vertraegen? |
| Test | Ist die Verifikation glaubwuerdig und deckt sie die Fachanforderungen ab? |

## Feedback-Loop: wiederkehrende Findings schaerfen die Planung

Findings aus Reviews sind nicht nur fuer die aktuelle Aenderung da. Taucht dieselbe
Fehlerklasse mehrfach auf (z. B. immer wieder Abweichung Fachanforderung<->Code,
vergessene Grenzfaelle, Scope-Drift), wird sie an der **Wurzel** behoben, statt sie
jedes Mal teuer im Review erneut zu fangen:

- Wiederkehrende Fehlerklasse -> als Pruefpunkt in die Plan-/Umsetzungs-Checkliste
  bzw. die Akzeptanzkriterien-/Abdeckungsmatrix-Vorlage aufnehmen.
- So verschiebt sich der Fehlerfang von teuer (spaetes, unabhaengiges Review) nach
  billig (bessere Planung + Worker-Selbst-Verifikation vor der Fertigmeldung, siehe
  `01-arbeitsweise\richtlinien\koordination\worker-lebenszyklus.md`).

## Gute Akzeptanzkriterien

- pruefbar
- konkret
- am Ergebnis orientiert
- mit Befehl, Datei oder beobachtbarem Verhalten belegbar

Schlecht: `Alles funktioniert.`
Gut: `Der Health-Endpunkt antwortet lokal mit HTTP 200.`

## Abschluss

Ein Plan ist fertig, wenn:
- Akzeptanzkriterien erledigt oder bewusst verworfen sind
- offene Risiken dokumentiert sind
- Tests oder manuelle Checks nachvollziehbar sind
- Doku aktuell ist
- keine blockierenden Findings offen sind
- generierter Code ist von verantwortlichen Devs verstanden; ein unbeteiligter
  Agent hat ihn reviewed, und vor Push/Merge in einen gemeinsamen Branch ist
  zusaetzlich ein menschliches Review erfolgt

Abschluss-Lauf (Push, Merge-Reihenfolge, Release-Version, PR-Hygiene): `01-arbeitsweise\richtlinien\plan-abschluss-release.md`
