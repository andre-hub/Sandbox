@echo off
setlocal EnableExtensions EnableDelayedExpansion

if "%~2"=="" (
    echo Usage: %~nx0 ^<winget^|choco^> ^<package-list^>
    exit /b 2
)

set "MANAGER=%~1"
set "LIST=%~2"
set "LOGDIR=%~dp0..\logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1
set "LOG=%LOGDIR%\install.log"
if not defined CHOCO_CACHE set "CHOCO_CACHE=c:\Installer\chocolatey"

if not exist "%LIST%" (
    echo [ERROR] Paketliste nicht gefunden: %LIST%
    exit /b 1
)

call :log INFO "Installiere %LIST% via %MANAGER%"
for /f "usebackq tokens=* delims=" %%P in ("%LIST%") do (
    set "PKG=%%P"
    if not "!PKG!"=="" if not "!PKG:~0,1!"=="#" (
        call :install_one "!PKG!"
        if errorlevel 1 exit /b 1
    )
)
exit /b 0

:install_one
set "PKG=%~1"
if /i "%MANAGER%"=="winget" (
    winget list --id "%PKG%" --exact --accept-source-agreements >nul 2>&1
    if not errorlevel 1 (
        call :log SKIP "%PKG% bereits installiert"
        exit /b 0
    )
    call :log START "winget %PKG%"
    winget install --silent --disable-interactivity --accept-package-agreements --accept-source-agreements --id "%PKG%" --exact
    if errorlevel 1 ( call :log ERROR "winget %PKG%" & exit /b 1 )
    call :log OK "winget %PKG%"
    exit /b 0
)
if /i "%MANAGER%"=="choco" (
    where choco >nul 2>&1
    if errorlevel 1 if exist "%ALLUSERSPROFILE%\chocolatey\bin\choco.exe" set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;%PATH%"
    where choco >nul 2>&1
    if errorlevel 1 ( call :log ERROR "Chocolatey nicht installiert" & exit /b 1 )
    call :log START "choco %PKG%"
    choco install -y --cache-location="%CHOCO_CACHE%" "%PKG%"
    if errorlevel 1 ( call :log ERROR "choco %PKG%" & exit /b 1 )
    call :log OK "choco %PKG%"
    exit /b 0
)
call :log ERROR "Unbekannter Paketmanager: %MANAGER%"
exit /b 2

:log
set "LEVEL=%~1"
set "MSG=%~2"
echo [%date% %time%] [%LEVEL%] %MSG%
echo [%date% %time%] [%LEVEL%] %MSG%>>"%LOG%"
exit /b 0
