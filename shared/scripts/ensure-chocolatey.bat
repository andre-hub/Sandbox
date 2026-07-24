@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Remote-Installer nur nach --install und interaktiver Bestaetigung ausfuehren.
set "chocoRoot="
if defined ChocolateyInstall if exist "%ChocolateyInstall%\bin\choco.exe" set "chocoRoot=%ChocolateyInstall%"
if not defined chocoRoot if exist "%ALLUSERSPROFILE%\chocolatey\bin\choco.exe" set "chocoRoot=%ALLUSERSPROFILE%\chocolatey"

if defined chocoRoot (
    echo [OK] Chocolatey vorhanden: !chocoRoot!\bin\choco.exe
    where choco >nul 2>&1
    if errorlevel 1 set "PATH=!PATH!;!chocoRoot!\bin"
    exit /b 0
)

where choco >nul 2>&1
if not errorlevel 1 (
    echo [OK] Chocolatey im PATH vorhanden.
    exit /b 0
)

if /I not "%~1"=="--install" (
    echo [INFO] Chocolatey nicht vorhanden; Fallback wird ohne Opt-in uebersprungen.
    exit /b 1
)

echo [WARN] Chocolatey wird von community.chocolatey.org geladen und ausgefuehrt.
set /p "confirm=Remote-Installer jetzt herunterladen und ausfuehren? [j/N]: "
if /I not "!confirm!"=="j" if /I not "!confirm!"=="ja" (
    echo [INFO] Chocolatey-Installation nicht bestaetigt; Fallback wird uebersprungen.
    exit /b 1
)
echo [INFO] Remote-Installer wurde interaktiv bestaetigt.

set "brokenRoot="
if defined ChocolateyInstall if exist "%ChocolateyInstall%" set "brokenRoot=%ChocolateyInstall%"
if not defined brokenRoot if exist "%ALLUSERSPROFILE%\chocolatey" set "brokenRoot=%ALLUSERSPROFILE%\chocolatey"
if defined brokenRoot (
    echo [WARN] Unvollstaendige Chocolatey-Installation gefunden: !brokenRoot!
    for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd-HHmmss')"`) do set "brokenTs=%%T"
    if not defined brokenTs (
        echo [ERROR] Zeitstempel fuer sichere Reparatur konnte nicht erzeugt werden.
        exit /b 1
    )
    ren "!brokenRoot!" "chocolatey.broken-!brokenTs!" >nul 2>&1
    if exist "!brokenRoot!" (
        echo [ERROR] Reparatur fehlgeschlagen - Ordner konnte nicht verschoben werden.
        exit /b 1
    )
    echo [OK] Unvollstaendigen Ordner gesichert.
)

echo [START] Chocolatey wird nach bestaetigtem Opt-in installiert ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

if defined ChocolateyInstall if exist "!ChocolateyInstall!\bin\choco.exe" (
    echo [OK] Chocolatey installiert.
    exit /b 0
)
if exist "!ALLUSERSPROFILE!\chocolatey\bin\choco.exe" (
    echo [OK] Chocolatey installiert.
    exit /b 0
)
echo [ERROR] Chocolatey-Installation fehlgeschlagen.
exit /b 1
