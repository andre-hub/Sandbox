# Production-Go-Live-Gates

## Ziel

Bevor eine Anwendung oder eine Aenderung produktiv geht, muss ein Mindestmass an
Sicherheit und Betriebsfaehigkeit belegt sein. Dieses Gate ist bewusst generisch:
keine Firmen- oder Tool-Namen, sondern Kategorien, die jede Firma mit eigenen
Werkzeugen fuellt.

Firmenspezifische Konkretisierung (z. B. ein bestimmtes Scan-Tool, eine bestimmte
Test-Pflicht oder eine bestimmte Netzwerk-Policy-Engine) gehoert in
`<Firma>\<Produkt>\regeln.md`, nicht in dieses generische Modul.

## Gate-Kategorien

| Kategorie | Minimum | Verweis |
|---|---|---|
| Beobachtbarkeit | Metrics, Logs, Dashboard, Alerts vorhanden | firmenspezifisches Werkzeug in `<Firma>\...` |
| Runbook | Erstdiagnose, Kontakt, Abhaengigkeiten dokumentiert | firmenspezifisches Werkzeug in `<Firma>\...` |
| Rollback | Ein getesteter, dokumentierter Rueckweg existiert | firmenspezifisches Werkzeug in `<Firma>\...` |
| Promotion-Pfad | Aenderung ist ueber definierte Umgebungen gelaufen, nicht direkt Local -> Prod | firmenspezifisches Werkzeug in `<Firma>\...` |
| Sicherheitsdefaults | non-root, Ressourcenlimits, getrennte Secrets, minimale Rechte | firmenspezifisches Werkzeug in `<Firma>\...` |
| Vulnerability-Scanning | Abhaengigkeiten/Images gescannt, kritische Findings triagiert oder akzeptiert | `04-sicherheit\sicherheit.md` |
| Netzwerksicherheit | Zugriffe eingeschraenkt statt offen (Zero-Trust-Prinzip, Network Policies o.ae.) | firmenspezifisches Werkzeug in `<Firma>\...` |
| Testdokumentation | Automatische und/oder manuelle Tests fuer den kritischen Pfad nachvollziehbar | `01-arbeitsweise\richtlinien\plan-lifecycle-und-reviewzyklen.md` |
| GitOps-/Pipeline-Gates | Build/Test gruen, Manifeste renderbar, Review erfolgt | firmenspezifisches Werkzeug in `<Firma>\...` |
| Gen-AI-Code-Review | Generierter Code ist von einem unbeteiligten Dev verstanden und reviewed | `01-arbeitsweise\richtlinien\gen-ai-entwicklungsverantwortung.md` |
| Backup/Restore | Datenverlustpfad bekannt, Wiederherstellung beschrieben | `04-sicherheit\sicherheit.md` |

## Wann das Gate gilt

- Erster produktionsnaher Go-Live einer neuen Anwendung.
- Aenderungen mit Datenverlust-, Sicherheits- oder Verfuegbarkeitsrisiko.
- Aenderungen, die generierten Code in einen produktionsnahen Pfad bringen.

Kleine, risikoarme Aenderungen mit bestehendem Rollback-Weg brauchen nicht jedes Mal
eine volle Neupruefung aller Kategorien — aber jede Kategorie muss bewusst
"erfuellt", "nicht betroffen" oder "bewusst akzeptiertes Risiko" sein, nicht einfach
uebersprungen werden.

## Nicht-Ziel

- Keine 1:1-Kopie einer Firmen-Checkliste.
- Keine konkrete Tool-Auswahl (Scanner, Policy-Engine, Testframework).
- Kein Ersatz fuer Firmenfreigaben, Datenschutz- oder Lizenzpruefung.

## Review-Check

- Ist jede Gate-Kategorie erfuellt, nicht betroffen oder bewusst als Risiko akzeptiert?
- Gibt es einen echten, getesteten Rollback-Weg?
- Ist die Aenderung ueber den Promotion-Pfad gelaufen statt direkt in Produktion?
- Wurde generierter Code unabhaengig reviewed?
- Sind offene Punkte im Plan/Status dokumentiert statt stillschweigend uebersprungen?
