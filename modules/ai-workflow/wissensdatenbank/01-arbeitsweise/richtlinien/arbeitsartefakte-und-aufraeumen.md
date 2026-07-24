# Arbeitsartefakte & Aufraeumen (verbindlich)

> Zweck: keine losen Temp-Dateien mehr in `C:\projects`-Wurzel oder in Repos. Jede Aufgabe raeumt ihren temporaeren Kram am Ende weg.

## Grundregel

- **Temporaeres** (Probe-Skripte, Roh-Dumps, Zwischendateien, Ad-hoc-Automation) NIE in:
  - `C:\projects`-Wurzel
  - in ein Git-Repo (auch nicht ungetrackt)
- Temporaeres IMMER in den **Scratch-Workspace**: `C:\share\ai-workers\scratch\<task>\`.
- **Dauerhaftes** (wiederverwendbare Rezepte, Referenz-Skripte, Erkenntnisse) gehoert in die **Wissensdatenbank** (`C:\wissensdatenbank\...`) oder ein Tool-Verzeichnis (`C:\projects\tools\<tool>\`), nicht in die projects-Wurzel.

## Scratch-Workspace (Helfer)

Skript: `C:\share\ai-workers\ai-scratch.ps1`

| Befehl | Zweck |
|---|---|
| `$ws = & C:\share\ai-workers\ai-scratch.ps1 -New -Task <name>` | Scratch-Dir anlegen, Pfad zurueck (in `$ws`/`$env:AI_SCRATCH` merken) |
| `& ...\ai-scratch.ps1 -List` | alle Scratch-Dirs + Alter/Groesse |
| `& ...\ai-scratch.ps1 -Clean -Task <name>` | Scratch-Dir dieser Aufgabe loeschen |
| `& ...\ai-scratch.ps1 -Gc -Days 3` | Sicherheitsnetz: vergessene Dirs aelter als N Tage weg |

## Aufraeum-Disziplin (Pflicht)

1. Zu Aufgabenbeginn: Scratch-Dir per `-New` anlegen, dort arbeiten.
2. Dauerhaft Wertvolles vor Abschluss in die Wissensdatenbank ueberfuehren (nicht im Scratch liegen lassen).
3. **Vor Fertigmeldung / im Self-Check**: eigenen Scratch per `-Clean` loeschen. Verifizieren: `C:\projects`-Wurzel + Repo-Status sauber (keine neuen losen/ungetrackten Dateien).
4. Koordinator prueft beim Abschluss stichprobenartig `ai-scratch.ps1 -List` und laesst `-Gc` laufen.

## Checkliste (Review/Self-Check)

- [ ] keine neuen losen Dateien in `C:\projects`-Wurzel
- [ ] `git status` der betroffenen Repos ohne unbeabsichtigte ungetrackte Dateien
- [ ] Scratch-Dir der Aufgabe geloescht (oder bewusst behalten + notiert)
- [ ] dauerhaft Wertvolles in Wissensdatenbank/Tool-Ordner ueberfuehrt
- [ ] keine PII/Secrets in verbleibenden Artefakten

## Querverweis

- Koordination/Worker (Self-Check vor Handoff): `koordination-und-worker.md`
