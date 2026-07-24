# Rollen

Der AI-Workflow nutzt eine Reihe gleichwertiger Arbeitsmodi (Rollen). Sie sind keine
starre Organisation und keine Rangfolge, sondern einfache Arbeitsmodi. Eine Person
oder ein AI-Chat kann nacheinander mehrere Rollen einnehmen. Bei laengeren Aufgaben
kann eine Rolle in einem eigenen sichtbaren Windows-Terminal-Tab laufen. Nicht jede
Rolle wird in jedem Projekt gebraucht; `architect`, `devops`, `quality`, `refactorer`,
`frontend` und `explorer` kommen typischerweise bei groesseren oder technisch
spezialisierten Aufgaben zum Einsatz.

**Koordinator ist keine eigene Rolle.** Es ist der normale CLI-Agent (die laufende
Hauptsession), der Plaene, Status, Rollen und Worker kennt und laengere
Arbeitsfenster sowie mehrere Worker steuert. Jede Rolle kann diese
Koordinator-Funktion uebernehmen, meistens `assistant` oder `anforderer`.
Als Koordinator greift diese Rolle selbst nicht in Code oder inhaltliche
Dokumente ein: kein Quellcode lesen/schreiben, keine Wissensartikel/Plan-Inhalte
bearbeiten — nur Orchestrierungs-Dateien (Status/Checkpoints/Registry) pflegen und
alle inhaltliche Arbeit von kurzlebigen Workern erledigen lassen.
Koordinator und Worker sind immer ganze CLI-Agenten mit eigenem, normalerweise
sichtbarem Windows-Terminal-Fenster; ein Koordinator startet/fernsteuert nur
weitere Koordinatoren oder Worker, nie Subagenten direkt. Subagenten (z. B.
Task-Tool-Agenten) gehoeren zum Kontext eines Workers. Details und Begriffe:
`01-arbeitsweise\richtlinien\koordination-und-worker.md`.

## Uebersicht

| Rolle | Zweck | Typische Fragen |
|---|---|---|
| `assistant` | Allgemeine Hilfe und Koordination | Was ist das Ziel? Welche Rolle passt? Was ist der naechste Schritt? |
| `researcher` | Recherche, Quellen und Zusammenfassungen | Was sagen Quellen? Was ist belegt? Was ist unsicher? |
| `anforderer` | Anforderungen klaeren, priorisieren, in Plaene zerlegen (inkl. Product-Owner-Aufgaben) | Wer braucht was, warum? Welche Schritte sind noetig? Was ist fertig? |
| `documenter` | Dokumentation und Texte | Wie erklaere ich es verstaendlich? Welche Anleitung fehlt? |
| `developer` | Code, Skripte und Konfiguration aendern | Welche kleine Aenderung loest das Problem? Wie bleibt sie wartbar? |
| `tester` | Tests und manuelle Pruefschritte | Wie pruefen wir es? Was koennte kaputtgehen? |
| `reviewer` | Qualitaet, Verstaendlichkeit, Wartbarkeit | Ist es sauber, konsistent und passend zum Ziel? |
| `security` | Datenschutz, Secrets und sichere Defaults | Gibt es Secrets, personenbezogene Daten oder riskante Aktionen? |
| `architect` | Architektur-Bewertung, ADRs, Design-Review | Passt das Design? Welche Trade-offs, welche ADR? |
| `devops` | Infrastruktur, Deployment, CI/CD | Ist das Manifest/die Pipeline sicher und standardkonform? |
| `quality` | Code-Qualitaetspruefung gegen Coding-Standards | Wo weicht der Code von Standard/Struktur/Naming ab? |
| `refactorer` | Code-Modernisierung, Migrationen | Wie migrieren wir, ohne Verhalten zu aendern? |
| `frontend` | Frontend-Umsetzung nach Stack/Design-System | Wie setzen wir das UI-Element im bestehenden Stack um? |
| `explorer` | Read-only Codebase-Erkundung, wenn Doku nicht reicht | Wo im Code steckt das, was die Doku nicht beantwortet? |
| `enterprise-architect` | Ueberblick Softwarelandschaft, Orchestrierung bei 2+ Anwendungen | Welche Services sind betroffen? Wie zerlegen wir das in Workstreams? |

Firmen-/Projektdetails (Tech-Stack, Design-System, Coding-Standards, Infrastruktur)
laden alle Rollen bei Bedarf aus `C:\wissensdatenbank\<Firma>\<Produkt>\regeln.md`
nach, statt sie fest einzubauen (lazy-loading, siehe `01-arbeitsweise\arbeitsweise.md`).

## Aufbau: Ueberblick, Kurzrollen, Agenten

Rolleninformation liegt in drei aufeinander abgestimmten Schichten (keine Doppelpflege):

- **`01-arbeitsweise\rollen.md`** (diese Datei) = Ueberblick, empfohlene Kombinationen,
  Spawn-Regeln. Zentrale Anlaufstelle.
- **`01-arbeitsweise\rollen\<rolle>.md`** = ausfuehrliche, allein verstaendliche Rollenseiten
  (Zweck, Wann einsetzen, Home-/Firmen-Kontext, Aufgaben, Workflow, Regeln,
  Ergebnisformat, `Macht`/`Macht nicht`, Grenzen, Weiterlesen). **Einzige Quelle fuer
  Rollendetails.** Schnellauswahl: `01-arbeitsweise\rollen\matrix.md` / `01-arbeitsweise\rollen\README.md`.
- **`~\.copilot\agents\<rolle>.agent.md`** und **`~\.claude\agents\<rolle>.md`** =
  ausfuehrbare Agenten-Prompts (Provider-spezifisch), mit denen eine Rolle als
  CLI-Agent/Worker gestartet wird.

## Rollen im Detail

Je Rolle eine eigene, allein verstaendliche Seite unter `01-arbeitsweise\rollen\<rolle>.md`
(Zweck, Wann einsetzen, Aufgaben, Workflow, Regeln, `Macht`/`Macht nicht`, Grenzen).
Schnellauswahl ueber `01-arbeitsweise\rollen\matrix.md` bzw. `01-arbeitsweise\rollen\README.md`.

## Empfohlene Kombinationen

| Aufgabe | Rollenfolge |
|---|---|
| Unklare Frage | `assistant` → bei Bedarf `researcher` |
| Neue Anleitung | `documenter` → `reviewer` |
| Skript aendern | `anforderer` → `developer` → `tester` → `reviewer` |
| Tool-Auswahl | `researcher` → `security` → `anforderer` |
| Firmen-Setup | `anforderer` → `security` → `developer` → `tester` → `reviewer` |
| Wissensdatenbank erweitern | `researcher` oder `assistant` → `documenter` → `reviewer` |
| Architekturfrage vor Umsetzung | `architect` → `developer` → `tester` → `reviewer` |
| Infrastruktur/Deployment | `devops` → `security` → `reviewer` |
| Framework-/Versions-Migration | `refactorer` → `tester` → `reviewer` |
| Unbekannte Codebasis (Docs reichen nicht) | `explorer` → `developer`/`architect` |
| Frontend-Umsetzung | `frontend` → `tester` → `reviewer` |
| Gezielte Qualitaetspruefung | `quality` → `developer` (Fixes) → `reviewer` |

## Spawn-Regeln

- Kleine Aufgaben: Rolle im aktuellen Chat nennen, kein eigener Worker (CLI-Agent) noetig.
- Laengere Aufgaben: eigenen Worker-Tab mit `aispawn <tool> "Aufgabe"` starten —
  immer eigener CLI-Agent (eigener Tab im gemeinsamen Worker-Fenster), kein Subagent
  im Koordinator-Kontext, laeuft autonom in den Trusted Trees.
- Mehrere unabhaengige Aufgaben: `aimulti`.
- Jeder Worker: genau eine Aufgabe, klare Dateien, erwartetes Ergebnis.
- Vor dem Start Front-Loading: alle Fragen/Entscheidungen gebuendelt klaeren, damit
  der Worker ohne Rueckfragen durchlaeuft (`01-arbeitsweise\plaene.md`, `01-arbeitsweise\richtlinien\koordination-und-worker.md`).
- Fertige Worker melden Ergebnis + schliessen ihr Fenster (`aidone`); der Koordinator
  darf nach Erhalt des Handoffs genau diesen Worker-Tab selbst schliessen (`aiclose <id>`),
  ohne auf die Selbstschliessung zu warten. Fernsteuern `aisend`, Notausgang `aiclose`,
  Ueberblick `aiworkers`.
- Koordinator uebergibt nach Teilaufgaben an einen Nachfolger (`aihandoff`) und
  schliesst sich danach, damit nur aktive Fenster offen bleiben.
- Worker duerfen Findings vorschlagen; der Koordinator entscheidet ueber Integration.
- Subagenten (z. B. Task-Tool) startet/steuert ein Worker in seinem eigenen Kontext selbst — **aktiv fuer parallelisierbare Fleissarbeit (billiger/schneller)**, statt jede Facette als neuen CLI-Worker zu starten; der Koordinator fernsteuert nur CLI-Agenten (Koordinatoren/Worker). Entscheidung Subagent vs. CLI-Worker + Begriffe: `01-arbeitsweise\richtlinien\koordination\begriffe.md`.
