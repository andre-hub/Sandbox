# Arbeitsweise

Domaenenuebergreifend: WIE wir arbeiten (nicht nur Softwareentwicklung). Methodik,
Rollen, Planung, Recherche.

## Ablageregeln

- Hier hinein: Grundablauf, Rollen/Koordination, Plan- und Statusverwaltung,
  Recherche-Regeln, agentische Arbeitsweise, Wissensdatenbank-Pflege.
- Nicht hier hinein: technische Coding-/Betriebsstandards (-> `Softwareentwicklung`),
  Rechner/Tools (-> `Infrastruktur`), Datenschutz/Secrets (-> `Sicherheit`),
  Firmen-/Produktwissen (-> `<Firma>\`).

## Basisdokumente

| Datei | Fokus |
|---|---|
| `arbeitsweise.md` | Grundablauf: Verstehen -> Planen -> Umsetzen -> Testen -> Review -> Doku |
| `plaene.md` | Wann ein Plan noetig ist, gestufte Plan-Erstellung, Status/Resume |
| `recherche.md` | Recherche und externe Quellen |
| `rollen.md` (+ `rollen\`) | Arbeitsmodi/Rollen, Koordinator-Begriff, Rollenseiten |

## richtlinien\

| Datei | Fokus |
|---|---|
| `richtlinien\agentische-entwicklung.md` | Mehrere CLIs, Rollen, Handoffs, Kontexttrennung |
| `richtlinien\koordination-und-worker.md` | Koordinator/Worker-Mechanik, Auftragsformat, Mehrschicht-Schleifen |
| `richtlinien\agentische-arbeitsweise.md` | Haupt-Weg: `ai-*`-Windows-Terminal-Skripte (Spawn/Send/Close, Registry, Inbox, Tier-Wahl) |
| `richtlinien\docs-first-recherche.md` | Interne Doku/Wissensdatenbank vor Quellcode und externer Recherche |
| `richtlinien\externe-recherche-pipeline.md` | Injection-sicheres Einlesen fremder Quellen (Quarantaene, Bereinigung, Redaktion) |
| `richtlinien\gen-ai-entwicklungsverantwortung.md` | Verantwortung, Human Review, Prod-Grenzen |
| `richtlinien\plan-lifecycle-und-reviewzyklen.md` | Planen, Reviewen, Abschliessen |
| `richtlinien\wissensdatenbank-lint.md` | Health-Check der Wissensdatenbank (tote Links, Sync) |
| `richtlinien\ticket-bis-pr.md` | End-to-End-Playbook Ticket -> PR (Checkliste, verweist auf plaene/rollen/koordination/git-workflow), Push-Gate + Autonomie-Reifegrad |

## Weiterlesen

- `02-softwareentwicklung\README.md`, `04-sicherheit\README.md`
- Neue Artikel: `06-vorlagen\artikel-default.md`
