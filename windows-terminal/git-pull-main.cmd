@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  git-pull-main.cmd
REM  Fuehrt in allen Git-Repos unter C:\projects\ ein
REM  "git pull" aus, aber NUR wenn der aktuelle Branch "main" ist.
REM ============================================================

set "ROOT=C:\projects"
set "ERRORS=0"
set "PULLED=0"
set "SKIPPED=0"
set "NONGIT=0"

echo.
echo   git pull -- alle Git-Repos in %ROOT% (nur main-Branch)
echo   =====================================================

for /d %%D in ("%ROOT%\*") do (
    if exist "%%D\.git" (
        set "_BRANCH="
        for /f "usebackq delims=" %%B in (`git -C "%%D" branch --show-current 2^>nul`) do set "_BRANCH=%%B"
        if "!_BRANCH!"=="main" (
            echo.
            echo   [%%~nxD]  ^(main^)
            git -C "%%D" pull
            if errorlevel 1 (
                echo   ^!^! Fehler in %%~nxD
                set /a ERRORS+=1
            ) else (
                set /a PULLED+=1
            )
        ) else (
            set /a SKIPPED+=1
            echo.
            echo   [%%~nxD]  -- uebersprungen ^(Branch: !_BRANCH!^)
        )
    ) else (
        set /a NONGIT+=1
    )
)

echo.
echo   =====================================================
echo   Gepullt: !PULLED!  ^|  Nicht-main uebersprungen: !SKIPPED!  ^|  Fehler: !ERRORS!
echo   (Nicht-Git-Ordner ignoriert: !NONGIT!)
echo.
