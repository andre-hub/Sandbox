@echo off
REM ============================================================
REM  gitex.cmd - GitExtensions fuer das aktuelle Git-Repository
REM  oeffnen. Bricht ab wenn kein Git-Repo vorhanden.
REM ============================================================
set "GITEX=C:\Program Files\GitExtensions\GitExtensions.exe"

if not exist "%GITEX%" (
    echo [FEHLER] GitExtensions nicht gefunden: %GITEX%
    exit /b 1
)

git rev-parse --git-dir >nul 2>&1
if %errorlevel% neq 0 (
    echo [FEHLER] "%CD%" ist kein Git-Repository.
    exit /b 1
)

start "" "%GITEX%" browse "%CD%"
