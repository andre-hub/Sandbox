@echo off
setlocal EnableExtensions
set "ROOT=%~dp0.."
set "SHARED=%ROOT%\shared"
call "%SHARED%\scripts\install-packages.bat" winget "%SHARED%\packages\base.winget.txt" || exit /b 1
call "%SHARED%\scripts\install-packages.bat" winget "%SHARED%\packages\office-common.winget.txt" || exit /b 1

REM Chocolatey ist nur ein optionaler Fallback fuer Pakete ohne winget-Manifest.
REM Besonders in Company-Setups kann dieser Pfad ohne Nebenwirkung uebersprungen werden.
set "do_choco="
set /p "do_choco=Chocolatey-Fallback-Pakete installieren? [j/N]: "
if /I "%do_choco%"=="j" goto :chocolatey_fallback
if /I "%do_choco%"=="ja" goto :chocolatey_fallback
echo [INFO] Chocolatey-Fallback-Pakete uebersprungen.
goto :after_chocolatey

:chocolatey_fallback
call "%SHARED%\scripts\ensure-chocolatey.bat" --install
if errorlevel 1 (
    echo [WARN] Chocolatey nicht verfuegbar oder nicht bestaetigt - Fallback-Pakete werden uebersprungen.
) else (
    call "%SHARED%\scripts\install-packages.bat" choco "%SHARED%\packages\chocolatey-fallback.choco.txt"
    if errorlevel 1 echo [WARN] Chocolatey-Fallback-Pakete konnten nicht vollstaendig installiert werden - fahre fort.
)

:after_chocolatey

call "%SHARED%\scripts\install-browsers.bat" || exit /b 1

if exist "%ROOT%\windows-terminal\install-terminal-config.bat" call "%ROOT%\windows-terminal\install-terminal-config.bat" || exit /b 1

echo [OK] Windows-11-Basis abgeschlossen.
exit /b 0
