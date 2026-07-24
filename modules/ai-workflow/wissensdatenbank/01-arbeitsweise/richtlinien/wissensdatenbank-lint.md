---
type: richtlinie
title: Wissensdatenbank-Lint
description: Periodischer Health-Check fuer die Wissensdatenbank (tote Links, verwaiste Artikel, Sync-Gaps)
tags: [wissensdatenbank, wartung, review]
updated: 2026-07-10
---

# Wissensdatenbank-Lint

## Ziel

Die Wissensdatenbank waechst wie ein LLM-Wiki (Open Knowledge Format/Karpathy-Muster):
Agenten schreiben und pflegen sie fortlaufend. Genau wie ein Wiki braucht sie
periodische Gesundheitschecks, sonst haeufen sich tote Links, verwaiste Artikel und
Sync-Gaps zwischen Sandbox-SSoT und installierter Kopie unbemerkt an.

## Wann ausfuehren

- Nach groesseren Refactorings der Wissensdatenbank (Umbenennungen, neue Rollen,
  strukturelle Aenderungen).
- Nach Rollen-Umbenennungen oder -Entfernungen (tote Verweise in anderen Artikeln).
- Regelmaessig vor einem groesseren Plan, der die Wissensdatenbank stark nutzt.
- Bei Verdacht, dass Sandbox-SSoT und installierte Kopie auseinandergelaufen sind.

## Checkliste

1. **Tote Links**: Jeder Verweis der Form `richtlinien\...md`, `05-projekte\...`,
   `06-vorlagen\...md` in Artikeln/Rollen-Dateien zeigt auf eine tatsaechlich
   existierende Datei.
2. **Verwaiste Artikel**: Jede Richtlinie unter `01-arbeitsweise\richtlinien\` bzw.
   `02-softwareentwicklung\richtlinien\` ist im jeweiligen Kategorie-Index
   (`01-arbeitsweise\README.md` / `02-softwareentwicklung\README.md`) gelistet und wird
   von mindestens einer Stelle
   (Rolle, `01-arbeitsweise\arbeitsweise.md`, `01-arbeitsweise\plaene.md`, anderer Artikel) referenziert.
3. **Veraltete Aussagen**: Artikel, die alte Rollennamen, entfernte Dateien oder
   ueberholte Konventionen erwaehnen (z. B. nach einem Rename wie `planner` →
   `anforderer`), werden gefunden und korrigiert.
4. **Sandbox-vs-Installiert-Sync**: Sandbox-SSoT (`modules\ai-workflow\...`) und
   installierte Kopie (`C:\wissensdatenbank`, `.copilot`, `.claude`, `.codex`) per
   Diff vergleichen (z. B. `Compare-Object`), nicht nur die zuletzt bearbeiteten
   Dateien, sondern alle Ordner vollstaendig.
5. **Frontmatter-Konsistenz** (fuer Artikel, die bereits Frontmatter haben):
   `type`/`title`/`description` stimmen mit dem tatsaechlichen Inhalt ueberein.
6. **Duplikate zwischen generisch und projekt-/firmenspezifisch**: Projekt-Dateien
   (z. B. `<Firma>\<Produkt>\*.md`, `regeln.md`) daraufhin pruefen, ob
   sie generische Ablaeufe/Gates/Vorlagen nur umformuliert wiederholen statt echte
   Abweichungen zu beschreiben. Gefundene Duplikate kuerzen auf Verweis + Delta
   (siehe `01-arbeitsweise\arbeitsweise.md`, Dokumentieren-Schritt).
7. **Rohdaten-Quarantaene nicht verlinkt**: Kein regulaerer Wissensartikel
   verweist auf den Rohdaten-Quarantaene-Ordner (ungepruefte Fremdinhalte). Solche Verweise
   sind ein Fehler — Rohdaten werden erst nach Bereinigung/Redaktion als echter
   Artikel uebernommen (siehe `01-arbeitsweise\richtlinien\externe-recherche-pipeline.md`). Ausnahme:
   die Erklaerung der Pipeline selbst und die README des Quarantaene-Ordners.

## Werkzeuge (Beispiele, PowerShell)

```powershell
# Tote interne Links grob finden (Beispiel fuer richtlinien-Verweise)
Select-String -Path .\**\*.md -Pattern 'richtlinien\\[a-z0-9-]+\.md' |
  ForEach-Object { $_.Matches.Value } | Sort-Object -Unique

# Sync-Check zwischen zwei Ordnern (z. B. Sandbox vs. installiert)
Compare-Object (Get-ChildItem $sandboxPfad -Recurse -Name) (Get-ChildItem $installiertPfad -Recurse -Name)

# Verbotene Verweise auf die Rohdaten-Quarantaene finden (sollte leer sein,
# ausser in der Pipeline-Doku und der README des Quarantaene-Ordners)
Select-String -Path .\**\*.md -Pattern '_recherche-rohdaten' |
  Where-Object { $_.Path -notmatch 'externe-recherche-pipeline\.md|_recherche-rohdaten' }
```

## Ergebnis festhalten

Befund und Fix kurz dokumentieren (Aktion `sync` bei behobenen Abweichungen,
`aktualisiert` bei inhaltlichen Korrekturen). Bei groesseren Funden zusaetzlich einen
kurzen Plan anlegen (`01-arbeitsweise\plaene.md`).

## Review-Check

- Wurden alle vier Ordner (Sandbox, `C:\wissensdatenbank`, `.copilot`, `.claude`,
  `.codex`) tatsaechlich verglichen, nicht nur die zuletzt bearbeiteten Dateien?
- Verweist kein regulaerer Artikel auf den Rohdaten-Quarantaene-Ordner?
- Ist jeder gefundene Gap dokumentiert?
- Gibt es nach dem Lint noch offene, nicht behobene Findings? Wenn ja: im Status/Plan vermerken.
