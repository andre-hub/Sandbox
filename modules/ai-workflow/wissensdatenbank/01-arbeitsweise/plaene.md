# Plaene

Plaene machen Arbeit wiederaufnehmbar. Bewusst klein: kein Projektmanagement-System, sondern eine einfache Datei-Struktur fuer Ziele, Schritte, Status, offene Punkte.

## Wann einen Plan schreiben?

Plan, wenn mind. ein Punkt zutrifft:

- Aufgabe betrifft mehrere Dateien/Module.
- Offene Fragen, die nicht verloren gehen duerfen.
- Review oder Testlauf noetig.
- Rollen/Worker in mehreren Terminal-Tabs koordinieren.
- Globale Einstellungen, Benutzerprofile oder `C:\wissensdatenbank` werden geaendert.
- Aufgabe dauert wahrscheinlich laenger als eine kurze Sitzung.

Sehr kleine Fragen: kurze Antwort im Chat.

## Plan-Erstellung in Stufen (neues Ticket/neue Aufgabe)

Reihenfolge, nicht vermischt:

1. **Stufe 1 — Wissensdatenbank als Quelle (docs-first).** Plan zuerst aus Anwendungs-/Architektur-Doku ableiten: Steckbriefe, arc42-/ADR-Artikel, je Anwendung die `spec.md` (detaillierte Fachanforderungen), Schnittstellenbeschreibungen, Glossar, `<Firma>\<Produkt>\regeln.md`. Doku = **primaere Quelle** fuer Ziel/Kontext/betroffene Komponenten/Akzeptanzkriterien. Die `spec.md` je Anwendung beschreibt das **gesamte fachliche Verhalten** (Fachanforderungen, Regeln, Sonderfaelle, Datenfluesse) = zentrale fachliche Referenz; fehlt/luueckenhaft -> als Doku-Luecke vermerken und wo noetig zuerst schliessen. Details: `01-arbeitsweise\richtlinien\docs-first-recherche.md`. Liegt die Aufgabenstellung/Fachanforderung im **internen Ticket-/Aufgabensystem oder Wiki** (oder einem anderen internen System), wird diese Quelle proaktiv gelesen (kein `web_fetch`/`curl`, siehe `01-arbeitsweise\recherche.md`).
2. **Stufe 2 — Quellcode-Ebene ergaenzen.** Danach Plan auf Code-Ebene verifizieren/ergaenzen: exakte Signaturen, aktuelles Verhalten, betroffene Dateien/Module, Luecken/Widersprueche zur Doku (als Doku-Update vermerken). Kein Umschreiben aus dem Code, sondern Praezisierung des doku-abgeleiteten Plans. **Konkret in die Implementierung schauen** (Doku = Soll, Code = Ist), vor Umsetzung im Plan belegt:
   - **Existenz statt Annahme:** jeder genannte Typ/Klasse/Methode/Enum/Datei/API im Code belegt (Pfad/Signatur). Angenommener, nicht existierender Name = Planungsmangel.
   - **Reuse vor Neu, belegt:** bei neuem Typ/Baustein zuerst Bestandsklassen pruefen (Wiederverwenden/Erweitern); Entscheidung Neu-vs-Reuse mit Begruendung. Keine neue Abstraktion, wo Felder an bestehendem Typ genuegen.
   - **Namenskonventionen aus dem Code:** Namen (Klassen/Enums/Services/Mapper/Dateien) an vorhandenen Mustern ausrichten, nicht erfinden; richtige Abstraktionsebene (Fachdomaene vs. Datei-/Formattyp).
   - **Ebenen-/Struktur-Treue:** geplante Einordnung (Schicht/Ordner/Dispatch/Basis-Ableitung) gegen Bestandsmuster abgleichen.

   Unbelegte Annahmen = Hauptursache weggeworfener Umsetzungen. Frage erst waehrend Umsetzung -> zurueck in die Planung (Planungsmangel).
3. **Stufe 3 — GPT-5.5 Kreuzcheck des autonomen Planstands (vor PO-Fragen).** Sind Aufgabenstellung, Doku (Stufe 1) und Quellcode-Abgleich (Stufe 2) eingearbeitet, wird der Plan zuerst durch einen **separaten GPT-5.5-Worker** gegengeprueft (fachliche Vollstaendigkeit, Widersprueche, fehlende Annahmen, unklare Entscheidungen, AK-Test-Code-Abdeckung). Ergebnis: konkrete Findings + bereinigter Planentwurf. Erst danach offene Punkte fuer den Product-Owner sammeln.
4. **Stufe 4 — Interaktive Klaerungsrunde mit dem Product-Owner (gebuendelt, vor der Umsetzung).** Sind alle **autonom** beschaffbaren Informationen ausgeschoepft (Aufgabenstellung, Doku aus Stufe 1, Quellcode aus Stufe 2, GPT-5.5-Kreuzcheck aus Stufe 3), bleiben typischerweise Entscheidungen offen, die nur der Mensch/Product-Owner treffen kann (fachliche Prioritaeten, Varianten, Sonderfaelle, Trade-offs). Diese **gebuendelt** als Sammlung offener Fragen fuehren und **einzeln nacheinander interaktiv** mit dem Product-Owner klaeren:
   - **Erst autonom ausschoepfen:** nichts fragen, was aus Aufgabenstellung/Doku/Code selbst beantwortbar ist (sonst unnoetige Rueckfrage = Planungsmangel).
   - **Eine Frage nach der anderen**, nicht als Wall-of-Text; jede Antwort darf Folgefragen ausloesen, bis der Punkt geklaert ist.
   - **Mit Auswahloptionen**, wo moeglich (Multiple Choice mit klarer Empfehlung), damit der PO schnell auswaehlen kann statt Freitext zu formulieren.
   - **Product-Owner-tauglich formulieren:** fachlich, aus Nutzer-/Anwendersicht, ohne Tech-Jargon; technische Trade-offs in ihre **fachlichen Konsequenzen** uebersetzen (was bedeutet Option A vs. B fuer Nutzer/Aufwand/Risiko), nicht in Implementierungsdetails. Ein nicht technisch versierter PO muss jede Frage verstehen und beantworten koennen.
   - **Antworten -> Plan** (Abschnitt „Entscheidungen", mit Begruendung), damit die Umsetzung anschliessend rueckfragefrei autonom laeuft. Fuehrt die Rolle `anforderer` (Product-Owner-Aufgaben): `01-arbeitsweise\rollen\anforderer.md`.
5. **Stufe 5 — Umsetzung getrennt vom Planen.** Erst wenn Plan aus Stufe 1+2 steht, der GPT-5.5-Kreuzcheck (Stufe 3) eingearbeitet ist und die Klaerungsrunde (Stufe 4) abgeschlossen ist, uebernimmt ein **anderer, frisch gestarteter Worker** die Umsetzung. Planung, Umsetzung, Abschluss-Review = **getrennte frische Worker** (Planer setzt nicht selbst um, Umsetzer reviewt sich nicht selbst); im Koordinator-Modus setzt der Koordinator nicht selbst um. Mechanik: `01-arbeitsweise\richtlinien\koordination-und-worker.md` (Aufgabenteilung Koordinator/Worker).

## Plan-Struktur: Teilplaene, Unteraufgaben und Anwendungs-Sektionen

Plan so weit zerlegen, dass jede Unteraufgabe **vollstaendig autonom** (ohne Rueckfrage) abarbeitbar ist. Grobe, mehrdeutige Schritte = Planungsmangel (erzeugen genau die Umsetzungsfragen, die vermieden werden sollen).

- **Zerlegung in Ebenen:** Plan -> Teilplaene -> Unteraufgaben. Teilplan buendelt zusammenhaengende Arbeit (Feature/Schicht/Anwendung); Unteraufgabe = kleinste, einem Worker zuweisbare Einheit mit eigenem Scope, Dateien, Akzeptanzkriterien, Entscheidungen.
- **Selbsttragend:** jede Unteraufgabe nennt Scope/betroffene Dateien, erwartetes Ergebnis, Abhaengigkeiten, Rolle, **Modell und Effort explizit** (zwei getrennte Angaben, mit kurzer Begruendung der Tier-Wahl) — genug, dass ein frischer Worker sie ohne den Rest des Plans starten kann.
- **Modell/Aufwand (Pflichtfeld, so niedrig wie moeglich):**

  | Tier | Wofuer | Modell | Effort |
  |---|---|---|---|
  | `klein` (Default) | read-only Review, Tests, Doku, einfache/mechanische Analyse | `claude-sonnet-5` | `low` |
  | `standard` | normale Entwicklung/Analyse/Methodik-Edits | `claude-sonnet-5` | `medium` |
  | `hoch` (nur begruendet) | komplexe Architektur/kritische Logik | `claude-opus-4.8` | `high` |

  `hoch` nur mit kurzer Begruendung (Komplexitaet/Risiko). Passend zum Spawn-Skript `-Tier` (`windows-terminal\ai-spawn-direct.ps1`).

  **Tier-Auswahl-Leitplanken:** interaktive Koordinator-Session laeuft bewusst auf `claude-opus-4.8` (bis auf Weiteres, Orchestrierung/Ueberblick) — setzt aber nichts selbst um. Alle anderen Aufgaben (Worker): so niedrig wie moeglich bei noch guter Qualitaet — `claude-sonnet-5 low` (Tier `klein`) ist fuer viele Worker-Taetigkeiten (Doku, Tests, Reviews, einfache Entwicklung, Recherche) voll ausreichend und Default. Architektur-Aufgaben (`architect`/`enterprise-architect`) brauchen i. d. R. Tier `hoch` (`claude-opus-4.8`). Obige Tier-Tabelle bleibt Single Source of Truth; diese Leitplanken stellen nur die Auswahl klar.

  **Modell und Effort als zwei getrennte Plan-Spalten (verbindlich).** Der Tier-Name ist nur Ableitungshilfe — im Plan-Template stehen **Modell** und **Effort** als **zwei eigene Spalten** (z. B. `claude-sonnet-5` / `low`), damit der Koordinator den Worker direkt und eindeutig mit `--model`/`--effort` startet. Grund: ohne explizite Werte laeuft eine Session auf dem globalen CLI-Default (grosses Modell, hoher Effort) — teuer und langsam. **Umsetzung nie in einer interaktiven Koordinator-Session** (die setzt kein `--model`/`--effort`), sondern immer als frisch gestarteter Worker mit den zwei Werten aus der Plan-Zeile.

- **Paketgroesse am Kontext-Budget ausrichten (~100k Token), nicht kuenstlich zerstueckeln:** Teilaufgaben so schneiden, dass ein Umsetzungs-Worker mit rund 100k Token nutzbarem Kontext sauber arbeitet. Mehrere **kleine, kohaerente** Aenderungen (z. B. ein paar Klassen/Properties im selben Modul/Datenmodell) gehoeren in **einen** Worker, statt je triviale Teilaufgabe einen frischen CLI-Worker zu starten — der wiederholte Kontext-Neuaufbau (Doku+Plan+Code neu lesen) kostet mehr als er spart und erzeugt Integrationsfehler durch Kontextverlust. Ein Worker darf **laenger laufen** und mehrere zusammenhaengende Unteraufgaben abarbeiten; **Subagenten** uebernehmen parallelisierbare Fleissarbeit und halten den Haupt-Kontext schlank (nur kompakte Handoffs zurueck). Erst frisch starten, wenn der Kontext wirklich knapp wird (Richtwert am ~100k-Budget) oder ein sauberer, unbeteiligter Blick noetig ist (Review). Nur **grosse/breite oder ueberlappende** Aufgaben zwingend trennen.
- **Tempo-/Aufwandsbudget je Unteraufgabe:** grobe Erwartung festhalten — kleine Codeaenderung: Minuten; groessere kohaerente Aufgabe: bis wenige Stunden (kleine Codebasis). Laeuft ein Worker deutlich laenger/teurer ohne sichtbaren Fortschritt, ist das ein Signal: Paket zu gross oder Plan unklar -> stoppen, Blocker im Status festhalten, re-scopen statt endlos weiterrechnen.
- **Mehrere Repos/Anwendungen -> eigener Unterplan-Ordner je Artefakt:** jede eigenstaendig gebaute/versionierte Einheit (Anwendung, Repo, NuGet, JAR, Modul, Plugin, Shared-Lib) bekommt einen eigenen Unterplan-Ordner `plan\<name>\<anwendung>\` mit `plan.md` + `status.md` (eigener Scope, eigene Teilplaene/Unteraufgaben, eigene Akzeptanzkriterien). Der Hauptplan `plan\<name>\plan.md` = **nur Uebersicht**: Ziel, Kontext, Gesamt-Akzeptanzkriterien, Abhaengigkeits-/Reihenfolge-Matrix, Verweise auf die Unterplaene, Gesamtstatus. `plan\<name>\status.md` = Gesamt-Resume-Checkpoint. Ein-Repo-Plaene: eine Datei genuegt.
- **Abhaengigkeiten zwischen Sektionen** (z. B. Lib zuerst, dann Consumer; Schnittstellenvertrag vor Implementierung) explizit notieren (Reihenfolge/Parallelitaet).
- **Paket-produzierende Repos zuerst umsetzen (Kaskaden-Kopf):** Repos, die ein Paket erzeugen (z. B. NuGet-Lib), das Downstream-Repos konsumieren, sind der Kopf der Kaskade — nicht parallel-gleichrangig einplanen. Strategie:
  - Upstream-Repo zuerst fertigstellen (code-complete + gruen).
  - Sobald fertig: `<worktree>` aufloesen, `<feature-branch>` pushen (nach expliziter Freigabe, kein Force), PR eroeffnen. Die CI publiziert das Paket frueh in die interne Registry.
  - Downstream-Implementierungen **starten oder laufen bereits parallel** (gegen lokalen Dev-Feed oder bald publiziertes Paket) — kein Blockieren auf den Upstream-Merge.
  - Nutzen: Paket frueh verfuegbar → Downstream-Pipelines werden frueher gruen → kuerzere kritische Kette, weniger Wartezeit am Planende.
  - Vollstaendige Push-/Re-Pin-/PR-Mechanik und Merge-Reihenfolge: `01-arbeitsweise\richtlinien\plan-abschluss-release.md`.
- Service-/repo-uebergreifend: `enterprise-architect` legt Schnittstellenvertraege fest, bevor in den Sektionen umgesetzt wird (`01-arbeitsweise\rollen.md`).

## Fortschritt je Abschnitt markieren (resume-faehig)

Damit die Abarbeitung jederzeit unterbrechbar + nahtlos fortsetzbar ist (Budget-/Ratelimit, Compact, Pause, Worker-Neustart), traegt **jeder Teilplan und jede Unteraufgabe einen eigenen Status** — nicht nur der Plan als Ganzes.

- Status: `offen` | `in Arbeit` | `blockiert` | `fertig`, mit kurzem Stand/Notiz-Feld zum letzten sicheren Stand (Datum, Branch/Working Tree/Datei).
- **Fortlaufend** aktualisieren: `fertig` erst, wenn Akzeptanzkriterien erfuellt + Aenderungen gesichert (committet/gestasht).
- **Wiederaufnahme:** frischer Worker/Koordinator nimmt erste nicht-`fertige` Unteraufgabe, deren Abhaengigkeiten `fertig` sind, und macht dort weiter — ohne den ganzen Plan neu zu verstehen.
- Zwei Ebenen: **Abschnitts-Status im Plan** (`plan.md`) = *was* fertig ist; **Resume-Checkpoint in `status.md`** = *wo genau* der Worker steht (`01-arbeitsweise\richtlinien\koordination-und-worker.md`, Resume-faehige Checkpoints). Beide aktuell halten (vor Wartezeiten, an Phasengrenzen, bei knappem Kontext).
- Mehrere Sektionen: jede fuehrt eigenen Fortschritt; Plan-Gesamtstatus `fertig` erst, wenn alle Sektionen `fertig`.

## Umsetzungsreife und Front-Loading

Ziel: moeglichst lange autonome Umsetzung (Richtwert: voller Arbeitstag). Deshalb am Anfang **so viel wie moeglich** klaeren + in den Plan legen — gebuendelt, nicht haeppchenweise. Offene Fragen/fachliche Luecken als **Sammlung offener Fragen** fuehren, **vor** Umsetzungsstart **einzeln nacheinander interaktiv** mit dem Menschen klaeren (Folgefragen erlaubt), Antworten -> Plan (Abschnitt „Entscheidungen"). Mechanik/Merksatz: `01-arbeitsweise\richtlinien\koordination-und-worker.md` (Front-Loading).

Ein Plan ist **umsetzungsreif**, wenn ein Worker ihn ohne Rueckfragen autonom abarbeiten kann. Pruefen:

- Ziel, Scope, Nicht-Ziele eindeutig?
- Alle Entscheidungen getroffen + mit Begruendung/Annahme festgehalten?
- Akzeptanzkriterien pruefbar?
- Betroffene Dateien/Komponenten + Doku-Update benannt?
- Vorhersehbare Sonderfaelle/Blocker vorab entschieden?

**Merksatz:** Fachliche Rueckfrage zwischen Planung und Umsetzung = Planung war unvollstaendig = Planungsmangel. Nur echte Blocker (fehlende Zugaenge, widerspruechliche Vorgaben, riskante Aktionen) duerfen die autonome Umsetzung anhalten.

## Plan-Review-Schleife (bis luueckenlos, vor der Umsetzung)

Plan **nicht** nach dem ersten Entwurf umsetzen. Vor der Umsetzung Schleife gegen Luecken + erfundene Annahmen:

1. **Plan-Entwurf** (Stufe 1+2).
2. **Review durch mehrere Rollen** (unabhaengig von der Planung): anforderer, architect, security, reviewer, tester pruefen je aus ihrer Sicht auf Luecken, Widersprueche, unbelegte Annahmen, fehlende Akzeptanzkriterien, nicht bedachte Sonderfaelle.
3. **Offene Punkte/Fragen klaeren** — mit Doku, Code oder Mensch entscheiden, Entscheidung + Begruendung in den Plan. Fragen an den Menschen **einzeln nacheinander interaktiv** (Folgefragen erlaubt), nicht als Wall-of-Text (siehe Front-Loading).
4. **Erneutes Review** des ergaenzten Plans.
5. **2-4 wiederholen**, bis kein Reviewer mehr offene Luecken/Fragen findet. Erst dann umsetzungsreif.

**Fachliche Vollstaendigkeit gegen die Fachspec (Anforderungs-Abdeckung).** Groesster Fehlerherd sind nicht Security-Luecken, sondern **Abweichungen zwischen Fachanforderung und Implementierung**, die durch den Review rutschen, weil er nur gegen die (evtl. unvollstaendigen) Akzeptanzkriterien prueft. Gegenmittel: jede Fachanforderung aus der `spec.md` der betroffenen Anwendung wird im Plan auf ein Akzeptanzkriterium, einen Test und eine geplante Fundstelle im Code abgebildet — als **Anforderungs-Abdeckungsmatrix** (Vorlage unten im Template). Ist eine Fachanforderung nicht in der Matrix abgebildet, ist der Plan **nicht umsetzungsreif**. Reviewer und Tester pruefen spaeter entlang dieser Matrix die Konformitaet Code<->`spec.md`, nicht nur gegen die AK (`01-arbeitsweise\rollen\reviewer.md`, `01-arbeitsweise\rollen\tester.md`).

**Keine erfundenen Annahmen.** Jede Annahme ist aus Doku/Code belegt oder eine vor der Umsetzung geklaerte Frage. Unbelegte Annahme = Planungsmangel: falsch geplante Annahmen fuehren dazu, dass ganze Implementierungen weggeworfen werden. Lieber eine Frage mehr in der Planung als eine verworfene Umsetzung. Review-Rollen/Reviewzyklen: `01-arbeitsweise\richtlinien\plan-lifecycle-und-reviewzyklen.md`.

## Scope-Kontrolle und Lueckenerkennung waehrend der Umsetzung

Auch bei lueckenlosem Plan koennen Scope-Konflikte oder Modell-Luecken erst waehrend
der Umsetzung sichtbar werden — typisch bei Cross-Repo-Arbeit, wenn Downstream-Tests
am realen Artefakt Luecken im Upstream-Modell aufdecken.

**Downstream-Test am realen Artefakt:**
Consumer-Tests am realen gepinnten Paket/Build — nicht gegen Mock oder Annahme —
decken Upstream-Luecken frueh auf. Diese Gegenpruefung fruehzeitig einplanen (nicht erst
am Planende), damit Korrekturen noch in den laufenden Umsetzungszyklus fallen.

**Mid-flight Scope-Konflikt:**
Wird waehrend der Umsetzung ein Scope-Konflikt erkannt:

1. Root-Cause bestimmen (Planungsluecke, widerspruechliche Anforderung, neues Wissen?).
2. Blocker sofort im Status festhalten — **keine stille Scope-Ausweitung**.
3. Eskalation an Koordinator/Mensch + Re-Plan mit klaren Akzeptanzkriterien.

Stille Ausweitung ist Planungsmangel mit Folgerisiken (ungepruefter Scope, fehlende
Akzeptanzkriterien, unbekannte Nebenwirkungen).

**Belege-first bei Legacy-Quellen:**
Referenzwerte aus Altsystem-Code oder Datenbank (Feldbelegungen, Bytepositionen,
Enumwerte) verbatim aufnehmen und **durabel sichern** (Plan, Status, Handoff-Datei
— nicht nur im Chat-Verlauf). Handoffs muessen ohne Zugriff auf den urspruenglichen
Chat-Kontext nutzbar sein; keine Annahmen auf Basis von Beschreibungen.

Eskalationsregeln und Blocker-Typen: `01-arbeitsweise\richtlinien\koordination-und-worker.md`

## Ablage

- Zentraler Index: `C:\wissensdatenbank\plan\plan.md`
- Einzelplan: `C:\wissensdatenbank\plan\<name>\plan.md`
- Laufender Stand: `C:\wissensdatenbank\plan\<name>\status.md`
- Optionale Worker-Promptdateien: `C:\wissensdatenbank\plan\<name>\run\<id>.prompt.txt`
- **Unterplan (bei >1 Repo/Anwendung):** `C:\wissensdatenbank\plan\<name>\<anwendung>\plan.md` + `status.md`
- Archiv fertiger Plaene: `C:\wissensdatenbank\plan\_archiv\<name>\` (Ordner verschieben, nicht loeschen)

`<name>` kurz + sprechend, z. B. `terminal-ai-workflow`, `neuer-laptop`, `website-review`.

## Ticket und Branch beim Planstart

- Beim Anlegen nach Ticketnummer fragen, falls keine genannt.
- Keine vorhanden: nachfragen, aber anbieten, dass reine Refactorings/Fixes auch ohne Ticketnummer laufen (Branch-Praefix `refactor/...` bzw. `fix/...` statt `feature/TICKET-...`).
- Working Tree, gemeinsamer Feature-Branch, Branch-Namen: `02-softwareentwicklung\richtlinien\git-workflow.md`.

## Minimaler Plan

```markdown
---
type: plan
title: <Titel>
status: offen
updated: <YYYY-MM-DD>
---

# <Titel>

## Ziel
<1-2 Saetze: Was soll am Ende wahr sein?>

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
Luecke in der Matrix = Plan nicht umsetzungsreif. Reviewer/Tester pruefen die
Konformitaet Code<->spec entlang dieser Matrix, nicht nur gegen die Akzeptanzkriterien.

| Fachanforderung (spec.md-Ref) | Akzeptanzkriterium | Test (Fall/Datei) | Code-Fundstelle (geplant) | Status |
|---|---|---|---|---|
| <Ref/Kurzbeschreibung> | <AK> | <Testfall> | <Datei/Klasse/Methode> | offen |

Keine fachlichen Aenderungen -> Feld "keine Fachanforderung betroffen" (begruendet).

## Doku-Update
- Betroffene Artikel/READMEs: <Pfade oder "keine Doku betroffen">
- [ ] Doku nach Umsetzung aktualisiert

Bei Quellcode-Aenderungen Pflicht; "keine Doku betroffen" = begruendete Ausnahme.
Mindestens pruefen/aktuell halten: arc42-Architekturdoku, Service-/Anwendungs-
Steckbriefe, je Anwendung die `spec.md` (detaillierte Fachanforderungen),
Schnittstellenbeschreibungen (APIs, Message-/Dateiformate), Glossar (neue/geaenderte
Begriffe), betroffene Projektartikel (`<Firma>\<Produkt>\...`), zugehoerige `regeln.md`.
Aendert sich Verhalten/Signatur/Datenfluss/Konfiguration -> passende Doku im selben Plan mitziehen.

## Schritte
- [ ] Verstehen (docs-first: erst Wissensdatenbank-/Doku-Artikel, dann bei Bedarf Quellcode)
- [ ] Umsetzen
- [ ] Testen
- [ ] Review

## Zerlegung: Teilplaene und Unteraufgaben (bei mehreren Workern)
Plan → Teilplaene → Unteraufgaben; jede Unteraufgabe autonom abarbeitbar. Bei
mehreren Repos/Anwendungen/Artefakten je eigener Unterplan-Ordner `plan\<name>\<anwendung>\`
(plan.md + status.md); Hauptplan `plan\<name>\plan.md` = nur Uebersicht (Ziel, Kontext,
Akzeptanzkriterien, Abhaengigkeits-/Reihenfolge-Matrix, Verweise auf Unterplaene, Gesamtstatus).
Ein-Repo-Plaene: eine Datei genuegt. Teilaufgaben **klein** zuschneiden (ein Worker = ein
kleines Paket). Jede Zeile traegt einen eigenen Status (resume-faehig):
`offen` | `in Arbeit` | `blockiert` | `fertig`.

### Anwendung/Artefakt: <Name>  (Repo/Lib/Working Tree/Branch) — Status: offen
| Teilplan / Unteraufgabe | Rolle | Haengt ab von | Modell | Effort | Tier/Begruendung | Status | Stand/Notiz |
|---|---|---|---|---|---|---|---|
| <Kurzbeschreibung> | <z. B. developer> | <- / andere Aufgabe> | <claude-sonnet-5> | <low\|medium\|high> | <klein\|standard\|hoch — warum?> | offen | <letzter sicherer Stand: Datum/Branch/Datei> |

## Entscheidungen (vorab gebuendelt)
- Entscheidung / Annahme: <getroffen, mit kurzer Begruendung>
- Vor Umsetzung zu klaeren: <offene Punkte — muessen vor dem autonomen Lauf beantwortet sein>

## Risiken und offene Fragen
- Risiko:
- Frage:

## Status
- Stand gesamt: offen | in Arbeit | blockiert | fertig
- Naechster Schritt: <konkret>
- Resume: <aktuelle Unteraufgabe + letzter sicherer Stand (Branch/Datei)>
```

## Statusdatei

`status.md` ist wichtiger als Plan-Perfektion. Dort steht, was wirklich passiert ist.

```markdown
# Status

- Stand: offen | in Arbeit | blockiert | fertig
- Letzte Aenderung: YYYY-MM-DD HH:MM
- Naechster Schritt:
- Blocker:

## Resume-Checkpoint
- Aktueller Schritt:
- Letzter sicherer Stand:
- Arbeitsstand (Worktree/Branch/Dateien):
- Laufende Worker + Ueberwachungsintervall:

## Verlauf
- YYYY-MM-DD HH:MM — <kurzes Ereignis>

## Pruefung
- [ ] <Check oder manueller Test>
```

Der Resume-Checkpoint macht die Arbeit nach Compact/Pause wiederaufnehmbar (Wo stehe ich, letzter sicherer Stand, Arbeitsstand, laufende Worker + Intervall). Koordinator + Worker halten ihn aktuell (`01-arbeitsweise\richtlinien\koordination-und-worker.md`, Resume-faehige Checkpoints).

## Akzeptanzkriterien schreiben

Pruefbar formulieren:

- Gut: `setup-ai-workflow.bat legt vor dem Loeschen ein Backup mit Zeitstempel an.`
- Gut: `aispawn copilot ohne Prompt startet eine interaktive CLI ohne Fehler.`
- Schlecht: `Setup ist besser.` / `Alles funktioniert.`

## Worker-Aufgaben

Worker-Auftrag im neuen Tab (Pflichtfelder, Beispiel, Blocker-Regel, Mehrschicht-Schleifen, Modell/Aufwand-Einstufung): `01-arbeitsweise\richtlinien\koordination-und-worker.md`. Kurz: ein kohaerenter Auftrag je Worker (kleine zusammenhaengende Teilaufgaben duerfen gebuendelt werden), unabhaengige Aufgaben parallel, Blocker im Status festhalten statt mit Annahmen ueberdecken, finaler Commit erst nach gruener Selbst-Verifikation + moeglichst unabhaengigem Review. Nicht jede Teilaufgabe braucht das staerkste Modell — Tier-Tabelle (klein/standard/hoch mit konkreten Modellen): §Plan-Struktur/Modell-Aufwand oben. **Review-Worker** duerfen/sollen bei parallelisierbarer Pruefarbeit **4+ eigene Subagenten** einsetzen (mehrere Dateien/Aspekte parallel, billiger + schneller). **Ausnahme:** braucht eine Teilpruefung Zugriff auf externe Dateien (ausserhalb des Worker-Scopes/`--add-dir`), ist ein eigener CLI-Worker besser als ein Subagent (Subagent teilt Berechtigungs-Scope des Eltern-Workers). Faustregel: Subagenten fuer Paralleles im eigenen Scope; CLI-Worker bei externem Datei-/Repo-Zugriff. Production-Grenzen + Human-Review-Pflicht fuer Gen-AI-Code: `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md`.

## Fertig-Kriterium

Eine Aufgabe ist fertig, wenn:

- alle Akzeptanzkriterien erfuellt oder bewusst gestrichen sind,
- Tests oder manuelle Checks dokumentiert sind,
- offene Risiken bekannt sind,
- **Software-Doku (README, arc42/Steckbriefe, je Anwendung `spec.md`, Schnittstellen, Glossar) und betroffene Wissensdatenbank-Artikel aktualisiert sind** — Pflicht, nicht optional; Doku-Update-Feld im Plan abgehakt oder bewusst auf "keine Doku betroffen" gesetzt,
- Status aktuell ist,
- keine blockierenden Review-/Security-Findings offen sind,
- verantwortliche Devs den generierten Code verstehen und betreiben koennen.

Abschluss-Lauf (Push, Merge-Reihenfolge, PR-Hygiene, Checkout-Umbau): `01-arbeitsweise\richtlinien\plan-abschluss-release.md`
