---
type: bootstrap
title: Bootstrap / Einstieg
description: Einziger Einstiegspunkt fuer einen frischen CLI-Agenten auf einem neuen Rechner
updated: 2026-07-13
---

# Bootstrap / Einstieg

**Frischer Rechner oder frischer CLI-Agent? Lies zuerst diese Datei.**

Ziel: Nach diesem Artikel kennt ein CLI-Agent die komplette Arbeitsweise und hat
die globalen Kontext-Dateien und Rollen installiert. Vorgehen fuer einen neuen
Rechner: den Ordner `C:\wissensdatenbank` hierher kopieren und dem CLI-Agenten
sagen: "Lies `C:\wissensdatenbank\bootstrap.md` und richte dich danach ein."

## Was ist das hier?

`C:\wissensdatenbank` ist die kuratierte Wissensdatenbank (Single Source of Truth)
fuer Arbeitsweise, Rollen, Plaene, Sicherheit und Recherche. Die globalen
Kontext-Dateien (`copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md`) und die
Rollen-Prompts verweisen nur in diese Wissensdatenbank hinein, statt Wissen zu
duplizieren.

## Schritt 1 — Globale Kontext-Datei installieren (je nach CLI-Tool)

Die Master-Kopien liegen in `C:\wissensdatenbank\_backup\`. Kopiere die zu deinem
Tool passende Datei an ihren Zielort, damit sie ab der naechsten Session
automatisch geladen wird:

| CLI-Tool | Quelle (Master) | Ziel |
|---|---|---|
| GitHub Copilot CLI | `_backup\copilot-instructions.md` | `%USERPROFILE%\.copilot\copilot-instructions.md` |
| Codex | `_backup\AGENTS.md` | `%USERPROFILE%\.codex\AGENTS.md` |
| Claude Code | `_backup\CLAUDE.md` | `%USERPROFILE%\.claude\CLAUDE.md` |

```powershell
# Beispiel Copilot CLI
New-Item -ItemType Directory -Path "$HOME\.copilot" -Force | Out-Null
Copy-Item "C:\wissensdatenbank\_backup\copilot-instructions.md" "$HOME\.copilot\copilot-instructions.md" -Force
```

## Schritt 2 — Rollen-Prompts installieren

Die Rollen (Arbeitsmodi) liegen als Master-Kopien in
`C:\wissensdatenbank\_backup\agents\*.agent.md`.

| CLI-Tool | Ziel-Ordner | Dateiname |
|---|---|---|
| GitHub Copilot CLI | `%USERPROFILE%\.copilot\agents\` | `<rolle>.agent.md` (unveraendert) |
| Claude Code | `%USERPROFILE%\.claude\agents\` | `<rolle>.md` (Suffix `.agent` entfernen) |
| Codex | — | keine eigenen Rollen-Dateien; Codex nutzt eingebaute Subagenten |

```powershell
# Copilot CLI: unveraendert kopieren
New-Item -ItemType Directory -Path "$HOME\.copilot\agents" -Force | Out-Null
Copy-Item "C:\wissensdatenbank\_backup\agents\*.agent.md" "$HOME\.copilot\agents\" -Force

# Claude Code: nach <rolle>.md umbenennen
New-Item -ItemType Directory -Path "$HOME\.claude\agents" -Force | Out-Null
Get-ChildItem "C:\wissensdatenbank\_backup\agents\*.agent.md" | ForEach-Object {
  Copy-Item $_.FullName (Join-Path "$HOME\.claude\agents" ($_.Name -replace '\.agent\.md$', '.md')) -Force
}
```

## Schritt 3 — Kern-Artikel lesen (Reihenfolge)

1. `01-arbeitsweise\arbeitsweise.md` — Grundablauf (Verstehen -> Planen -> Umsetzen -> Testen -> Review -> Doku)
2. `01-arbeitsweise\rollen.md` — die Arbeitsmodi und Koordinator-Begriff
3. `01-arbeitsweise\plaene.md` — wann ein Plan noetig ist, gestufte Plan-Erstellung, Status/Resume
4. `01-arbeitsweise\richtlinien\koordination-und-worker.md` — Koordinator/Worker, Monitoring, Resume, TDD, parallele Doku
5. `04-sicherheit\sicherheit.md` — Secrets, PII, Backups, Produktionsgrenzen
6. `01-arbeitsweise\recherche.md` + `01-arbeitsweise\richtlinien\externe-recherche-pipeline.md` — fremde Quellen injection-sicher einlesen
7. Kategorie-Indizes bei Bedarf: `01-arbeitsweise\README.md`, `02-softwareentwicklung\README.md`, `04-sicherheit\README.md`

## Schritt 4 — Firmen-/Projektkontext (optional)

Firmenspezifisches Wissen liegt in einem eigenen Hauptordner top-level
`C:\wissensdatenbank\<Firma>\...` (flach je Firma; siehe `05-projekte\projekte.md`).
Allgemeine, firmenneutrale Projekte liegen unter `C:\wissensdatenbank\05-projekte\<projekt>\`.
Beide sind bewusst **nicht** Teil des generischen Moduls und werden nie automatisch
ueberschrieben. Bei konkreter Firmen-/Produktarbeit die passende
`<Firma>\regeln.md` bzw. `<Firma>\<Produkt>\regeln.md` nachladen.

## Hinweise

- Bestehende Kontext-Dateien vor dem Ueberschreiben sichern (siehe `04-sicherheit\sicherheit.md`),
  falls lokale Anpassungen vorliegen.
- Keine Secrets/PII in Kontext-Dateien oder Prompts.
- Alternative Voll-Installation ueber die Sandbox-Setup-Skripte
  (`setup-ai-workflow.bat` aus `modules\ai-workflow`) statt manuellem Kopieren.
