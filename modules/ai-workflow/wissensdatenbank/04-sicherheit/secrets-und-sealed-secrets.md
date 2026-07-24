# Secrets und Sealed Secrets

## Ziel

Geheimnisse duerfen versioniert werden, aber nie im Klartext. Die saubere Trennung
zwischen Quellcode, Manifesten und geheimen Werten ist Pflicht.

## Grundsatz

- Klartext-Secrets nie committen.
- Nicht-sensitive Werte in ConfigMaps oder normalen Konfigurationsdateien halten.
- Secrets verschluesselt oder ueber Secret-Manager bereitstellen.

## Sealed-Secret-Muster

```text
Klartext lokal -> verschluesseltes Manifest in Git -> Entschluesselung nur im Cluster
```

## Leitlinien

- Verschluesselung an Namespace oder Scope binden, wenn das Werkzeug es unterstuetzt.
- Temporaere Klartextdateien nach dem Versiegeln sofort entfernen.
- Secret-Rotation als wiederkehrenden Prozess einplanen.
- Referenzen im Deployment ueber `secretKeyRef`, nicht ueber hart codierte Werte.

## Checkliste vor dem Commit

- Kein `kind: Secret` im Klartext im Staging-Bereich
- Richtiger Namespace oder Scope
- Temporaere Dateien geloescht
- Deployment referenziert den Secret-Namen korrekt

## Review-Check

- Koennen neue Teammitglieder das Secret-Verfahren verstehen, ohne Klartexte zu sehen?
- Ist der Rotationspfad dokumentiert?
- Sind Beispiele und Tests ohne echte Geheimnisse?

