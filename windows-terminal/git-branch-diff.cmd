@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  git-branch-diff.cmd
REM  Zeigt alle Git-Repos unter C:\projects\ die NICHT auf
REM  dem "main"-Branch sind.
REM ============================================================

set "ROOT=C:\projects"
set "DIFF=0"
set "TOTAL=0"

echo.
echo   Repos mit abweichendem Branch (nicht main)
echo   =====================================================

for /d %%D in ("%ROOT%\*") do (
    if exist "%%D\.git" (
        set /a TOTAL+=1
        for /f "usebackq delims=" %%B in (`git -C "%%D" branch --show-current 2^>nul`) do set "_BRANCH=%%B"
        if not "!_BRANCH!"=="main" (
            set /a DIFF+=1
            echo.
            echo   [%%~nxD]  Branch: !_BRANCH!
        )
    )
)

echo.
if %DIFF%==0 (
    echo   Alle Repos sind auf main.
) else (
    echo   %DIFF% von %TOTAL% Repos haben einen anderen Branch als main.
)
echo.
