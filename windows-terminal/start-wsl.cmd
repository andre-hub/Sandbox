@echo off
REM ============================================================
REM  start-wsl.cmd - oeffnet eine WSL-Session und haelt Tab offen
REM
REM  Wird vom Terminal-Profil "WSL Start" geladen.
REM  Default-Distribution wird genutzt; Override via WSL_DISTRO env.
REM ============================================================

call "%USERPROFILE%\Documents\windows-terminal\aliases.cmd"

title WSL

where wsl >nul 2>&1
if errorlevel 1 (
    echo [WARN] wsl.exe nicht gefunden. WSL 2 ist nicht installiert.
    echo Erst-Setup: sandbox\modules\dev-machine\wsl\setup-admin.bat (Admin) und sandbox\modules\dev-machine\wsl\setup.bat
    goto :shell
)

if not "%WSL_DISTRO%"=="" (
    echo Starte WSL-Distribution: %WSL_DISTRO%
    wsl -d "%WSL_DISTRO%"
) else (
    echo Starte Default-WSL-Distribution ...
    wsl
)

echo.
echo === WSL beendet - cmd-Session bleibt offen ===
echo Erneut starten: wsl  (oder mit Distro: wsl -d ^<name^>)
echo Liste:          wsl --list --verbose
echo.

doskey wslup=wsl
doskey wsllist=wsl --list --verbose
doskey wslstop=wsl --shutdown
doskey wslsetup=call "%USERPROFILE%\Documents\windows-terminal\wsl-setup.cmd" $*

:shell
