# 02-rollen - Rollenuebersicht

Zweck dieses Ordners: die 15 Rollen des AI-Workflow-Moduls, jede als eigene,
allein verstaendliche Seite.

Die oeffentliche Variante kennt 15 klar getrennte Rollen. Jede Rolle ist
bewusst allgemein gehalten, damit das Modul fuer Firmen und Home nutzbar
bleibt. Die Rollen beschreiben Arbeitsauftraege, nicht interne Organigramme.

Fuer die schnelle Auswahl gibt es zusaetzlich die Kurzmatrix in
[`matrix.md`](matrix.md).

## Rollen

| Rolle | Zweck |
|---|---|
| [assistant](assistant.md) | Allgemeine Hilfe, Intake und Koordination bei gemischten oder unklaren Anliegen |
| [anforderer](anforderer.md) | Anforderungen klaeren, priorisieren, in Plaene zerlegen |
| [researcher](researcher.md) | Recherche, Quellenbewertung und belastbare Zusammenfassungen |
| [developer](developer.md) | Technische Umsetzung, kleine und nachvollziehbare Aenderungen |
| [tester](tester.md) | Tests, Syntaxchecks und Verifikation |
| [reviewer](reviewer.md) | Unabhaengige Qualitaetspruefung und Freigabeempfehlung |
| [documenter](documenter.md) | Dauerhafte Dokumentation und verstaendliche Texte |
| [security](security.md) | Secrets, PII, sichere Voreinstellungen und riskante Aktionen |
| [architect](architect.md) | Architektur-Bewertung, ADRs und Design-Review vor der Umsetzung |
| [devops](devops.md) | Infrastruktur, Deployment und CI/CD-Pipelines |
| [quality](quality.md) | Code-Qualitaetspruefung gegen Coding-Standards mit konkreter Fundstelle |
| [refactorer](refactorer.md) | Code-Modernisierung, Migrationen und Pattern-Vereinheitlichung |
| [frontend](frontend.md) | Frontend-Umsetzung nach bestehendem Stack und Design-System |
| [explorer](explorer.md) | Read-only Codebase-Erkundung, wenn Dokumentation nicht ausreicht |
| [enterprise-architect](enterprise-architect.md) | Ueberblick ueber die Systemlandschaft, Orchestrierung bei 2+ Anwendungen |

## Einsatzreihenfolge

1. `assistant` fuer gemischte oder noch offene Anliegen
2. `anforderer` fuer Ziel, Umfang und Abnahmekriterien
3. `researcher` fuer Quellen, Einordnung und offene Fakten
4. `enterprise-architect` bei Anforderungen ueber mehrere Systeme hinweg, sonst `architect` fuer Architekturentscheidungen innerhalb eines Systems
5. `explorer` zur read-only Erkundung, wenn Dokumentation nicht ausreicht
6. `developer`, `frontend`, `devops` oder `refactorer` fuer Umsetzung und technische Aenderungen
7. `tester`, `reviewer` und `quality` fuer Absicherung, Lesbarkeit und Codequalitaet
8. `documenter` fuer dauerhafte Nachpflege
9. `security` fuer Risiken, Schutz und Freigabegrenzen

## Firmen- und Home-Nutzung

- **Home:** kleine Vorhaben, private Automatisierung, Ordnung in Dateien, Hobbyprojekte.
- **Firmen:** Produktarbeit, Teamabstimmung, dokumentierte Aenderungen, reproduzierbare Uebergaben.
- **Gemeinsam:** klare Ziele, kleine Schritte, nachvollziehbare Ergebnisse und keine PII oder Secrets.

## Leitplanken

- Jede Rolle soll allein verstaendlich sein.
- Oeffentliche Inhalte bleiben neutral und schlank, aber nicht oberflaechlich.
- Firmenbezogene Sonderfaelle gehoeren in lokale, nicht veroeffentlichte Zusaetze.
- Die oeffentlichen Rollen muessen ohne interne Agentenordner auskommen.

Alle Rollen arbeiten nach `C:\wissensdatenbank\01-arbeitsweise\arbeitsweise.md`, `C:\wissensdatenbank\04-sicherheit\sicherheit.md` und ggf. `C:\wissensdatenbank\<Firma>\<Produkt>\regeln.md`.
