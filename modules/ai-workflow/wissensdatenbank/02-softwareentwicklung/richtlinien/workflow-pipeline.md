# Workflow-Pipeline

## Ziel

Ein Verarbeitungslauf wird in kleine, klar benannte Phasen zerlegt. Das macht Logging,
Tests, Fehlerbehandlung und Wiederverwendung einfacher.

## Modell

```text
Consumer/Entry -> Executor -> Phasen -> Domain Services -> Infrastructure
```

## Kerninterface

```csharp
public interface IWorkflowPhase<TContext>
{
    string Name { get; }
    Task ExecuteAsync(TContext context, CancellationToken ct);
}
```

## Kontextobjekt

```csharp
public class ProcessingContext
{
    public Guid CorrelationId { get; init; }
    public bool ContinueWorkflow { get; set; } = true;
    public string? ErrorMessage { get; set; }
}
```

Abgeleitete Kontexte tragen fachliche Zwischenergebnisse.

## Executor

```csharp
foreach (var phase in phases)
{
    if (!context.ContinueWorkflow)
        break;

    await phase.ExecuteAsync(context, cancellationToken);
}
```

## Phasenregeln

- Eine Phase = eine klar benannte Verantwortung.
- Keine stillen Fehler.
- Bei Abbruch Ursache im Kontext und im Log festhalten.
- Seiteneffekte nur dort, wo sie erwartet werden.

## Fehlerbehandlung

```csharp
catch (Exception ex)
{
    context.ContinueWorkflow = false;
    context.ErrorMessage = ex.Message;
    _logger.LogError(ex, "Phase {PhaseName} failed for {CorrelationId}", Name, context.CorrelationId);
}
```

## Review-Check

- Sind Phasen klein genug?
- Ist die Reihenfolge bewusst und dokumentiert?
- Koennen einzelne Phasen isoliert getestet werden?
- Ist der Abbruchmechanismus fuer Leser eindeutig?

