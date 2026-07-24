@echo off
REM ============================================================
REM  git-fetch-all.cmd
REM  Fuehrt in allen Git-Repos unter C:\projects\ ein
REM  "git fetch --prune" aus.
REM ============================================================

set "ROOT=C:\projects"
set "ERRORS=0"
set "COUNT=0"

echo.
echo   git fetch --prune -- alle Repos in %ROOT%
echo   =====================================================

for /d %%D in ("%ROOT%\*") do (
    if exist "%%D\.git" (
        set /a COUNT+=1
        echo.
        echo   [%%~nxD]
        git -C "%%D" fetch --prune
        if errorlevel 1 (
            echo   ^!^! Fehler in %%~nxD
            set /a ERRORS+=1
        )
    )
)

echo.
echo   =====================================================
echo   Fertig. %COUNT% Repos verarbeitet, %ERRORS% Fehler.
echo.
