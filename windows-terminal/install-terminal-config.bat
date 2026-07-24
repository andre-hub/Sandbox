@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Windows Terminal Konfiguration

REM  Datenschutz: nutzt ausschliesslich %USERPROFILE% / %USERNAME%.

set "src=%~dp0"
set "profileFolder=%USERPROFILE%\Documents\windows-terminal"
set "termSettings=%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

echo.
echo === Windows Terminal Konfiguration fuer %USERNAME% ===
echo.

if not exist "%profileFolder%" (
    mkdir "%profileFolder%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Profile-Folder konnte nicht angelegt werden: %profileFolder%
        exit /b 1
    )
    echo [OK] Profile-Folder angelegt: %profileFolder%
) else (
    echo [OK] Profile-Folder existiert: %profileFolder%
)

set "clinkDir=%LOCALAPPDATA%\clink"
for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd-HHmmss')"`) do set "ts=%%T"
if not defined ts (
    echo [ERROR] Zeitstempel fuer Backups konnte nicht erzeugt werden.
    exit /b 1
)
set "backupRoot=%profileFolder%\terminal-config-backup-%ts%"
call :backup_file "%profileFolder%\aliases.cmd" "%backupRoot%\profile\aliases.cmd" || exit /b 1
call :backup_file "%profileFolder%\start-minikube.cmd" "%backupRoot%\profile\start-minikube.cmd" || exit /b 1
call :backup_file "%profileFolder%\start-wsl.cmd" "%backupRoot%\profile\start-wsl.cmd" || exit /b 1
call :backup_file "%profileFolder%\wsl-setup.cmd" "%backupRoot%\profile\wsl-setup.cmd" || exit /b 1
call :backup_file "%profileFolder%\wslcheck.cmd" "%backupRoot%\profile\wslcheck.cmd" || exit /b 1
call :backup_file "%profileFolder%\gitex.cmd" "%backupRoot%\profile\gitex.cmd" || exit /b 1
call :backup_file "%profileFolder%\clearsession.cmd" "%backupRoot%\profile\clearsession.cmd" || exit /b 1
call :backup_file "%profileFolder%\git-fetch-all.cmd" "%backupRoot%\profile\git-fetch-all.cmd" || exit /b 1
call :backup_file "%profileFolder%\git-pull-main.cmd" "%backupRoot%\profile\git-pull-main.cmd" || exit /b 1
call :backup_file "%profileFolder%\git-branch-diff.cmd" "%backupRoot%\profile\git-branch-diff.cmd" || exit /b 1
call :backup_file "%profileFolder%\settings.json" "%backupRoot%\profile\settings.json" || exit /b 1
call :backup_file "%termSettings%" "%backupRoot%\terminal\settings.json" || exit /b 1
call :backup_file "%clinkDir%\fzf_bindings.lua" "%backupRoot%\clink\fzf_bindings.lua" || exit /b 1
call :backup_file "%profileFolder%\fzf_bindings.lua" "%backupRoot%\profile\fzf_bindings.lua" || exit /b 1
if exist "%backupRoot%" echo [OK] Lokale Terminal-Dateien gesichert: %backupRoot%

copy /y "%src%aliases.cmd"        "%profileFolder%\aliases.cmd" >nul
if %errorlevel% neq 0 (
    echo [ERROR] aliases.cmd konnte nicht kopiert werden.
    exit /b 1
)
copy /y "%src%start-minikube.cmd" "%profileFolder%\start-minikube.cmd" >nul
if errorlevel 1 (echo [ERROR] start-minikube.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%start-wsl.cmd"      "%profileFolder%\start-wsl.cmd" >nul
if errorlevel 1 (echo [ERROR] start-wsl.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%wsl-setup.cmd"      "%profileFolder%\wsl-setup.cmd" >nul
if errorlevel 1 (echo [ERROR] wsl-setup.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%wslcheck.cmd"       "%profileFolder%\wslcheck.cmd" >nul
if errorlevel 1 (echo [ERROR] wslcheck.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%gitex.cmd" "%profileFolder%\gitex.cmd" >nul
if errorlevel 1 (echo [ERROR] gitex.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%clearsession.cmd" "%profileFolder%\clearsession.cmd" >nul
if errorlevel 1 (echo [ERROR] clearsession.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%git-fetch-all.cmd"   "%profileFolder%\git-fetch-all.cmd" >nul
if errorlevel 1 (echo [ERROR] git-fetch-all.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%git-pull-main.cmd"   "%profileFolder%\git-pull-main.cmd" >nul
if errorlevel 1 (echo [ERROR] git-pull-main.cmd konnte nicht kopiert werden. & exit /b 1)
copy /y "%src%git-branch-diff.cmd" "%profileFolder%\git-branch-diff.cmd" >nul
if errorlevel 1 (echo [ERROR] git-branch-diff.cmd konnte nicht kopiert werden. & exit /b 1)
echo [OK] aliases.cmd, start-minikube.cmd, start-wsl.cmd, wsl-setup.cmd, wslcheck.cmd, gitex.cmd, clearsession.cmd, git-fetch-all.cmd, git-pull-main.cmd, git-branch-diff.cmd installiert.

copy /y "%src%settings.json" "%profileFolder%\settings.json" >nul
if errorlevel 1 (
    echo [ERROR] settings.json konnte nicht in den Profile-Folder kopiert werden.
    exit /b 1
)
echo [OK] settings.json (Vorlage) im Profile-Folder abgelegt.

if not exist "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\" (
    echo [WARN] Windows Terminal scheint nicht installiert zu sein.
    echo        Skript installiert nur die Vorlage in %profileFolder%.
    echo        Nach dem Terminal-Install settings.json manuell ersetzen.
    exit /b 0
)

copy /y "%src%settings.json" "%termSettings%" >nul
if %errorlevel% neq 0 (
    echo [ERROR] settings.json konnte nicht in Terminal-Pfad geschrieben werden.
    exit /b 1
)
echo [OK] Windows-Terminal-settings.json gesetzt.

echo.
echo Startverzeichnis fuer den Command-Prompt-Tab:
echo   [1] %%USERPROFILE%%    (Standard)
echo   [2] C:\projects
set "opt_d=n"
if exist "D:\" set "opt_d=j"
if "%opt_d%"=="j" echo   [3] D:\
set /p "ch_startdir=Auswahl [1]: "
if "%ch_startdir%"=="" set "ch_startdir=1"

set "startDir=%USERPROFILE%"
if "%ch_startdir%"=="2" set "startDir=C:\projects"
if "%ch_startdir%"=="3" if "%opt_d%"=="j" set "startDir=D:\"

if not "%startDir%"=="%USERPROFILE%" (
    if not exist "%startDir%\" (
        echo [WARN] Verzeichnis existiert nicht: %startDir%
        echo        Es wird trotzdem gesetzt -- bitte spaeter anlegen.
    )
    set "STARTDIR_WT=%startDir%"
    REM Base64/-EncodedCommand statt Inline-"-Command": vermeidet, dass
    REM cmd.exe die escapten Anfuehrungszeichen falsch parst und die Zeile
    REM am "|" aufspaltet (fuehrte zu "'Set-Content' is not recognized").
    powershell -NoProfile -EncodedCommand JABkACAAPQAgACQAZQBuAHYAOgBTAFQAQQBSAFQARABJAFIAXwBXAFQAIAAtAHIAZQBwAGwAYQBjAGUAIAAnAFwAXAAnACwAJwAvACcACgAkAGMAbwBuAHQAZQBuAHQAIAA9ACAARwBlAHQALQBDAG8AbgB0AGUAbgB0ACAALQBSAGEAdwAgAC0AUABhAHQAaAAgACQAZQBuAHYAOgB0AGUAcgBtAFMAZQB0AHQAaQBuAGcAcwAKACQAYwBvAG4AdABlAG4AdAAgAD0AIAAkAGMAbwBuAHQAZQBuAHQAIAAtAHIAZQBwAGwAYQBjAGUAIAAnACIAcwB0AGEAcgB0AGkAbgBnAEQAaQByAGUAYwB0AG8AcgB5ACIAXABzACoAOgBcAHMAKgAiAFsAXgAiAF0AKgAiACcALAAgACgAJwAiAHMAdABhAHIAdABpAG4AZwBEAGkAcgBlAGMAdABvAHIAeQAiADoAIAAiACcAIAArACAAJABkACAAKwAgACcAIgAnACkACgBTAGUAdAAtAEMAbwBuAHQAZQBuAHQAIAAtAFAAYQB0AGgAIAAkAGUAbgB2ADoAdABlAHIAbQBTAGUAdAB0AGkAbgBnAHMAIAAtAFYAYQBsAHUAZQAgACQAYwBvAG4AdABlAG4AdAAgAC0ATgBvAE4AZQB3AGwAaQBuAGUA
    if errorlevel 1 (
        echo [WARN] Startverzeichnis konnte nicht in settings.json gesetzt werden.
    ) else (
        echo [OK] Startverzeichnis gesetzt: %startDir%
    )
) else (
    echo [OK] Startverzeichnis: %%USERPROFILE%% ^(Standard, keine Aenderung noetig^)
)

if not exist "%clinkDir%" (
    mkdir "%clinkDir%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] clink Script-Ordner konnte nicht angelegt werden: %clinkDir%
        exit /b 1
    )
)
copy /y "%src%clink\fzf_bindings.lua" "%clinkDir%\fzf_bindings.lua" >nul
if errorlevel 1 (
    echo [ERROR] clink fzf_bindings.lua konnte nicht kopiert werden.
    exit /b 1
)
echo [OK] clink fzf_bindings.lua installiert: %clinkDir%

if exist "%profileFolder%\fzf_bindings.lua" (
    del /f /q "%profileFolder%\fzf_bindings.lua" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] fzf_bindings.lua konnte nicht aus dem Profil-Ordner entfernt werden.
        exit /b 1
    )
    echo [OK] fzf_bindings.lua aus Profil-Ordner entfernt ^(gehoert nach %%LOCALAPPDATA%%\clink^).
)

set "clinkExe=C:\Program Files (x86)\clink\clink_x64.exe"
where clink >nul 2>&1
if not errorlevel 1 (
    clink autorun install --quiet >nul 2>&1
    echo [OK] clink autorun registriert ^(PATH, --quiet^).
) else if exist "%clinkExe%" (
    REM Delayed Expansion ^^!clinkExe^^! statt %%clinkExe%%: der Pfad
    REM enthaelt "(x86)" - bei normaler %%-Expansion wertet cmd die
    REM Klammern des Variableninhalts als Teil der if/else-Blockstruktur
    REM aus und bricht mit ". was unexpected at this time." ab.
    "!clinkExe!" autorun install >nul 2>&1
    echo [OK] clink autorun registriert ^(!clinkExe!^).
) else (
    echo [WARN] clink nicht gefunden - autorun nicht gesetzt.
    echo        Bitte 'chrisant996.Clink' via winget installieren und neu starten.
)

echo.
echo Konfiguration abgeschlossen.
echo  - Aliases-Datei : %profileFolder%\aliases.cmd
echo  - Settings-Datei: %termSettings%
echo  - clink Scripts : %clinkDir%
exit /b 0

:backup_file
if not exist "%~1" exit /b 0
if not exist "%~dp2" (
    mkdir "%~dp2" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Backup-Ordner konnte nicht angelegt werden: %~dp2
        exit /b 1
    )
)
copy /y "%~1" "%~2" >nul
if errorlevel 1 (
    echo [ERROR] Backup fehlgeschlagen: %~1
    exit /b 1
)
exit /b 0
