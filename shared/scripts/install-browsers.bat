@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "SCRIPT_DIR=%~dp0"

echo Browser-Auswahl (Mehrfachauswahl, kommagetrennt)
echo   [1] Mozilla Firefox (Default)
echo   [2] Helium Browser
echo   [3] Google Chrome
set /p "choices=Auswahl [1]: "
if "%choices%"=="" set "choices=1"
set "choices=%choices:,= %"

for %%C in (%choices%) do (
    if "%%C"=="1" call :install_browser "browser-firefox.winget.txt"
    if "%%C"=="2" call :install_browser "browser-helium.winget.txt"
    if "%%C"=="3" call :install_browser "browser-chrome.winget.txt"
    if not "%%C"=="1" if not "%%C"=="2" if not "%%C"=="3" echo [WARN] Unbekannte Browser-Auswahl: %%C
    if errorlevel 1 exit /b 1
)
exit /b 0

:install_browser
call "%SCRIPT_DIR%install-packages.bat" winget "%SCRIPT_DIR%..\packages\%~1"
exit /b %errorlevel%
