# Softwareentwicklung

Technische Standards und Leitfaeden fuer die Software-Domaene: Code, Tests, Git,
Build/Deploy, Kubernetes, Messaging, Betrieb.

## Ablageregeln

- Hier hinein: Coding-/Test-/Git-Standards, DDD, Logging/Monitoring, Kubernetes/GitOps,
  Build/Deploy, Registry, Go-Live-Gates, Messaging.
- Nicht hier hinein: Methodik/Rollen/Planung (-> `Arbeitsweise`),
  Secrets/Threat-Modelling (-> `Sicherheit`).

## richtlinien\

| Datei | Fokus |
|---|---|
| `richtlinien\coding-standards.md` | Lesbarer, testbarer Code (sprachagnostisch) |
| `richtlinien\testing-standards.md` | Testpyramide, AAA, Mocking-Prinzip (sprachagnostisch) |
| `richtlinien\ddd-grundlagen.md` | Schichten, Aggregate, Ports/Adapter |
| `richtlinien\git-workflow.md` | Branches, Commits, Reviews, Merge-Regeln |
| `richtlinien\git-hooks-precommit.md` | Pre-Commit-Hooks fuer lokale Qualitaetschecks |
| `richtlinien\logging-standards.md` | Strukturierte Logs, Korrelation, Datenschutz |
| `richtlinien\production-go-live-gates.md` | Generisches Sicherheits-/Betriebsgate vor Produktion |
| `richtlinien\stufenweise-softwareentwicklung.md` | Gates, Handoffs, Verifikation |
| `richtlinien\workflow-pipeline.md` | Phasenbasierte Verarbeitung mit Kontextobjekt |

## Weiterlesen

- `01-arbeitsweise\README.md`, `04-sicherheit\README.md`
- Neue Artikel: `06-vorlagen\artikel-default.md`
