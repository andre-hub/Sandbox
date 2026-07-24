# Rollenmatrix

Diese Matrix ergaenzt die einzelnen Rollenseiten. Sie hilft bei der schnellen Auswahl
und zeigt, welche Art von Ergebnis jede Rolle liefern soll.

## Rollen

| Rolle | Wofuer | Ergebnis |
|---|---|---|
| assistant | Gemischte oder noch unklare Anliegen | Struktur, naechste Schritte, Entflechtung |
| anforderer | Fachliches Ziel und Umfang | Pruefbare Anforderungen, Abnahmen, Ausschluesse |
| researcher | Quellen und Einordnung | Quellenhinweise, Fakten, offene Punkte |
| architect | Architekturentscheidung vor der Umsetzung | Entscheidung mit Alternativen, Vertraege, Scope |
| enterprise-architect | Ueberblick ueber mehrere Systeme | Systemuebersicht, Vertraege, Arbeitspakete je System |
| explorer | Read-only Bestandsaufnahme | Kompakte Zusammenfassung, relevante Dateien, Empfehlung |
| developer | Technische Umsetzung | Kleine, nachvollziehbare Aenderungen |
| frontend | Oberflaechenumsetzung | Barrierefreie, responsive UI-Aenderungen im bestehenden Stack |
| devops | Infrastruktur und Deployment | Validierte Infrastruktur-/Pipeline-Aenderungen |
| refactorer | Modernisierung ohne Verhaltensaenderung | Abgeschlossene Migration, unveraendertes Verhalten |
| tester | Verifikation und Regression | Testfaelle, Befunde, Risiken |
| reviewer | Lesbarkeit und Qualitaet | Empfehlung, Findings, Restpunkte |
| quality | Codequalitaet gegen Standards | Befunde mit Fundstelle, Schweregrad, Freigabeempfehlung |
| documenter | Dauerhafte Dokumentation | Konsistente, wartbare Texte |
| security | Schutz, Freigabegrenzen, Risiken | Konkrete Sicherheitsbewertung |

## Nutzung in Home und Firmen

- **Home:** verstaendliche Vorlagen, Automatisierung, Ordnung und sichere Standardablaeufe.
- **Firmen:** klare Uebergaben, belastbare Aenderungen, dokumentierte Entscheidungen und sichere Publikation.

## Auswahlregel

- Wenn das Ziel noch unklar ist, zuerst `assistant`.
- Wenn es um fachliche Erwartungen geht, zuerst `anforderer`.
- Wenn eine Quelle oder Einordnung fehlt, zuerst `researcher`.
- Wenn eine Architekturentscheidung ueber mehrere Systeme hinweg ansteht, `enterprise-architect`; innerhalb eines Systems `architect`.
- Wenn bestehender Code erst verstanden werden muss und Dokumentation nicht reicht, `explorer`.
- Wenn es geaendert werden soll: `developer` fuer allgemeine Umsetzung, `frontend` fuer Oberflaechen, `devops` fuer Infrastruktur, `refactorer` fuer Modernisierung ohne Verhaltensaenderung.
- Wenn es geprueft werden soll: `tester`, `reviewer`, `quality` oder `security`.
- Wenn etwas dauerhaft erklaert werden soll, `documenter`.

## Grundsatz

Jede Rolle soll ohne interne Agentenordner nutzbar sein und trotzdem genug
Kontext fuer Firmen- und Home-Nutzung liefern.
