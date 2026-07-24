@echo off
setlocal enabledelayedexpansion
title Dev-Maschine (lightweight) - Update

cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0configure-credentials.ps1" -ValidateOnly
if errorlevel 1 ( echo [ERROR] Sichere lokale Konfiguration fehlt. & exit /b 1 )

echo.
echo ============================================================
echo  Dev-Maschine Update
echo ============================================================

set /p "do_wsl=WSL2-Kernel aktualisieren (wsl --update)? [J/n]: "
set /p "do_stack=Infra-Stack neu anwenden (kubectl apply -k)? [J/n]: "
if /i "!do_wsl!"==""   set "do_wsl=j"
if /i "!do_stack!"=="" set "do_stack=j"

if /i "!do_wsl!"=="j" (
    echo.
    echo === WSL2-Update ===
    wsl --update
)

if /i "!do_stack!"=="j" (
    echo.
    echo === Infra-Stack neu anwenden ===
    set "DISTRO=Ubuntu-24.04"
    for /f "tokens=2 delims==" %%D in ('findstr /b /i "DISTRIBUTION" "%~dp0config.ini" 2^>nul') do set "DISTRO=%%D"
    set "DISTRO=!DISTRO: =!"
    where wsl >nul 2>&1
    if errorlevel 1 (
        echo [WARN] wsl nicht gefunden - Update des Stacks uebersprungen.
    ) else (
        set "PKG_WSL=%~dp0"
        if "!PKG_WSL:~-1!"=="\" set "PKG_WSL=!PKG_WSL:~0,-1!"
        set "PKG_WSL=!PKG_WSL:\=/!"
        set "PKG_WSL=!PKG_WSL:C:=/mnt/c!"
        set "PKG_WSL=!PKG_WSL:c:=/mnt/c!"
        wsl -d !DISTRO! bash -lc "bash '!PKG_WSL!/k8s/deploy-stack.sh' '!PKG_WSL!'"
    )
)

echo.
echo Update abgeschlossen.
pause
exit /b 0
