# DDD-Grundlagen

## Ziel

Domain-Driven Design trennt Fachlogik von Technikdetails. Das hilft, Regeln klar zu
modellieren und Infrastruktur spaeter austauschbar zu halten.

## Schichten

```text
UI/API -> Application -> Domain <- Infrastructure
```

| Schicht | Verantwortung |
|---|---|
| UI/API | Transport, Validierung am Rand, Mapping |
| Application | Use Cases, Orchestrierung, Transaktionen |
| Domain | Entitaeten, Value Objects, Aggregate, Regeln |
| Infrastructure | Datenbanken, Messaging, externe Systeme |

Die Domain kennt keine HTTP-Clients, Datenbanktreiber oder UI-Frameworks.

## Typische Bausteine

- Entitaet: hat Identitaet und Verhalten.
- Value Object: unveraenderlich, vergleichbar ueber Wert.
- Aggregate: Konsistenzgrenze rund um eine Wurzel.
- Repository: Zugriffspunkt fuer Aggregate.
- Domain Service: Regel, die nicht gut in ein einzelnes Objekt passt.
- Domain Event: beschreibt etwas Relevantes, das passiert ist.

## Ports und Adapter

Externe Systeme ueber Interfaces kapseln. Die Fachsprache bleibt innen stabil, der Adapter uebersetzt.

```text
Externes DTO -> Adapter -> Domain-Interface -> Domainmodell
```

## Application-Layer

- baut Workflows und Use Cases
- verwendet Domainobjekte
- enthaelt moeglichst wenig echte Fachregeln
- kapselt Seiteneffekte ueber Ports

## Review-Check

- Liegt Geschaeftslogik versehentlich in Controller, Consumer oder Repository?
- Ist die Domain unabhaengig von Frameworktypen?
- Sind Aggregate und Transaktionsgrenzen erkennbar?
- Gibt es fuer Fremdsysteme eine Anti-Corruption-Schicht?

