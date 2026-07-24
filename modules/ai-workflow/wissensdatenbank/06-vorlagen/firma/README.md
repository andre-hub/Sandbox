# <Firma>

Lokaler, firmenspezifischer Wissensordner. Wird als **eigener Hauptordner**
`C:\wissensdatenbank\<Firma>\` gepflegt (nicht unter `05-projekte\`, nicht in die
Sandbox committen). Enthaelt nur freigegebene Informationen; keine Secrets oder
personenbezogenen Daten.

## Aufbau (flach)

| Datei/Ordner | Inhalt |
|---|---|
| `unternehmen.md` | Ueberblick, Konventionen, Glossar, Zustaendigkeiten |
| `landschaft.md` | Systemlandschaft/Service-Registry (fuer `enterprise-architect`) |
| `infrastruktur.md` | Umgebungen, Betrieb, Freigaben |
| `regeln.md` | Firmenweite Eskalations-/Freigaberegeln |
| `produkt\` | Je Produkt EIN flacher Ordner (README, regeln, steckbrief, arc42) |

## Nutzung

- `06-vorlagen\firma\` bewusst nach `<Firma>\` kopieren, Platzhalter ersetzen.
- Produktordner `produkt\` je Produkt duplizieren/umbenennen.
- Firmenregeln ergaenzen/verschaerfen die allgemeine Wissensdatenbank, schwaechen
  Sicherheitsregeln nie ab (siehe `04-sicherheit\sicherheit.md`).
