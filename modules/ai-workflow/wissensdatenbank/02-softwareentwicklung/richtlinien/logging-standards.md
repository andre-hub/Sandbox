# Logging Standards

## Ziel

Logs sollen drei Dinge leisten: nachvollziehbare Ereignisse, schnelle Fehlerdiagnose und
saubere Datenschutzgrenzen.

## Grundregeln

- Strukturierte Logs statt frei formulierter Texte.
- Korrelation ueber eine Request-, Message- oder Workflow-ID.
- Fachereignisse auf `Information`, Defekte auf `Error` oder `Critical`.
- Keine Geheimnisse oder personenbezogenen Daten loggen.

## Log-Level

| Level | Einsatz |
|---|---|
| Trace | sehr detailreiche Diagnose, meist nur lokal |
| Debug | Entwicklungsdetails, temporaere Diagnose |
| Information | Start, Ende, Statuswechsel, Fachmeilenstein |
| Warning | unerwarteter, aber behandelter Zustand |
| Error | Operation fehlgeschlagen |
| Critical | Dienst oder Plattform stark beeintraechtigt |

## Strukturierte Parameter

```csharp
_logger.LogInformation(
    "Processing order {OrderId} with status {Status}",
    orderId,
    status);
```

- Stabile Feldnamen verwenden.
- Serialisierte Objekte sparsam loggen.
- IDs, Dauer, Retry-Zahl, Phase und Ursache priorisieren.

## Datenschutz und Secrets

Nie in Logs schreiben:
- Namen, Adressen, Telefonnummern, E-Mails
- Kontodaten, Fahrzeugdaten, Personalausweisnummern
- Passwoerter, Tokens, API-Keys, Connection Strings

Erlaubt sind technische IDs, Statuswerte, Timestamps, Fehlertypen und gekuerzte Referenzen.

## Fehler in Verarbeitungspipelines

```csharp
catch (Exception ex)
{
    _logger.LogError(ex,
        "Phase {PhaseName} failed for {CorrelationId}",
        phaseName,
        correlationId);
    context.ContinueWorkflow = false;
}
```

- Phase oder Use Case nennen.
- Korrelation mitgeben.
- Abbruchzustand explizit markieren, nicht still verschwinden.

## Review-Check

- Ist die Log-Nachricht auswertbar, ohne Quellcode zu lesen?
- Fehlt eine Korrelation?
- Wird versehentlich PII oder ein Secret mitgeloggt?
- Passt der Level zur Auswirkung?

