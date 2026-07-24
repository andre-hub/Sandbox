# Projekte und Firmenkontext

Die allgemeine Wissensdatenbank (`Arbeitsweise`, `Softwareentwicklung`,
`Infrastruktur`, `Sicherheit`) bleibt firmen- und projektunabhaengig. Konkrete
Projekte und Firmenwissen liegen getrennt und flach.

## Zwei Ablageorte

- `05-projekte\<projekt>\` - **allgemeine, firmenneutrale Projekte** (eigene Tools,
  Home-Projekte). Vorlage: `05-projekte\_vorlagen\projekt\`.
- `<Firma>\` - **firmenspezifischer Hauptordner top-level** (je Firma genau einer,
  flach), z. B. `C:\wissensdatenbank\<Firma>\`. Vorlage: `06-vorlagen\firma\`. Wird nie
  in die Sandbox committet und nie automatisch ueberschrieben.

Firmen liegen bewusst NICHT unter `05-projekte\`, damit die Ordner flach bleiben.

## Firmen-Hauptordner (flach)

```text
C:\wissensdatenbank\<Firma>\
  README.md
  unternehmen.md        # Ueberblick, Konventionen, Glossar
  landschaft.md         # Systemlandschaft/Service-Registry (enterprise-architect)
  infrastruktur.md      # Umgebungen, Betrieb, Freigaben
  regeln.md             # firmenweite Eskalations-/Freigaberegeln
  <Produkt>\
    README.md  regeln.md  steckbrief.md  arc42.md
```

`landschaft.md` ist besonders fuer `enterprise-architect` relevant, wenn mehrere
Anwendungen/Services derselben Firma zusammenhaengen (Service-Registry,
Integrationsmuster, geteilte Vertraege/Libraries).

## regeln.md - Minimalinhalt

Jede `<Firma>\regeln.md` bzw. `<Firma>\<Produkt>\regeln.md` bleibt kurz und pruefbar:

```markdown
# Regeln: <Firma> / <Produkt>

## Eskalationen
- <Aktion, die nie autonom entschieden werden darf, mit Begruendung>

## Standards und Referenzen
- <firmeninterne Coding-/Test-/Git-Standards, falls vorhanden>

## Architektur/Kontext
- <Verweis auf arc42.md, ADRs, Systemlandschaft>
```

## Wie Agenten das nutzen

- Bei Arbeit in einem bekannten Firmen-Repo: `<Firma>\regeln.md` und ggf.
  `<Firma>\<Produkt>\regeln.md` zusaetzlich zu `01-arbeitsweise\arbeitsweise.md` und
  `01-arbeitsweise\rollen.md` lesen.
- Generische Regeln haben Vorrang bei Methodik/Sicherheit; `regeln.md` ergaenzt oder
  verschaerft nur firmenspezifisch und schwaecht die Sicherheitsregeln nie ab.
- Ist kein `<Firma>\`-Ordner vorhanden, gelten ausschliesslich die generischen Regeln.

## Nicht in die Sandbox committen

Firmen-Hauptordner (`<Firma>\`) und `05-projekte\<projekt>\`-Instanzen sind kein
Bestandteil von `modules\ai-workflow\wissensdatenbank` und werden von
`setup-ai-workflow.bat` weder erzeugt noch beim Neubefuellen der Wissensdatenbank
geloescht oder ueberschrieben. Nur `05-projekte\_vorlagen\` und `06-vorlagen\firma\` sind
neutrale, auslieferbare Vorlagen.