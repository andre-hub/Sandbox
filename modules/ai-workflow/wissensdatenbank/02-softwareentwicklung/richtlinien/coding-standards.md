# Coding Standards

## Ziel

Lesbarer, testbarer und kleiner Code. Die Regeln sind bewusst pragmatisch und sollen
Reviews vereinfachen, nicht Stil-Debatten verlagern. Sprachagnostisch formuliert — je
Repo/Stack an die konkrete Sprache anpassen (Beispiele unten sind Illustration, keine Vorgabe).

## Strukturgrenzen

| Einheit | Richtwert |
|---|---|
| Klasse/Modul | bis ca. 300 Zeilen |
| Methode/Funktion | bis ca. 50 Zeilen |
| Verschachtelung | maximal 4 Ebenen |
| Verantwortungen pro Klasse/Modul | moeglichst 1 |

- Early Return vor langen `if/else`-Ketten.
- Komplexe Entscheidungen in kleine private Methoden/Funktionen oder Domaintypen auslagern.
- Lange Methoden/Funktionen sind ein Signal fuer fehlende Abstraktion oder gemischte Verantwortungen.

## Benennung

| Element | Stil | Beispiel |
|---|---|---|
| Klassen, Interfaces/Typen, Enums | konsistenter Stil je Sprachkonvention (z. B. PascalCase) | `InvoiceService`, `IEventPublisher` |
| Methoden/Funktionen | konsistenter Stil je Sprachkonvention | `publishAsync` |
| Properties/Felder | konsistenter Stil je Sprachkonvention | `correlationId` |
| Parameter, lokale Variablen | konsistenter Stil je Sprachkonvention (z. B. camelCase) | `correlationId` |
| Konstanten | klar erkennbar als Konstante (z. B. UPPER_SNAKE_CASE) | `MAX_RETRIES` |

Wichtiger als Modefragen: einheitlich innerhalb desselben Repos bleiben, an die
Konvention der jeweiligen Sprache/des jeweiligen Stacks halten.

- **Sprache der Bezeichner:** Typen, Methoden/Funktionen, Properties, Parameter und
  lokale Variablen auf **Englisch**. Ausnahme sind fachliche **Eigennamen** — Produkt-,
  Firmen-, Projekt-, Betreiber-/Mandantennamen sowie Dateiformat-/Schnittstellen-Codes
  (z. B. firmenspezifische Format-Kuerzel). Kommentare und Dokumentationskommentare
  duerfen Deutsch sein. Neue Namen zuerst an vorhandenen Bestandstypen des Repos
  ausrichten, nicht neu erfinden.
- **Keine Ticket-/Issue-Nummern in Bezeichnern:** Projekt-/Ticketreferenzen (z. B.
  `Proj1234...`) sind transient und gehoeren in Commit-/PR-Text oder Kommentare, nicht
  in Typ-, Enum-, Methoden- oder Property-Namen. Bezeichner benennen die Fachsache
  (`Whitelist`, nicht `Proj1234Whitelist`).

## Sichtbarkeit und Kopplung

- Oeffentliche Schnittstellen nur fuer echte API-Oberflaechen exponieren.
- Interne Logik so eng wie moeglich sichtbar halten (Sprach-Aequivalent von `internal`/paket-privat).
- Felder/Zustand kapseln; nach aussen ueber Methoden oder Properties/Getter zugaenglich machen.
- Business-Logik nicht in globalen/statischen Hilfsfunktionen verstecken, wenn Testbarkeit leidet.

## Null-/Fehlwert-Sicherheit

- Wo die Sprache es anbietet: Nullability/Optionality-Checks aktiviert lassen bzw. konsequent nutzen.
- Fehlende/leere Werte explizit behandeln, nicht stillschweigend durchreichen.
- Guard Clauses vor spaeten Null-/Fehlwert-Fehlern.

```text
function process(order)
    if order is null/empty
        raise ArgumentError("order is required")
    // ...
```

## Fehlerbehandlung

- Keine leeren Fehlerbehandlungs-Bloecke (`catch`/`except`/Sprachaequivalent).
- Fehler mit Kontext loggen.
- Fehler nicht verschlucken, wenn Aufrufer oder Queue-Retry darauf angewiesen sind.
- Fachlich erwartbare Fehler als Domaintyp oder Result abbilden; technische Defekte als Exception/Error.

## Dokumentation

- Dokumentationskommentare fuer oeffentliche Schnittstellen und nicht offensichtliche APIs.
- HTTP-APIs mit einem Schnittstellenformat (z. B. OpenAPI) beschreiben.
- Kommentare nur fuer Absicht, Randbedingungen oder Invarianten; nicht fuer Offensichtliches.

### Keine Planungs-/Prozess-Referenzen im Code (Pflicht)

Kommentare erklaeren **den Code fuer den naechsten Entwickler** — nicht unseren Arbeitsprozess.
**Verboten** in Quellcode-Kommentaren (und Bezeichnern):

- Interne Contract-/Plan-IDs und Ticket-Artefakte: Prozess-Codes wie `KP-3.6`, `OQ-2`,
  `F3/F4/F5`, `Gate-0`, `R-S7`, `S-7`, `A-4` u. ae.
- Verweise auf interne/nicht verfuegbare Dokumente („aus Notes-DB", „laut Lastenheft",
  „siehe Plan §KP-2") oder auf den Review-/Reviewzyklus.
- Ticketnummern in Bezeichnern (`Proj1234Whitelist` -> `Whitelist`).

**Erlaubt/erwuenscht:** knappe Klartext-Kommentare zu Absicht, Randbedingung oder Invariante,
die **ohne Kenntnis unseres Plans** verstaendlich sind. Beispiel statt
„KP-3.6 D-record body from offset 42 behind SS_TRM_KE (S-7, Notes-DB)":
„D-Saetze werden nur bei aktiviertem Feature-Flag ausgegeben; das Byte-Layout ab Offset 42 ist
noch nicht final." Feature-Flag-/Symbolnamen als **Code** duerfen bleiben; der Kommentar-Text bleibt Klartext.

## Clean-Code-Leitplanken

- DRY: Duplication reduzieren, aber nicht zu frueh abstrahieren.
- KISS: einfachste tragfaehige Loesung bevorzugen.
- YAGNI: nichts fuer hypothetische Zukunft bauen.
- SOLID: besonders Single Responsibility und Dependency Inversion.

## Review-Check

- Ist die Klasse/das Modul auf einen Zweck fokussiert?
- Sind Seiteneffekte klar sichtbar?
- Sind Eingaben validiert?
- Ist die Methode/Funktion ohne globale Zustandsannahmen testbar?
- Gibt es sprechende Namen statt Kommentarbedarf?
