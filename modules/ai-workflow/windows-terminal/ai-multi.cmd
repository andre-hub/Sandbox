@echo off
setlocal DisableDelayedExpansion

REM Jeder Prompt liegt in einer Datei. Dadurch gibt es weder CALL-Re-Expansion noch
REM eine unsichere Verkettung von Prompt-Text in Batch-Variablen.

if /I not "%~1"=="copilot" (
    echo [ERROR] Usage: ai-multi.cmd copilot prompt-file-1 [prompt-file-2 ...]
    exit /b 1
)
shift
if "%~1"=="" (
    echo [ERROR] Mindestens eine Prompt-Datei angeben.
    exit /b 1
)

where pwsh >nul 2>&1
if not errorlevel 1 (set "POWERSHELL_EXE=pwsh") else (set "POWERSHELL_EXE=powershell")
where %POWERSHELL_EXE% >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PowerShell nicht im PATH gefunden.
    exit /b 1
)

:spawn
if "%~1"=="" exit /b 0
%POWERSHELL_EXE% -NoProfile -ExecutionPolicy Bypass -File "%~dp0ai-spawn-direct.ps1" -Tool copilot -PromptFile "%~1"
if errorlevel 1 exit /b %errorlevel%
shift
goto :spawn
