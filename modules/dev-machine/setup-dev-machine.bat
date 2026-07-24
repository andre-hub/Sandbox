@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "ROOT=%~dp0..\.."
set "SHARED=%ROOT%\shared"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0configure-credentials.ps1" || exit /b 1
call "%SHARED%\scripts\install-packages.bat" winget "%SHARED%\packages\dev-machine.winget.txt" || exit /b 1
set /p "do_wsl=WSL2 einrichten? [j/N]: "
if /i "!do_wsl!"=="j" (
    if exist "%~dp0wsl\setup-admin.bat" call "%~dp0wsl\setup-admin.bat" || exit /b 1
    if exist "%~dp0wsl\setup.bat" call "%~dp0wsl\setup.bat" || exit /b 1
)
echo [OK] Dev-Maschine abgeschlossen.
exit /b 0
