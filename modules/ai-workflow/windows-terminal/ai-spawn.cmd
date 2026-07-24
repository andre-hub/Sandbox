@echo off
setlocal DisableDelayedExpansion

REM Prompt-Inhalte werden nie in CMD-Variablen zusammengesetzt oder mit CALL erneut
REM expandiert. Fuer direkte Texte ai-spawn-direct.ps1 aus PowerShell verwenden.

set "tool=%~1"
if "%tool%"=="" (
    if defined AI_DEFAULT_TOOL (set "tool=%AI_DEFAULT_TOOL%") else (set "tool=copilot")
)
if /I not "%tool%"=="copilot" (
    echo [ERROR] Einziges unterstuetztes Tool: copilot.
    exit /b 1
)

set "promptFile=%~2"
if not "%~3"=="" (
    echo [ERROR] Usage: ai-spawn.cmd [copilot] [prompt-file]
    exit /b 1
)

where pwsh >nul 2>&1
if not errorlevel 1 (set "POWERSHELL_EXE=pwsh") else (set "POWERSHELL_EXE=powershell")
where %POWERSHELL_EXE% >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PowerShell nicht im PATH gefunden.
    exit /b 1
)

if defined promptFile (
    %POWERSHELL_EXE% -NoProfile -ExecutionPolicy Bypass -File "%~dp0ai-spawn-direct.ps1" -Tool copilot -PromptFile "%promptFile%"
) else (
    %POWERSHELL_EXE% -NoProfile -ExecutionPolicy Bypass -File "%~dp0ai-spawn-direct.ps1" -Tool copilot
)
exit /b %errorlevel%
