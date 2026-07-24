@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "ROOT=%~dp0.."
set "SHARED=%ROOT%\shared"

call "%ROOT%\windows-11-setup-base\setup-base.bat" || exit /b 1

set /p "do_ai=AI-Workflow installieren? [j/N]: "
if /i "!do_ai!"=="j" call "%SHARED%\scripts\install-packages.bat" winget "%SHARED%\packages\ai-workflow.winget.txt" || exit /b 1
if /i "!do_ai!"=="j" if exist "%ROOT%\modules\ai-workflow\setup-ai-workflow.bat" call "%ROOT%\modules\ai-workflow\setup-ai-workflow.bat" || exit /b 1

set /p "do_gaming=Gaming installieren? [j/N]: "
if /i "!do_gaming!"=="j" call "%SHARED%\scripts\install-packages.bat" winget "%SHARED%\packages\gaming.winget.txt" || exit /b 1
if /i "!do_gaming!"=="j" (
    set /p "do_nvidia=NVIDIA-Treiber ueber Chocolatey pruefen/installieren? [j/N]: "
    if /i "!do_nvidia!"=="j" call "%SHARED%\scripts\ensure-chocolatey.bat" --install || exit /b 1
    if /i "!do_nvidia!"=="j" call "%SHARED%\scripts\install-packages.bat" choco "%SHARED%\packages\gaming-nvidia.choco.txt" || exit /b 1
)

set /p "do_dev=Dev-Maschine einrichten? [j/N]: "
if /i "!do_dev!"=="j" call "%ROOT%\modules\dev-machine\setup-dev-machine.bat" || exit /b 1

echo [OK] Home-Setup abgeschlossen.
exit /b 0
