# Testing Standards

## Ziel

Tests pruefen Verhalten, nicht Implementierungsdetails. Jeder Test soll schnell lesbar,
stabil und ohne Produktionsdaten ausfuehrbar sein. Sprachagnostisch formuliert — je
Repo/Stack ein passendes Test-Framework, Mocking-/Double-Werkzeug und Assertion-Bibliothek
waehlen und konsistent im Repo verwenden.

## Testpyramide

| Ebene | Zweck | Anteil |
|---|---|---|
| Unit | Geschaeftslogik, Mapping, Validierung isoliert | Basis — die meisten Tests |
| Integration | Zusammenspiel mehrerer Komponenten (z. B. mit echter/lokaler Infrastruktur) | weniger, gezielt |
| End-to-End/UI | kritischer Nutzerpfad durch das Gesamtsystem | wenige, teuerste Ebene |

## Namensschema

`methodName_stateUnderTest_expectedBehavior` (oder Sprachaequivalent, konsistent im Repo)

Beispiele:
- `importAsync_validInput_returnsSuccess`
- `process_missingCorrelationId_stopsWorkflow`
- `render_afterSave_showsToast`

## AAA-Muster

Jeder Test folgt Arrange, Act, Assert.

```text
test "publishAsync_validOrder_sendsMessage":
    publisher = mock(OrderPublisher)
    service = OrderService(publisher)

    result = service.publishAsync(Order("A-1"))

    assert result == true
    assert publisher.received(publish, times: 1)
```

## Was testen?

| Testen | Nicht testen |
|---|---|
| Geschaeftslogik | Datenobjekte ohne Logik |
| Validierung | Framework-Details |
| Mapping mit Fachwert | triviale Getter/Setter |
| Fehlerpfade | Dependency-Injection-Registrierungen ohne Verhalten |
| Pipeline-Phasen und Use Cases | rein dekorative Boilerplate |

## Testbarkeit im Design

- Constructor-/Dependency-Injection statt statischer Abhaengigkeiten.
- Seiteneffekte ueber Schnittstellen/Interfaces kapseln.
- Uhren, Zufall und Dateisystem abstrahieren.
- Fachobjekte klein und gezielt aufbauen.

## Mocking-Prinzip

- Doubles/Mocks nur an den Systemgrenzen (externe Services, Zeit, Zufall, I/O) einsetzen,
  nicht fuer die zu testende Logik selbst.
- Verifikation auf das fachlich relevante Verhalten beschraenken (welcher Aufruf mit
  welchem Ergebnis), nicht auf jede interne Implementierungsdetail-Interaktion.

## Datenschutz

- Keine echten Namen, Konten, Kennzeichen, E-Mails oder Zugangsdaten in Testdaten.
- Synthetische IDs und neutrale Beispiele nutzen.
- Produktionsauszuege vor Verwendung anonymisieren.

## UI- und E2E-Tests

- Stabile Test-Selektoren (z. B. `data-testid`) vor fragilen CSS-Selektoren bevorzugen.
- Kein festes Warten (`sleep`); auf echte Bedingungen warten.
- Headless in CI, sichtbar nur fuer lokales Debugging.
- Testdaten und erzeugte Artefakte nach Testlauf aufraeumen.

## TDD — Compile-/Build-Fehler und offene Fragen

Ergaenzung zur TDD-Rollentrennung (Mechanik/Worker-Koordination:
`01-arbeitsweise\richtlinien\koordination\schleifen-und-review.md`, Abschnitt „TDD-Variante"):

- **Compile-/Build-Fehler = gueltiger Rot-Zustand:** Schreibt der Tester Tests gegen noch
  nicht existierende Typen oder Member (additiver Fall), ist ein Compile-/Build-Fehler ein
  gueltiger „rot"-Zustand — der Test-Worker legt die neuen Typen nicht selbst an; das
  ist Aufgabe des Implementierungs-Workers.
- **Offene Typ-/Konventionsfragen vor der Impl klaeren:** Stoesst der Tester auf unklare
  Typen, Namenskonventionen oder Entwurfsfragen, stellt er diese **gebuendelt dem
  Koordinator/Mensch, bevor die Implementierung beginnt**. Kein stilles Entscheiden durch
  den Tester; Antworten kommen als Planerweiterung zurueck, dann erst startet der
  Implementierungs-Worker.

## Review-Check

- Deckt der Test Verhalten oder nur Implementierung ab?
- Ist der Fehlerfall explizit?
- Laeuft der Test ohne Reihenfolgeabhaengigkeit?
- Sind Namen und Assertions fuer Leser sofort klar?
