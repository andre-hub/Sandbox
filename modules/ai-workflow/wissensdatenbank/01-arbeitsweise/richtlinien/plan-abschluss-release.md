# Plan-Abschluss und Release-Phase

Letzter Schritt eines Plans: Repos PR-fertig machen, pushen, PRs oeffnen und mergen.
Gilt vor allem fuer Multi-Repo-Tickets mit Paket-Kopplung (Upstream baut Paket,
Downstream konsumiert es), funktioniert analog fuer einfachere Faelle.

Vorgelagert: Umsetzung abgeschlossen, alle Worker-Worktrees in den Feature-Branch
integriert, Review + Tests gruen. Dieser Artikel beschreibt nur den Abschluss-Lauf.

Rollen/Koordination: `01-arbeitsweise\richtlinien\koordination-und-worker.md`
Git-Worktree-Grundlagen: `02-softwareentwicklung\richtlinien\git-workflow.md`

---

## 1. Definition of Done je Repo (Voraussetzung)

Bevor der Abschluss-Lauf beginnt, gilt je Repo:

- Code-Stand **vollstaendig** (kein TODO/Stub ohne bewusste Entscheidung).
- **Genau 1 Commit ueber `origin/<main-branch>`** (WIP squasht):
  `git log --oneline origin/<main-branch>..HEAD` zeigt genau eine Zeile.
- Commit-Message: **Einzeiler**, kein Fliesstext, kein `Co-authored-by`/Agenten-Trailer.
- Arbeitsverzeichnis **sauber**: `git status` zeigt keine uncommitteten Aenderungen.
- Lokale Tests + Build **gruen**.

Sind mehrere Repos beteiligt: erst alle Repos in diesen Zustand bringen, dann
mit Schritt 2 beginnen.

---

## 2. Saubere Release-Version herstellen (kein Dev-Suffix)

Lokale Dev-Builds nutzen einen Prerelease-Suffix (`<release-version><prerelease-suffix>`)
und einen lokalen Feed (`<lokaler-feed>`). Fuer den PR-fertigen Commit gilt:

- **Upstream-Repo `<upstream-paket-repo>`:** Release-Version `<release-version>` ohne Suffix
  (Zeile `<VersionPrefix>` in der csproj unveraendert, `<VersionSuffix>` nicht gesetzt);
  kein `dotnet pack` mit Suffix mehr noetig — die CI publiziert aus dem gemergten Stand.
- **Downstream-Repo `<downstream-repo>`:**
  - `<PackageReference>` auf glatte Release-Version `<release-version>` (ohne Suffix) re-pinnen.
  - Lokalen Feed-Eintrag (`<lokaler-feed>`) **aus der committeten `nuget.config`/Paketquelle entfernen**.
  - Begruendung: die interne Registry (`<interne-registry>`) kennt `<lokaler-feed>` nicht;
    ein verbliebener lokaler Pfad bricht die CI sofort.

### Trick: Gruen-Verifikation trotz noch-nicht-publiziertem Paket

Das offizielle Paket ist erst nach dem Upstream-Merge in `<interne-registry>` verfuegbar.
So trotzdem lokal gruen verifizieren, bevor der lokale Feed aus dem Commit entfernt wird:

1. Im `<upstream-paket-repo>`: sauberes Paket mit der **finalen Release-Version**
   (ohne Suffix) lokal bauen:
   ```powershell
   dotnet pack -c Release -p:PackageVersion=<release-version> -o <lokaler-feed>
   ```
2. Im `<downstream-repo>`: `<PackageReference>` auf `<release-version>` pinnen,
   lokalen Feed **temporaer** noch aktiv lassen → `dotnet restore` + Tests gruen.
3. Erst jetzt lokalen Feed-Eintrag aus `nuget.config` entfernen, Downstream-Stand committen.
4. `git status` sauber → Commit amenden oder neu committen.

Ergebnis: Commit ist PR-fertig (kein lokaler Feed) **und** lokal verifiziert gruen.

---

## 3. Pre-Push-Hygiene je Repo

Unmittelbar vor dem Push, je Repo einzeln:

1. `git fetch` — pruefe, dass `origin/<main-branch>` unveraendert ist (kein neuer Commit
   seit Arbeitsbeginn, kein Rebase-Bedarf).
2. `git log --oneline origin/<main-branch>..HEAD` → exakt 1 Zeile.
3. `git log -1 --format="%s"` → Einzeiler ohne Trailer pruefe.
4. `git status` → sauber.
5. Commit-Message unpassend oder zu ausfuehrlich? **Jetzt per amend korrigieren**,
   vor dem Push. Nach dem Push ist kein Force moeglich (Branch ist geteilt).

---

## 4. Push-Gate (verbindlich)

Kein Push ohne explizite aktuelle Bestaetigung:

- Remote-URL und Branch-Name **nochmals anzeigen** und mit dem Menschen abgleichen
  (besonders bei mehreren Repos im gleichen Terminal-Kontext: falsches Repo leicht).
- Kein Force-Push auf geteilte/gemeinsame Branches.
- Push je Repo separat (nicht alles auf einmal per Skript, ohne Pruefung).
- **Der Mensch oeffnet die PRs** (nur Hauptbeschreibung + wenige Commits, keine
  WIP-Details).

**Push-Timing:** der Mensch entscheidet vor dem ersten Push:
- *Gebuendelt am Planende* — alle Repos fertig, dann alle pushen. Kein halbfertiger
  Remote-Zustand; laengere lokale Arbeit ohne Remote-Backup.
- *Pro Repo sobald fertig* — Upstream-Push + Merge abwarten, dann Downstream.
  Frueheres CI-Feedback je Repo, aber Downstream-CI zeigt rote Pipelines bis Upstream
  fertig (erwartet, siehe Schritt 5).

---

## 5. Merge-Reihenfolge und erwartete rote Pipelines

Bei Paket-Kopplung (`<upstream-paket-repo>` baut Paket, `<downstream-repo>` konsumiert):

```
<upstream-paket-repo>  PR oeffnen → review → merge
                       ↓ CI publiziert <release-version> in <interne-registry>
<downstream-repo>      PR oeffnen → CI wird gruen → review → merge
```

- **Upstream zuerst** mergen — CI publiziert das Paket in `<interne-registry>`.
- **Downstream-Pipelines sind bis zum Upstream-Merge bewusst rot** (Paket noch nicht
  verfuegbar). Das ist erwartetes Verhalten, kein Fehler. Klar kommunizieren (PR-Beschreibung
  oder Kommentar): „Warte auf Upstream-Merge und Paket-Publikation."
- Erst nachdem Upstream-CI gruen + Paket publiziert: Downstream-PR mergen.

Umsetzungs-Variante dieser Reihenfolge (Upstream frueh pushen, Downstream parallel starten): `01-arbeitsweise\plaene.md` §Plan-Struktur/Kaskaden-Kopf.

---

## 6. Checkout-Umbau fuer lokales Testen nach dem Merge

Nach dem Merge stehen die Repos lokal noch auf den Feature-Branches in den Worktrees
(`<worktree>`). Fuer lokales Testen (z. B. wsl-connect, minikube) wird der
`<haupt-checkout>` benoetigt:

1. **Worktrees pruefen:** `git worktree list` — alle sauber (`clean`)?
2. **Feature-Branch im `<haupt-checkout>` auschecken:**
   ```powershell
   cd <haupt-checkout>
   git fetch
   git checkout <feature-branch>
   ```
3. Erst jetzt (optional): Worktree entfernen, wenn er nicht mehr benoetigt wird:
   ```powershell
   git worktree remove <worktree>
   git worktree prune
   ```
   Branch-Ref nicht ungefragt loeschen — erst nach erfolgtem Merge + lokaler Verifikation.
4. **Lokaler Build/Restore zieht automatisch aus `<interne-registry>`**, sobald die
   Release-Version dort verfuegbar ist. Kein dauerhafter lokaler Feed noetig;
   das lokal gebaute Release-Paket kann als Fallback in `<lokaler-feed>` bleiben,
   ist aber nicht eingebunden.

---

## 7. Wissenssicherung und Aufraumen

Parallel zum Merge-Lauf, nicht vertagen:

- **Generisches Wissen in die WDB:** Methodik, Stolperstellen, Erkenntnisse verallgemeinert
  festhalten (kein Ticket-Bezug, keine konkreten Commit-Hashes). Ticket-spezifisches
  gehoert in den Planordner, nicht in Methodik-Artikel.
- **Tech-Debt-Eintraege:** bekannte, bewusst zurueckgestellte Punkte im Plan oder in einem
  separaten Backlog-Eintrag sichern, bevor der Plan archiviert wird.
- **Aufraeumen nach vollstaendigem Merge:**
  - Veraltete Worktrees entfernen (`git worktree remove`, `git worktree prune`).
  - Lokalen Dev-Feed-Eintrag (`<lokaler-feed>`) aus `nuget.config` entfernen (falls nicht
    schon in Schritt 2 geschehen).
  - Plan-Ordner archivieren: `plan\_archiv\<name>\` (verschieben, nicht loeschen).

---

## Checkliste (abhakbar)

**Vorbereitung je Repo**
- [ ] Genau 1 Commit ueber `origin/<main-branch>` (kein WIP mehr)
- [ ] Commit-Message Einzeiler, kein Trailer
- [ ] `git status` sauber
- [ ] Lokale Tests + Build gruen

**Release-Version (bei Paket-Kopplung)**
- [ ] `<upstream-paket-repo>`: csproj auf `<release-version>` ohne Suffix
- [ ] Lokales Release-Paket gebaut + Downstream damit gruen verifiziert
- [ ] `<downstream-repo>`: Re-Pin auf `<release-version>`, lokaler Feed aus `nuget.config` entfernt
- [ ] `git status` sauber nach Re-Pin + Feed-Entfernung

**Pre-Push (je Repo)**
- [ ] `git fetch` — `origin/<main-branch>` unveraendert
- [ ] Remote-URL + Branch-Name explizit bestaetigt
- [ ] Commit-Message nochmals geprueft; falls noetig: amend VOR Push

**Push und PRs**
- [ ] Push-Variante (gebuendelt/pro Repo) mit Mensch abgestimmt
- [ ] Kein Force-Push
- [ ] Mensch oeffnet PRs (Hauptbeschreibung + wenige Commits)

**Merge-Reihenfolge**
- [ ] Upstream-PR zuerst gemergt
- [ ] CI publiziert `<release-version>` in `<interne-registry>`
- [ ] Downstream-Pipelines gruen → Downstream-PR mergen

**Nachbereitung**
- [ ] `<haupt-checkout>` auf Feature-Branch aktualisiert (lokales Testen moeglich)
- [ ] Worktrees entfernt (nach Merge + Verifikation)
- [ ] Wissenssicherung in WDB abgeschlossen
- [ ] Tech-Debt-Eintraege gesichert
- [ ] Plan archiviert (`plan\_archiv\<name>\`)

---

## Rollen-Bezug (knapp)

- **Koordinator:** orchestriert Reihenfolge, prueft Pre-Push-Hygiene, gibt Push-Gate
  frei, kommuniziert erwartete rote Pipelines. Kein eigener Commit/Push-Befehl ohne
  Mensch-Freigabe.
- **Worker:** fuehrt Re-Pin, lokalen Build, Test, Commit-Amend, `nuget.config`-Bereinigung
  durch. Ein Worker je Repo (sequenziell bei Paket-Abhaengigkeit).

Mechanik/Auftrag/Blocker-Regel: `01-arbeitsweise\richtlinien\koordination-und-worker.md`
