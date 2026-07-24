# Agentische Arbeitsweise (Haupt-Weg)

Dies ist der **Hauptweg** fuer Koordinator/Worker/Subagenten-Arbeit in diesem Repo: leichtgewichtige
Windows-Terminal-Tab-Spawner (`ai-*`-Skripte, `modules\ai-workflow\windows-terminal\`) plus eine
lokale JSON-Registry. Kein externer Dienst, kein Port, keine Fernsteuerung ueber Netzwerk — alles
laeuft ueber lokale Dateien auf derselben Maschine. Diese Doku ersetzt die entfernte
`03-infrastruktur\windows-terminal-aliase.md`.

Begriffe (Koordinator/Worker/Subagent), Kette und Mehrschicht-Schleifen: `koordination-und-worker.md`.
Dieser Artikel beschreibt, **womit** (Tooling) die dortige Methodik technisch umgesetzt wird.

## Was ein Worker ist

- Ein Worker ist ein **eigener Tab** im gemeinsamen Fenster `ai-workers` (Fenstername ueber
  `AI_WORKER_WINDOW` umstellbar; `-NewWindow` startet stattdessen ein eigenes Fenster).
- Startmodus **sichtbar** (Standard): Worker arbeitet autonom durch und schliesst seinen Tab bei
  Fertigstellung selbst. `-Headless` startet einen stillen `-p`-Lauf ohne UI.
- Jeder Worker bekommt genau eine Aufgabe mit klaren Grenzen und einem erwarteten Ergebnis; Blocker
  werden zurueckgemeldet statt Annahmen zu verstecken.

## Spawn / Send / Close

| Alias | Wirkung |
|---|---|
| `aispawn <tool> [prompt]` | Worker-Tab starten. `-Headless` fuer stillen Lauf, `-NewWindow` fuer eigenes Fenster |
| `aimulti <tool> "p1" -- "p2"` | mehrere unabhaengige Worker-Tabs auf einmal starten |
| `aiworkers [-Active\|-Full\|-Prune]` | aktive Worker/Tabs aus der Registry auflisten |
| `aisend <id> "auftrag"` | Worker per Session-`--resume` fernsteuern (Folgeauftrag, kein SendKeys) |
| `aiclose <id>` | Worker gezielt schliessen (`-All`/`-Dead` zum Aufraeumen) |
| `aidone <id> "ergebnis"` | Worker meldet Ergebnis und schliesst seinen eigenen Tab |
| `aihandoff -PromptFile <status.md>` | Koordinator-Staffeluebergabe an einen Nachfolger |
| `aiinbox [-All\|-Clear]` | Koordinator-Inbox lesen bzw. quittieren/leeren |
| `aihelp` | Kurzhilfe zu allen `ai*`-Befehlen |

Kurze Spawn-Aliase wie `cs`, `xs`, `cps`, `as` oder `vs` werden bewusst **nicht** installiert — jeder
Aufruf bleibt als vollstaendiger `ai*`-Befehl lesbar.

Fuer Prompts mit vielen Sonderzeichen (`!`, `^`, Anfuehrungszeichen, mehrzeilig): Promptdatei nutzen,
`ai-spawn-direct.ps1 -PromptFile <datei>` statt Direktaufruf ueber `cmd.exe`.

**Verfuegbarkeit:** In `cmd`-Tabs sind `ai*`-Befehle Doskey-Makros (`ai-aliases.cmd`). In PowerShell
stellt das Modul `AiWorkers` dieselben Befehle als Funktionen bereit (Positions- und benannte Form,
z. B. `aispawn -Tool copilot -PromptFile <f> -Role developer`).

## Lokale JSON-Registry

Jeder gestartete Worker wird mit ID, Rolle, Status und Zeit in einer lokalen Registry-Datei
(`registry.json`, Ort ueber `AI_WORKER_HOME` umstellbar, Default `%USERPROFILE%\ai-workers`)
gefuehrt. `aiworkers` liest daraus den Ueberblick; `aiclose -Prune` raeumt tote Eintraege auf.
Sitzungs-IDs fuer `--resume` werden **nicht** im Klartext in dieser Datei gehalten, sondern separat
ueber DPAPI verschluesselt abgelegt (Windows-Nutzerprofil-gebunden) — die Registry selbst bleibt
sekundaerdatensparsam (ID/Rolle/Status/Zeit, kein Freitext-Ergebnis).

## `--resume`-Fernsteuerung

`aisend <id> "auftrag"` gibt einem laufenden Worker per Session-`--resume` einen Folgeauftrag, ohne
den Tab zu fokussieren oder Tastatureingaben zu simulieren. **Fork-Schutz**: `aisend` bricht ab,
wenn der Ziel-Worker noch aktiv laeuft (PID lebt, Status `running`) — ein Resume derselben Session
in zwei parallelen Prozessen waere ein Fork-Risiko. Vorher `aiclose <id>` oder bewusst `-Force`.

## Inbox-Feedback-Loop (`aiinbox`)

`aidone <id> "ergebnis"` schreibt beim Abschluss zusaetzlich einen Eintrag in die Koordinator-Inbox
(mutex-geschuetzt, `inbox.jsonl` im Worker-Verzeichnis) — nur ID/Rolle/Status/Zeit, ohne
Freitext-Ergebnisfeld (Datensparsamkeit). Der Koordinator liest offene Eintraege mit `aiinbox`,
quittiert/leert sie mit `aiinbox -Clear`; `aiinbox -All` zeigt auch bereits quittierte Eintraege.
So merkt der Koordinator ohne aktives Pollen jedes Terminals, welcher Worker fertig/blockiert ist.

## Tier -> Modell-Wahl

`aispawn`/`ai-spawn-direct.ps1` akzeptieren `-Tier klein|standard|hoch` und fuellen daraus Modell und
Effort (ueberschreiben nie ein explizit gesetztes `-Model`/`-Effort`). Ohne `-Tier` wird ueber die
Rolle (`-Role`) automatisch ein Tier zugeordnet.

| Tier | Modell | Effort | Beispielrollen |
|---|---|---|---|
| `klein` | `claude-sonnet-5` | low | reviewer, tester, documenter, explorer |
| `standard` | `claude-sonnet-5` | medium | developer, anforderer, refactorer, frontend, devops |
| `hoch` | `claude-opus-4-8` | high | architect, security, enterprise-architect |

Details zur Rollenwahl: `..\rollen.md`.

## Selbstschliessung

Worker-Tabs laufen in einem eigenen Terminal-Profil mit `closeOnExit: always`; zusaetzlich sorgt ein
UIA-Nothelfer dafuer, dass ein haengendes Restart/Close-Overlay ueber den "Close Tab"-Button
geschlossen wird. Der Abschluss (`aidone`) beendet den Prozessbaum PID-Reuse-sicher (kein rohes
`Stop-Process` auf eine womoglich wiederverwendete PID) und schreibt den Inbox-Eintrag, bevor sich
der Tab schliesst. So bleiben keine "process exited... press Enter"-Overlays haengen und keine
Zombie-Prozesse zurueck.

## Review-Schleifen

Ein Review-Worker startet **read-only** (kein Fix im selben Lauf) und meldet im Standard-Verdict-
Format (`Verdict/Findings/Positiv/Naechster Schritt`, s. `arbeitsweise.md`). Bei laengeren Reviews
darf der Review-Worker intern mehrere eigene Subagenten parallel einsetzen (Kette bleibt: Koordinator
startet den Review-Worker, der Worker faechert selbst auf) — das ist kein neuer CLI-Worker pro
Facette, sondern Subagenten-Buendelung im selben Kontext.

## Autonomie-Modus

Ohne `-NoAutonomy` startet `aispawn` einen Worker mit den Freigaben, die fuer die im laufenden
Projekt tatsaechlich vertrauten Ordner (`-AllowDirs`) noetig sind, damit nicht bei jedem neuen Befehl
ein Ordner-Trust-Prompt kommt. `-NoAutonomy` erzwingt das normale Freigabeverhalten (Worker fragt
nach). Vertrauten Ordnerkreis bewusst klein halten — keine pauschale Vollfreigabe ueber das ganze
Dateisystem.

## Verweise

- Koordinator/Worker/Subagent-Begriffe, Kette, Mehrschicht-Schleifen: `koordination-und-worker.md`
- Rollen und Rollenwahl: `..\rollen.md`
- Grundablauf (Verstehen -> Planen -> Umsetzen -> Testen -> Review -> Doku): `..\arbeitsweise.md`
- Skripte selbst: `modules\ai-workflow\windows-terminal\ai-*.ps1`, `ai-aliases.cmd`
