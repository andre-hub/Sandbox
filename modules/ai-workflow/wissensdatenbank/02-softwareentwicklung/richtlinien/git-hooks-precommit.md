# Pre-Commit-Hooks

## Ziel

Pre-Commit-Hooks stoppen einfache Fehler moeglichst frueh: kaputte Tests, falsche
Zeilenenden, vergessene Formatierung oder offensichtliche Secrets.

## Geeignete Checks

- gezielte Tests fuer den geaenderten Scope
- Formatierung oder Linting
- Secret-Scan oder verbotene Dateimuster
- schnelle Syntax-Checks

Hooks muessen schnell genug bleiben, sonst werden sie regelmaessig umgangen.

## Beispiel: `dotnet test`

```sh
#!/bin/sh
REPO_ROOT=$(git rev-parse --show-toplevel)
FAILED=0

SLN_FILES=$(find "$REPO_ROOT" -maxdepth 5 -name "*.sln" | grep -v "/bin/" | grep -v "/obj/")

if [ -z "$SLN_FILES" ]; then
  TEST_PROJS=$(find "$REPO_ROOT" -name "*Tests*.csproj" -o -name "*Test.csproj" | grep -v "/bin/" | grep -v "/obj/")
  for PROJ in $TEST_PROJS; do
    dotnet test "$PROJ" --verbosity quiet || FAILED=1
  done
else
  for SLN in $SLN_FILES; do
    dotnet test "$SLN" --verbosity quiet || FAILED=1
  done
fi

[ $FAILED -eq 0 ] || exit 1
```

## Windows-Fallstricke

- Shell-Hooks ohne BOM speichern.
- LF statt CRLF verwenden, wenn `#!/bin/sh` beteiligt ist.
- Lange PowerShell-Logik besser in ein separates Skript auslagern.

## Notfall-Bypass

`git commit --no-verify`

Nur fuer begruendete Ausnahmen. Wenn Teams den Bypass staendig brauchen, ist der Hook zu langsam oder zu breit.

## Review-Check

- Ist der Hook reproduzierbar auf frischen Maschinen?
- Ist klar, welche Checks blockierend sind?
- Sind Dauer und Fehlermeldungen fuer Entwickler zumutbar?

