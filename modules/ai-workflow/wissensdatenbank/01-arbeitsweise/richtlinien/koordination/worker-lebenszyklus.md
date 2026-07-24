# Koordination — Worker-Lebenszyklus, Auftrag, Terminal-Befehle

Teil von `01-arbeitsweise\richtlinien\koordination-und-worker.md` (Hub).

## Autonome Worker: Berechtigungen und Flags

Worker laeuft im Automodus in freigegebenen Trusted Trees mit vollen Rechten (nicht an Einzelfreigaben haengen). Freigegeben (Trusted Trees): `C:\projects`, `C:\projects-wt`, `C:\wissensdatenbank`, `C:\share`, `%USERPROFILE%\Documents\windows-terminal` sowie der Worker-Austauschordner `%AI_WORKER_HOME%`.

- Start-Flags (setzt `ai-spawn-direct.ps1` automatisch): `--allow-all-tools`, je ein `--add-dir` fuer die Trusted Trees, `--no-ask-user` (autonom). Standard-Worker starten mit **sichtbarer Oberflaeche** (`-i`): normales Copilot-UI inkl. Eingabefeld da, Agent arbeitet autonom durch, schliesst Tab bei vollstaendiger Fertigstellung selbst (Abschluss-Protokoll per `aidone` automatisch im Prompt). Headless-Batch/Skript ohne UI: `-Headless` (`-p`, Tee in Handoff).
- Schreiben + Befehle in Trusted Trees ohne Einzelbestaetigung. Die **interaktive Koordinator-Session** wird autonom gestellt: in **cmd**-Tabs ueber den `copilot`-doskey-Alias (`aliases.cmd`), in **PowerShell** ueber die `copilot`-Funktion des `AiWorkers`-Moduls (per `Documents\PowerShell\profile.ps1` geladen, ueberlagert die `copilot.exe`). Beide setzen `--allow-all-tools` + `--add-dir` fuer die Trusted Trees. Grund: die von Copilot verwaltete `permissions-config.json` kann pro Ordner nur `write` (alle Schreibzugriffe) und **aufgezaehlte** Befehle freigeben, aber keinen „alle Befehle"-Platzhalter — ein neuer, nicht gelisteter Befehl fragt sonst erneut. Der Alias/die Funktion vermeidet das global fuer die Session, Pfadzugriff bleibt per `--add-dir` auf die Trusted Trees begrenzt. Programmatisch gestartete Nachfolge-Koordinatoren (`aihandoff`) laufen ueber `ai-spawn-direct.ps1` und sind automatisch abgedeckt. Bypass mit Rueckfragen: `copilot.exe` bzw. `& (Get-Command copilot -CommandType Application).Source` direkt aufrufen.
- Produktionsgrenzen bleiben: `--allow-all-tools` hebt Prod-/Datenschutzregeln nicht auf (kein autonomer Prod-Zugriff, keine Secrets; `04-sicherheit\sicherheit.md`, `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md`).
- Manuell/abweichend: `-Headless` (headless `-p`, kein UI), `-NoAutonomy` (normale Freigaben, kein Self-Close), `-NoAutoClose` (Tab bleibt nach Abschluss offen), `-AllowAsk` (Rueckfragen erlauben), `-AllowDirs` (andere Ordner).

## Worker-Lebenszyklus (Start bis Selbstschliessung)

Klarer Lebenszyklus, damit sichtbar bleibt, welches Fenster (CLI-Agent) aktiv ist:

1. **Start** — Koordinator startet Worker als **eigenen Tab im gemeinsamen Worker-Fenster** (`aispawn` / `ai-spawn-direct.ps1`); Worker mit ID/Session-ID/Status in AI-Worker-Registry (`aiworkers` zeigt alle).
2. **Autonome Arbeit** — Worker arbeitet die vorab geklaerte Aufgabe ab, schreibt Fortschritt/Ergebnis in Handoff-Datei (Resume-Checkpoint). **Parallelisierbare Teilschritte an eigene Subagenten** delegieren (Task-Tool, eigener Kontext, kein Fenster) — billiger + schneller als alles selbst sequenziell oder als ein neuer CLI-Worker je Facette (Entscheidung Subagent vs. CLI-Worker: `koordination\begriffe.md`). Ein Worker darf **laenger laufen und mehrere zusammenhaengende Unteraufgaben** abarbeiten, solange sein nutzbarer Kontext (Richtgroesse ~100k Token) sauberes Arbeiten erlaubt; Subagenten halten den Haupt-Kontext schlank (nur kompakte Handoffs zurueck). Erst an einen frischen Worker uebergeben, wenn der Kontext wirklich knapp wird — nicht prophylaktisch nach jeder Teilaufgabe.
3. **Selbst-Verifikation (Pflicht vor der Fertigmeldung)** — vor `aidone` selbst gegenpruefen, **bevor** ein teures unabhaengiges Review laeuft: alle Akzeptanzkriterien einzeln durchgehen; Tests/Checks ausfuehren und **gruen** bestaetigen (nicht behaupten); Diff gegen den zugewiesenen Scope (keine stille Ausweitung); bei fachlichen Aenderungen Abgleich gegen die Anforderungs-Abdeckungsmatrix/`spec.md`. Offene Punkte -> Blocker im Status, nicht als `done` melden. So werden Fehler billig hier statt teuer im Review gefangen.
4. **Ergebnis melden** — nach gruener Selbst-Verifikation: Ergebnis an Koordinator (Handoff-Datei + Registry-Status `done`; per `aidone`). `aidone` schreibt zusaetzlich einen **Inbox-Eintrag** (Feedback-Loop): Koordinator sieht Fertigmeldungen ueber `aiinbox` (offene Eintraege) und quittiert/leert mit `aiinbox -Clear`, statt Handoff-Dateien einzeln abzuklappern.
5. **Selbstschliessung** — direkt nach Ergebnismeldung schliesst der Worker seinen Tab. Standard-Worker (`-i`) rufen als letzten Schritt automatisch `aidone <id> "<ergebnis>"` (Abschluss-Protokoll steckt im Prompt) und verschwinden. Headless (`-Headless`, `-p`) schliessen bei Erfolg automatisch (Fehler-Tabs bleiben zur Inspektion offen). Worker-Tabs schliessen zuverlaessig, auch wenn ein haengendes Close-Overlay ohne Fallback-Mechanik zurueckbleiben wuerde. **Koordinator-seitig**: sobald der Koordinator den Handoff dieses Workers erhalten/gesichtet hat, darf er **genau diesen** Worker-Tab selbst schliessen (`aiclose <id>`) — er wartet nicht auf die Selbstschliessung, sondern beendet den fertigen Worker gezielt, damit nur aktive Fenster offen bleiben.
6. **Notausgang** — haengt ein Worker oder driftet er aus dem Scope: Koordinator schliesst gezielt `aiclose <id>` (beendet Fenster-Prozessbaum); tote Eintraege: `aiworkers -Prune`.

Regel: **fertige Worker verschwinden**, nur aktive Fenster bleiben offen — so geht der Ueberblick nicht verloren.

## Fernsteuern (Folgeauftraege ohne Fensterbedienung)

Ueber die Session, nicht ueber Tastatureingaben ins fremde Fenster:

- Jeder Worker feste Session-ID. Folgeauftrag/Korrektur per `aisend <id> "<auftrag>"`; Worker setzt Session mit `--resume` autonom fort, schreibt weiter in dieselbe Handoff-Datei.
- Robust: kein SendKeys, keine Fenster-Fokussierung noetig; funktioniert auch nach beendetem letztem Lauf.
- Fork-Schutz: `aisend` bricht ab, wenn der Ziel-Worker noch aktiv laeuft (PID lebt, status=running) — verhindert parallele Prozesse auf derselben Session; vorher `aiclose <id>` oder bewusst `-Force`.
- Fernsteuern = **Ausnahme** (Drift-Korrektur, Nachschaerfen), nicht Normalfall — bei gutem Front-Loading braucht ein Worker kaum Folgeauftraege.

## Worker-Auftrag: Pflichtfelder

Jeder Worker-Auftrag nennt:

1. **Rolle** — Arbeitsmodus (`developer`, `tester`, `reviewer`, ...)
2. **Scope** — betroffene Dateien/Ordner/Systeme
3. **Aufgabe** — was konkret zu tun ist
4. **Regeln/Verbote** — z. B. read-only, kein Commit, keine Secrets ausgeben, kein Push
5. **Erwartetes Ergebnis** — Output-Format, Akzeptanzkriterien
6. **Blocker-Regel** — Verhalten bei Blocker (zurueckmelden, nicht raten)
7. **Modell und Effort (getrennt)** — konkretes Modell (`--model`, z. B. `claude-sonnet-5`) **und** Reasoning-Effort (`--effort`, z. B. `low`/`medium`) als **zwei explizite Werte** aus der Plan-Zeile, nicht nur der Tier-Name (klein/standard/hoch, siehe `01-arbeitsweise\richtlinien\plan-lifecycle-und-reviewzyklen.md`). Worker immer damit starten (`aispawn -Model ... -Effort ...` bzw. `-Tier`); **nie in einer interaktiven Koordinator-Session** auf dem globalen CLI-Default (grosses Modell/hoher Effort) laufen lassen. Nicht jede Teilaufgabe braucht das staerkste Modell.
8. **Worktree/Branch** — bei Schreibzugriff: eigener Worktree/Arbeits-Branch vom gemeinsamen Feature-Branch des Plans (siehe `02-softwareentwicklung\richtlinien\git-workflow.md`)

Beispiel:

```text
Rolle: reviewer
Scope: C:\projects\beispiel
Aufgabe: Pruefe die Aenderung read-only gegen Ziel und Akzeptanzkriterien.
Regeln: Keine Edits, kein Commit, keine Secrets ausgeben.
Output: Verdict, Findings mit Datei:Zeile, naechster Schritt.
Blocker: Bei fehlendem Kontext sofort zurueckmelden statt zu raten.
Modell: claude-sonnet-5  |  Effort: medium   (Tier standard)
```

## Terminal-Umsetzung (Windows)

- Neuer Worker-Tab (gemeinsames Worker-Fenster, autonom): `aispawn <tool> [prompt]` bzw. `ai-spawn-direct.ps1` (Rolle/Modell/Interaktiv-Modus als Parameter).
- Mehrere unabhaengige Worker: `aimulti <tool> "Aufgabe 1" -- "Aufgabe 2"`.
- Ueberblick aktiver Fenster/Worker: `aiworkers` (`-Active`, `-Full`, `-Prune`).
- Fernsteuern (Folgeauftrag via Session-Resume): `aisend <id> "<auftrag>"`.
- Gezielt schliessen (Notausgang): `aiclose <id>` (bzw. `-All`/`-Dead`).
- Worker meldet Ergebnis + schliesst sich: `aidone <id> "<ergebnis>"`.
- Koordinator-Staffeluebergabe: `aihandoff -PromptFile <status.md>`.
- Registry/Handoff/Logs der Worker: Worker-Austauschordner `%AI_WORKER_HOME%` (Standardpfad per Umgebungsvariable konfigurierbar).
- Komplexe Prompts (viele Sonderzeichen, `!`, `^`, Anfuehrungszeichen, mehrere Zeilen): Promptdatei nutzen + `ai-spawn-direct.ps1 -PromptFile <datei>`.
- Keine kurzen Spawn-Aliase wie `cs`, `xs`, `cps`, `as` oder `vs`.
- **Verfuegbarkeit in PowerShell:** `ai*`-Befehle sind in **cmd**-Tabs doskey-Makros (`ai-aliases.cmd`). In **PowerShell** (z. B. Koordinator-Shell) stellt das Modul `AiWorkers` (`Documents\PowerShell\Modules\AiWorkers\`) dieselben Befehle als Funktionen bereit — transparente Pass-throughs auf die Skripte in `Documents\windows-terminal\`, per Autoload (auch mit `-NoProfile`). Verhalten identisch; `aispawn` akzeptiert Positionsform (`aispawn copilot "<prompt>"`) und benannte Parameter (`aispawn -Tool copilot -PromptFile <f> -Role developer`). Zusaetzlich exportiert das Modul die `copilot`-Funktion (autonome Koordinator-Session); diese laedt **nicht** per Autoload (Namenskollision mit `copilot.exe`), sondern wird ueber `Documents\PowerShell\profile.ps1` (`Import-Module AiWorkers`) aktiv und ueberlagert die `.exe` in interaktiven Sessions.

## "Neuer Agent" vs. Hintergrund-Worker

- **Neuer Agent** = immer neues, sichtbares **eigenes** Windows-Terminal-Fenster mit frisch gestarteter CLI-Anwendung (Normalfall: `aispawn` / `aimulti`). Keine gesonderte Rueckfrage noetig. Folgeauftraege an laufenden Agenten via `aisend` (Session-Resume), nicht manuelle Eingaben ins fremde Fenster.
- Worker als **Hintergrundprozess** (kein sichtbares Fenster, kein Mitlesen) nur bei ausdruecklicher Ansage. Hintergrund-Worker brauchen immer explizite Benutzer-Freigabe vor dem Start — nicht aus Bequemlichkeit waehlen.
- Hintergrundbetrieb nur sinnvoll bei wirklich autonom abarbeitbarer, nicht zu umfangreicher Aufgabe (kurz + abgegrenzt, nicht lang + offen ohne Aufsicht).
- Im Zweifel: sichtbares Fenster + nachfragen, statt eigenmaechtig Hintergrundprozess starten.
