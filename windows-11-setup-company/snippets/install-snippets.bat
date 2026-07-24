@echo off
setlocal
title Snippets - Visual Studio 2026 + SSMS

REM  Datenschutz: ausschliesslich %USERPROFILE%, kein fester Username.

set "src=%~dp0"
set "vsTarget=%USERPROFILE%\Documents\Visual Studio 2026\Code Snippets\Visual C#\My Code Snippets"
set "ssmsTarget=%USERPROFILE%\Documents\SQL Server Management Studio\Code Snippets\SQL\My Code Snippets"

echo.
echo === Visual Studio 2026 Snippets ===
if not exist "%vsTarget%" (
    mkdir "%vsTarget%" >nul 2>&1
    echo [OK] Ordner angelegt: %vsTarget%
)
copy /y "%src%visualstudio-2026\*.snippet" "%vsTarget%\" >nul
if %errorlevel% neq 0 (
    echo [ERROR] VS-2026-Snippets konnten nicht kopiert werden.
    exit /b 1
)
echo [OK] VS-2026-Snippets installiert.

echo.
echo === SSMS Snippets ===
if not exist "%ssmsTarget%" (
    mkdir "%ssmsTarget%" >nul 2>&1
    echo [OK] Ordner angelegt: %ssmsTarget%
)
copy /y "%src%ssms\*.snippet" "%ssmsTarget%\" >nul
if %errorlevel% neq 0 (
    echo [ERROR] SSMS-Snippets konnten nicht kopiert werden.
    exit /b 1
)
echo [OK] SSMS-Snippets installiert.

echo.
echo Snippets installiert.
echo Hinweis Visual Studio 2026: Tools - Code Snippets Manager - Importieren falls noetig.
exit /b 0
