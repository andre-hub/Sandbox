# Stufenweise Softwareentwicklung

## Ziel

Nicht sofort aendern, sondern in nachvollziehbaren Stufen arbeiten. Jede Stufe erzeugt
Evidenz fuer die naechste.

## Phasen

1. Intake und Klassifikation
2. Exploration
3. Design und Plan
4. Umsetzung
5. Verifikation
6. Review, Doku und Abschluss

## Gates

| Gate | Bedeutung |
|---|---|
| G1 | Ziel, Scope und Aufgabenart klar |
| G2 | Betroffene Artefakte, Risiken, Wissensluecken benannt |
| G3 | Plan, Akzeptanzkriterien und Verifikation stehen |
| G4 | Umsetzung abgeschlossen oder bewusst begrenzt |
| G5 | Akzeptanzkriterien geprueft |
| G6 | Review, Doku und Handoff abgeschlossen |

## Leitlinien

- Erst Evidenz, dann Fix.
- Erst gezielte Checks, dann breitere Regression.
- Handoffs muessen ohne Rueckfrage nutzbar sein.
- Dauerwissen kommt in die Wissensdatenbank; Sitzungsverlauf in Plan- oder Statusdateien.

## Typische Trigger

- Unklarer Scope -> mehr Exploration
- Oeffentliche API oder Vertrag -> Design und Review verpflichtend
- Infrastruktur oder Runtime -> zuerst Beobachtbarkeit und Diagnose
- Grosses Refactoring -> eigener Plan, eigene Review-Runde

## Minimales Handoff

```md
## Handoff
- Ziel:
- Scope:
- Gesicherte Erkenntnisse:
- Entscheidungen:
- Risiken:
- Verifikation:
- Naechster Schritt:
```

