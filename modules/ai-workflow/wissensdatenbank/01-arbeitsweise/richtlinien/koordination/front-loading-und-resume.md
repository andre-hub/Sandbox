# Koordination — Front-Loading, Wartepositionen, Resume-Checkpoints

Teil von `01-arbeitsweise\richtlinien\koordination-und-worker.md` (Hub).

## Autonomie-Ziel und Front-Loading

Ziel: moeglichst lange, ununterbrochene autonome Arbeit (Richtwert: ~8 h/voller Arbeitstag ohne Eingriff). Dazu **so frueh/viel wie moeglich in Plan+Doku klaeren** — alle offenen Fragen, Fach-/Designentscheidungen waehrend Erstellung/Ausarbeitung/Verfeinerung **gebuendelt am Anfang** sammeln + klaeren, nicht haeppchenweise waehrend der Umsetzung.

- Offene Fragen/fachliche Detail-Luecken als **Sammlung offener Fragen** fuehren und **erst nach Ausschoepfen aller autonom beschaffbaren Infos** (Aufgabenstellung, Doku, Code) **vor** Umsetzungsstart klaeren. Sammlung **einzeln nacheinander interaktiv** mit dem Menschen/Product-Owner abfragen (eine Frage nach der anderen); jede Antwort darf Folgefragen ausloesen, bis vollstaendig geklaert. **Mit Auswahloptionen** (Multiple Choice mit Empfehlung), wo moeglich, und **Product-Owner-tauglich** formuliert (fachlich, aus Nutzersicht, ohne Tech-Jargon; Trade-offs als fachliche Konsequenzen), damit auch ein nicht technisch versierter PO entscheiden kann. Antworten/Entscheidungen -> Plan. Als eigene Stufe der Plan-Erstellung: `01-arbeitsweise\plaene.md` (Stufe 3 — Interaktive Klaerungsrunde).
- Entscheidungen/Annahmen/Akzeptanzkriterien/Scope/Nicht-Ziele vollstaendig im Plan (`01-arbeitsweise\plaene.md`), bevor ein Umsetzungs-Worker startet.
- **Merksatz:** Fachliche Rueckfrage zwischen Planung und Umsetzung = Planung war unvollstaendig = Planungsmangel -> zurueck in die Planungsphase, nicht in den laufenden autonomen Umsetzungslauf.
- Nur echte Blocker (fehlende Zugaenge, widerspruechliche Vorgaben, riskante Aktionen) duerfen laufenden Worker anhalten; alles Vorhersehbare vorab klaeren.

## Wartepositionen minimieren

Koordinator wartet nicht blockierend, arbeitet asynchron:

- Worker laufen autonom (Flags in `koordination\worker-lebenszyklus.md`), melden Ergebnis ueber Handoff-Datei; Koordinator pollt Registry/Status (`aiworkers`) statt im Leerlauf zu warten.
- Unabhaengige Teilaufgaben parallel starten, nicht sequentiell abwarten.
- Statt Rueckfrage mitten im Lauf: Worker arbeitet vorab geklaerte Vorgaben ab; fehlt etwas -> Blocker im Status + wo moeglich an unabhaengiger Stelle weiter.
- Mensch gebuendelt an Entscheidungspunkten (Front-Loading), nicht Dauer-Freigabeinstanz waehrend der Umsetzung.

## Resume-faehige Checkpoints

Kontext kann jederzeit knapp werden (Compact/Zusammenfassung) oder die Arbeit wird pausiert. Koordinator + Worker halten ihren Stand fortlaufend in resume-faehigen Checkpoints in Dateien fest, nicht nur im fluechtigen Chat-Kontext:

- **Worker**: Fortschritt in Status-/Handoff-Datei des Plans (`status.md`) — aktueller Schritt, letzter stabiler Zwischenstand, naechster Schritt, offene Blocker, ggf. Worktree/Branch. Derselbe oder ein frischer Worker macht nach Compact/Pause nahtlos weiter.
- **Koordinator**: im Plan/Status — welche Worker mit welchem Auftrag laufen, welches Ueberwachungsintervall gilt, was zuletzt geprueft wurde, was als Naechstes ansteht. Orchestrierung nach Compact wiederaufnehmbar.

Guter Checkpoint beantwortet knapp: Wo stehe ich? Letzter sicherer Stand? Naechster Schritt? Was blockiert? Wo liegt der Arbeitsstand (Worktree/Branch/Dateien)? Regelmaessig aktualisieren — spaetestens vor laengeren Wartezeiten, an Phasengrenzen, bei knappem Kontext. Format/Ablage: `01-arbeitsweise\plaene.md` (Status-/Resume-Feld).
