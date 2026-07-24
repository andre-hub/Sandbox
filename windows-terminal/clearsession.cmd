@echo off
REM ============================================================
REM  clearsession.cmd - Alle Copilot CLI Session-Daten loeschen
REM ============================================================
set "SESSION_DIR=%USERPROFILE%\.copilot\session-state"

if not exist "%SESSION_DIR%" (
    echo [INFO] Kein Session-Verzeichnis gefunden: %SESSION_DIR%
    exit /b 0
)

echo [INFO] Loesche Copilot CLI Session-Daten...
echo  Pfad: %SESSION_DIR%
echo.
rd /s /q "%SESSION_DIR%"
mkdir "%SESSION_DIR%"
echo [OK] Session-Daten geloescht.
