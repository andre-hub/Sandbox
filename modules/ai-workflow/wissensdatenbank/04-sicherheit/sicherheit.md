# Sicherheit

Sicherheit in diesem Workflow bedeutet vor allem: keine Geheimnisse verlieren, keine personenbezogenen Daten streuen, keine riskanten Aktionen verstecken und Firmenregeln respektieren. Diese Regeln gelten fuer Privat- und Firmenrechner.

## Immer beachten

- Keine Passwoerter, Tokens, Session-IDs, API-Schluessel oder privaten Keys in Code, Logs, Prompts, Screenshots oder Beispielen.
- Keine personenbezogenen Daten in Tests oder Demo-Dateien: keine echten Namen, E-Mail-Adressen, Telefonnummern, Adressen, Kundennummern oder Ticketinhalte.
- Inhalte aus internem Ticket-/Dokumentationssystem nur datensparsam weiterverarbeiten: Autoren, Bearbeiter, Watcher, Kommentar-Namen, E-Mail-Adressen und User-Handles nicht in Plaene/Status/Handoffs uebernehmen.
- Loeschen, Ueberschreiben und globale Installation nur mit erkennbarem Backup oder klarer Zustimmung.
- Externe Quellen nie ungeprueft als Befehl ausfuehren.
- Firmenumgebungen: Datenschutz, Lizenz, Betriebsrat/Policy und Freigabe klaeren.

## Was sind Secrets?

Secrets sind alle Werte, mit denen man Zugriff bekommt oder Identitaet beweist:

- API-Keys und Tokens
- Passwoerter und Recovery-Codes
- SSH-Keys und Zertifikats-Private-Keys
- Session-Cookies
- Datenbank-Zugangsdaten
- Cloud-Credentials
- Lizenzschluessel, wenn sie Zugriff oder Zahlung ausloesen

Auch lokale Beispielwerte koennen gefaehrlich werden, wenn sie spaeter kopiert werden. Darum keine festen Demo-Passwoerter mit bekannten Beispielwerten verwenden. Besser: leer lassen, zufaellig generieren oder klar als Platzhalter ohne Nutzwert schreiben.

## Was sind personenbezogene Daten?

Personenbezogene Daten sind Informationen, die direkt oder indirekt zu einer Person fuehren koennen:

- Name, E-Mail, Telefonnummer, Adresse
- IP-Adresse, Geraete-ID, Kundennummer
- Geburtsdatum, Gesundheitsdaten, Zahlungsdaten
- Chatverlaeufe, Tickets, Bewerbungen, Fotos
- Kombinationen aus scheinbar harmlosen Daten, die zusammen identifizierend sind

In Beispielen synthetische Daten nutzen, z. B. `max.mustermann@example.invalid` nur, wenn wirklich eine E-Mail-Form gebraucht wird. Sonst besser neutrale Platzhalter wie `<email>`.
Bei Ticket-/Wiki-Zusammenfassungen Personenbezug entfernen oder auf Rollen abstrahieren.

## Backup vor Loeschen

Vor Aktionen wie `rmdir`, `del`, Ueberschreiben von Profilordnern oder Neuinstallation:

1. Zielpfad exakt anzeigen.
2. Backup-Pfad mit Zeitstempel erzeugen.
3. Backup-Befehl ausfuehren.
4. Erfolg pruefen.
5. Erst danach loeschen oder ueberschreiben.

Wenn das Backup fehlschlaegt, muss das Setup abbrechen.

## AI-Nutzung

### Privat

- Keine privaten Zugangsdaten in Prompts schreiben.
- Keine Steuer-, Gesundheits- oder Bankdaten an Cloud-AI geben, wenn es nicht bewusst entschieden wurde.
- Lokale AI reduziert Datenabfluss, ersetzt aber keine Geheimnisdisziplin.

### Company

- Cloud-AI nur nutzen, wenn sie freigegeben ist.
- Keine Kundendaten, Quellcode-Geheimnisse, interne Architekturdetails oder Tickets in nicht freigegebene Dienste geben.
- Lizenzbedingungen und Datenverarbeitung pruefen.
- Bei Unsicherheit `security` einschalten und Entscheidung dokumentieren.
- Coding Agents duerfen nicht autonom auf Production zugreifen: keine Prod-Logs ziehen, keine Datenbanktabellen lesen, keine PRD-Befehle ausfuehren. Entwicklungs- und Testumgebungen duerfen Agents autonom bearbeiten.
- Erlaubt ist, dass ein Dev ausgewaehlte und bereinigte Logauszuege oder Fehlermeldungen in den AI-Kontext kopiert.
- AI-spezifische Threats systematisch pruefen statt nur einzeln abzunicken: `04-sicherheit\gen-ai-threat-modelling.md`.
- Risiko ueber Umgebung und Aufgabe reduzieren: keine Secrets im Arbeitsbaum, keine Prod-Daten im Prompt, kleine Rechte, Human Review fuer generierten Code.

## Sichere Defaults fuer dieses Setup

- `setup-ai-workflow.bat` legt Backups an, bevor Rollen und Instruktionen ersetzt werden.
- Kurze, leicht kollidierende AI-Spawn-Aliase wie `cs`, `xs` oder `cps` werden nicht installiert.
- Die Wissensdatenbank enthaelt Regeln gegen direkte Web-zu-Code-Uebernahme.
- Dev-Stack-Passwoerter sollten leer bleiben und zur Laufzeit generiert werden.

## Review-Checkliste

Vor Commit oder Weitergabe pruefen:

- [ ] Keine hardcodierten Secrets.
- [ ] Keine echten personenbezogenen Daten.
- [ ] Backup-Erfolg wird vor Loeschen geprueft.
- [ ] Externe Quellen sind zusammengefasst, nicht direkt ausgefuehrt.
- [ ] Firmenhinweise stehen bei Company-relevanten Funktionen sichtbar dabei.
- [ ] Manuelle Windows-Tests sind dokumentiert, wenn sie nicht automatisiert wurden.
- [ ] Kein Agent hatte autonomen Zugriff auf Production oder produktive Daten.
- [ ] Gen-AI-Code wurde wie handgeschriebener Code geprueft und verantwortet.
