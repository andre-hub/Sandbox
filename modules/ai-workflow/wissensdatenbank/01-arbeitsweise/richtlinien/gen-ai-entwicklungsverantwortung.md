# Gen-AI in der Entwicklung

## Ziel

Gen-AI beschleunigt Entwicklung, ersetzt aber nicht Verantwortung, Systemkenntnis,
Review und Betriebssicherheit.

## Verantwortung

- Devs verantworten Code, den sie mit Gen-AI erzeugen lassen.
- Generierter Code hat dieselben Qualitaetsanforderungen wie handgeschriebener Code.
- Devs muessen die betroffene Software verstehen: Anforderungen, Historie, Risiken,
  Betrieb und Incident-Reaktion.

## Zweistufiges Review

- **Pflicht bei jeder Aenderung:** Review durch mindestens einen weiteren Agenten,
  der an der Umsetzung nicht beteiligt war. Das gilt schon lokal, auch ohne Push.
- **Pflicht vor Push/Remote-Freigabe:** zusaetzlich ein menschliches Review. Sobald
  eine Aenderung geteilt wird (Push, PR, Merge in einen gemeinsamen Branch), greift
  die menschliche Verantwortungspflicht — ein Agenten-Review ersetzt sie nicht.

## Mensch und AI kombinieren

| Staerke | Typische Nutzung |
|---|---|
| AI | Stacktraces lesen, Varianten skizzieren, Fleissarbeit, Querverweise, erste Tests |
| Mensch | Zielbild, Historie, Fachprioritaeten, Trade-offs, Nebenwirkungen, Ownership |

Gute Nutzung heisst: AI arbeitet vor, der Mensch korrigiert Ziel, Kontext und
Entscheidung.

## Multi-Agenten- und Schleifenarbeit

- Ein Koordinator darf lange Arbeitsfenster strukturieren und Worker-Agents steuern.
- Worker bekommen kleinen Scope, klare Verbote, erwartetes Ergebnis und Blocker-Regel.
- Mehrschicht-Schleifen sind erwuenscht: Umsetzung, Test, Review, Security, Doku.
- Ueberlappenden Scope vermeiden; Blocker zurueckmelden statt Annahmen zu verstecken.
- Der Koordinator bleibt verantwortlich fuer Integration, Priorisierung und Stopps.

## Produktionsgrenzen

Coding Agents bekommen keinen autonomen Zugriff auf Production. Entwicklungs- und
Testumgebungen duerfen Agents dagegen autonom bearbeiten (Deploy, Debug, Testdaten).

| Nicht OK | OK |
|---|---|
| Agent zieht autonom Prod-Logs, Datenbanktabellen oder Dumps | Dev kopiert ausgewaehlte, bereinigte Logauszuege in den Kontext |
| Agent fuehrt Befehle auf PRD aus, z. B. `kubectl`, SQL-Write, Rollout | Dev fuehrt freigegebene Befehle selbst aus und dokumentiert Ergebnis |
| Agent entscheidet PRD-Hotfix ohne Gate | Agent bereitet Optionen, Risiko und Checkliste vor |
| — | Agent arbeitet autonom in Dev-/Testumgebungen (Deploy, Debug, Datenaufbau) |

## Gen-AI-Threats

Kurzfassung: keine Secrets/Prod-Daten im Agent-Kontext, minimale Tool-Rechte statt
`allow-all`, generierter Code durch Tests und unabhaengiges Human Review, Security
Concerns im Plan dokumentieren statt nur Tool-Calls einzeln abzunicken.

Vollstaendige Kategorien, Warnzeichen und Gegenmassnahmen: `04-sicherheit\gen-ai-threat-modelling.md`.

## Arbeitsfreude und Qualitaet

- Nicht nur Gen-AI-Merge-Requests reviewen lassen.
- Genug manuelle Arbeit behalten, damit Devs mit Code, Architektur und Betrieb vertraut bleiben.
- Eintoenige Review-Arbeit reduziert Aufmerksamkeit; Reviews klein und sinnvoll schneiden.

## Review-Check

- Versteht das Team den generierten Code und kann ihn betreiben?
- Hat ein unbeteiligter Agent den Code reviewed, bevor er als fertig gilt?
- Ist vor jedem Push/Merge in einen gemeinsamen Branch ein menschliches Review erfolgt?
- Hat kein Agent autonom auf Production zugegriffen (Dev/Test ausgenommen)?
- Sind Secrets, PII und Prod-Daten aus Prompts und Logs herausgehalten?
- Sind AI-Staerken genutzt, ohne menschliche Kontextentscheidungen zu ersetzen?
