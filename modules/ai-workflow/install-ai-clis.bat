@echo off
setlocal EnableExtensions
title AI-CLIs (GitHub Copilot / Claude Code / OpenAI Codex)

where npm >nul 2>&1
if errorlevel 1 (
    echo [WARN] npm nicht im PATH - Node.js LTS zuerst installieren ^(sandbox-Basis^).
    exit /b 1
)

echo.
echo === Optionale AI-CLIs global per npm ===
call :install_cli "GitHub Copilot CLI" "@github/copilot" "copilot"
call :install_cli "Claude Code" "@anthropic-ai/claude-code" "claude"
call :install_cli "OpenAI Codex" "@openai/codex" "codex"
exit /b 0

:install_cli
set "answer="
set /p "answer=%~1 installieren oder aktualisieren? [j/N]: "
if /I not "%answer%"=="j" if /I not "%answer%"=="ja" (
    echo [INFO] %~1 uebersprungen.
    exit /b 0
)
call npm install -g %~2
if errorlevel 1 (
    echo [ERROR] %~1 konnte nicht installiert werden.
    exit /b 0
)
where %~3 >nul 2>&1
if errorlevel 1 (
    echo [WARN] %~1 installiert, aber %~3 ist noch nicht im PATH. Neues Terminal oeffnen.
) else (
    echo [OK] %~1 installiert und im PATH gefunden.
)
exit /b 0
