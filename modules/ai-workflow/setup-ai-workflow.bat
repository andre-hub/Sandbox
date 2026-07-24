@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SRC=%~dp0"
set "WDB=C:\wissensdatenbank"
set "WT=%USERPROFILE%\Documents\windows-terminal"

for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "TS=%%I"
set "BACKUP=%USERPROFILE%\ai-workflow-backup-%TS%"

if not exist "%SRC%wissensdatenbank\" (
    echo [ERROR] Wissensdatenbank-Quelle fehlt: %SRC%wissensdatenbank
    exit /b 1
)
if not exist "%SRC%Agents.md" (
    echo [ERROR] Zentrale Context-Quelle fehlt: %SRC%Agents.md
    exit /b 1
)
if not exist "%SRC%deploy-roles.ps1" (
    echo [ERROR] Rollen-Deploy-Skript fehlt: %SRC%deploy-roles.ps1
    exit /b 1
)
echo.
echo === AI-Workflow Setup (erweitert) ===
echo Quelle : %SRC%
echo Backup : %BACKUP% ^(wird nur angelegt, wenn etwas zu sichern ist^)
echo.

call :backup_file "%USERPROFILE%\.copilot\copilot-instructions.md" "%BACKUP%\copilot\copilot-instructions.md" || exit /b 1
call :backup_dir  "%USERPROFILE%\.copilot\agents"                "%BACKUP%\copilot\agents" || exit /b 1
call :backup_file "%USERPROFILE%\.claude\CLAUDE.md"                "%BACKUP%\claude\CLAUDE.md" || exit /b 1
call :backup_dir  "%USERPROFILE%\.claude\agents"                  "%BACKUP%\claude\agents" || exit /b 1
call :backup_file "%USERPROFILE%\.codex\AGENTS.md"                 "%BACKUP%\codex\AGENTS.md" || exit /b 1
call :backup_file "%WT%\ai-aliases.cmd"                            "%BACKUP%\windows-terminal\ai-aliases.cmd" || exit /b 1
call :backup_file "%WT%\ai-spawn.cmd"                              "%BACKUP%\windows-terminal\ai-spawn.cmd" || exit /b 1
call :backup_file "%WT%\ai-multi.cmd"                              "%BACKUP%\windows-terminal\ai-multi.cmd" || exit /b 1
call :backup_file "%WT%\ai-spawn-direct.ps1"                       "%BACKUP%\windows-terminal\ai-spawn-direct.ps1" || exit /b 1
call :backup_file "%WT%\ai-worker-lib.ps1"                         "%BACKUP%\windows-terminal\ai-worker-lib.ps1" || exit /b 1
call :backup_file "%WT%\ai-workers.ps1"                            "%BACKUP%\windows-terminal\ai-workers.ps1" || exit /b 1
call :backup_file "%WT%\ai-send.ps1"                               "%BACKUP%\windows-terminal\ai-send.ps1" || exit /b 1
call :backup_file "%WT%\ai-close.ps1"                              "%BACKUP%\windows-terminal\ai-close.ps1" || exit /b 1
call :backup_file "%WT%\ai-worker-done.ps1"                        "%BACKUP%\windows-terminal\ai-worker-done.ps1" || exit /b 1
call :backup_file "%WT%\ai-coord-handoff.ps1"                      "%BACKUP%\windows-terminal\ai-coord-handoff.ps1" || exit /b 1

if exist "%BACKUP%" (
    echo [OK] Backup vorhandener Rollen/Instruktionen angelegt.
) else (
    echo [OK] Keine vorhandenen Rollen/Instruktionen zu sichern.
)

REM Keine Profilordner loeschen: lokale, nicht vom Modul verwaltete Dateien bleiben erhalten.
call :ensure_dir "%USERPROFILE%\.copilot\agents" || exit /b 1
copy /Y "%SRC%Agents.md" "%USERPROFILE%\.copilot\copilot-instructions.md" >nul
if errorlevel 1 exit /b 1
echo [OK] copilot: zentraler Context aktualisiert (%USERPROFILE%\.copilot)

call :ensure_dir "%USERPROFILE%\.claude\agents" || exit /b 1
copy /Y "%SRC%Agents.md" "%USERPROFILE%\.claude\CLAUDE.md" >nul
if errorlevel 1 exit /b 1
echo [OK] claude: zentraler Context aktualisiert  (%USERPROFILE%\.claude)

call :ensure_dir "%USERPROFILE%\.codex" || exit /b 1
copy /Y "%SRC%Agents.md" "%USERPROFILE%\.codex\AGENTS.md" >nul
if errorlevel 1 exit /b 1
echo [OK] codex: AGENTS.md                       (%USERPROFILE%\.codex)

call :ensure_dir "%WT%" || exit /b 1
copy /Y "%SRC%windows-terminal\ai-spawn-direct.ps1" "%WT%\ai-spawn-direct.ps1" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-spawn.cmd" "%WT%\ai-spawn.cmd" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-multi.cmd" "%WT%\ai-multi.cmd" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-aliases.cmd" "%WT%\ai-aliases.cmd" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-worker-lib.ps1" "%WT%\ai-worker-lib.ps1" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-workers.ps1" "%WT%\ai-workers.ps1" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-send.ps1" "%WT%\ai-send.ps1" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-close.ps1" "%WT%\ai-close.ps1" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-worker-done.ps1" "%WT%\ai-worker-done.ps1" >nul
if errorlevel 1 exit /b 1
copy /Y "%SRC%windows-terminal\ai-coord-handoff.ps1" "%WT%\ai-coord-handoff.ps1" >nul
if errorlevel 1 exit /b 1
echo [OK] Spawner/Aliase + Worker-Toolkette installiert (%WT%)

REM Lokale Firmenordner direkt unter %WDB% sowie firmenneutrale Instanzen unter
REM %WDB%\05-projekte werden nie automatisch geloescht oder ueberschrieben.
if exist "%WDB%" (
    call :backup_dir "%WDB%" "%BACKUP%\wissensdatenbank" || exit /b 1
)
call :ensure_dir "%WDB%" || exit /b 1
REM Obsolete, ausschliesslich vom Modul verwaltete Altpfade vor dem Overlay entfernen.
for %%F in (arbeitsweise.md plaene.md recherche.md projekte.md rollen.md sicherheit.md log.md) do del /Q "%WDB%\%%F" >nul 2>&1
for %%D in (richtlinien rollen vorlagen) do if exist "%WDB%\%%D\" rmdir /S /Q "%WDB%\%%D"
xcopy /Y /E /I "%SRC%wissensdatenbank\*" "%WDB%\" >nul
if errorlevel 1 exit /b 1
echo [OK] Wissensdatenbank aktualisiert            (%WDB%)
echo [INFO] Firmen-/Produktvorlage: %WDB%\06-vorlagen\firma

set /p "do_roles=Freigegebene Rollen jetzt in aktive CLI-Agent-Ordner deployen? [j/N]: "
if /i "%do_roles%"=="j" call :deploy_roles || exit /b 1
if /i "%do_roles%"=="ja" call :deploy_roles || exit /b 1

echo.
set /p "do_cli=AI-CLIs jetzt per npm installieren (copilot/claude/codex)? [j/N]: "
if /i "%do_cli%"=="j" call :install_optional_ai_clis
if /i "%do_cli%"=="ja" call :install_optional_ai_clis

echo.
echo === Fertig. ===
where wt      >nul 2>&1 && echo [OK] Windows Terminal gefunden. || echo [WARN] wt.exe nicht im PATH - Worker-Tabs brauchen Windows Terminal.
where copilot >nul 2>&1 && echo [OK] copilot gefunden. || echo [INFO] copilot nicht im PATH.
where claude  >nul 2>&1 && echo [OK] claude  gefunden. || echo [INFO] claude nicht im PATH.
where codex   >nul 2>&1 && echo [OK] codex   gefunden. || echo [INFO] codex nicht im PATH.
echo.
echo Einstieg: %WDB%\01-arbeitsweise\arbeitsweise.md
echo Rollen : %WDB%\01-arbeitsweise\rollen.md
if exist "%BACKUP%" echo Backup : %BACKUP%
echo Hinweis: Kurze Spawn-Aliase wie cs/xs/cps werden nicht installiert. Nutze aispawn oder aimulti.
echo.
endlocal
exit /b 0

:ensure_dir
if not exist "%~1" (
    mkdir "%~1" >nul 2>&1
    if errorlevel 1 (echo [ERROR] Konnte Ordner nicht anlegen: %~1 & exit /b 1)
)
exit /b 0

:backup_file
if not exist "%~1" exit /b 0
call :ensure_dir "%BACKUP%" || exit /b 1
call :ensure_dir "%~dp2" || exit /b 1
copy /Y "%~1" "%~2" >nul
if errorlevel 1 (echo [ERROR] Backup fehlgeschlagen: %~1 & exit /b 1)
exit /b 0

:backup_dir
if not exist "%~1" exit /b 0
call :ensure_dir "%BACKUP%" || exit /b 1
robocopy "%~1" "%~2" /E /COPY:DAT /DCOPY:DAT /R:2 /W:1 /XJ >nul
if errorlevel 8 (echo [ERROR] Backup fehlgeschlagen: %~1 & exit /b 1)
exit /b 0

:install_optional_ai_clis
call "%SRC%install-ai-clis.bat"
if errorlevel 1 (
    echo [WARN] AI-CLI-Installation fehlgeschlagen - Setup der Wissensdatenbank bleibt erhalten.
)
exit /b 0

:deploy_roles
powershell -NoProfile -ExecutionPolicy Bypass -File "%SRC%deploy-roles.ps1" -RollenDir "%WDB%\01-arbeitsweise\rollen" -AgentsMd "%SRC%Agents.md" -CopilotDir "%USERPROFILE%\.copilot\agents" -ClaudeDir "%USERPROFILE%\.claude\agents" -TrustedRoles "anforderer,architect,assistant,developer,devops,documenter,enterprise-architect,explorer,frontend,quality,refactorer,researcher,reviewer,security,tester" -ApproveDeployment
if errorlevel 1 exit /b 1
echo [OK] Explizit freigegebene Rollen aktualisiert.
exit /b 0
