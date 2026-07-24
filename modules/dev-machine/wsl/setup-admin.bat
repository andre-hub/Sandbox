@echo off
setlocal enabledelayedexpansion
title WSL Admin Setup

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs -Wait"
    exit /b %errorlevel%
)

cd /d "%~dp0"

echo.
echo ============================================================
echo  WSL Admin Setup
echo ============================================================
echo.

set "restart_needed=0"

dism.exe /online /get-featureinfo /featurename:Microsoft-Windows-Subsystem-Linux 2>nul | find "State : Enabled" >nul 2>&1
if %errorlevel% neq 0 (
    echo Enabling Windows-Subsystem-for-Linux ...
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart >nul 2>&1
    if %errorlevel% equ 0 ( set "restart_needed=1" ) else ( echo [ERROR] enable failed & pause & exit /b 1 )
) else (
    echo [OK] Windows-Subsystem-for-Linux already enabled
)

dism.exe /online /get-featureinfo /featurename:VirtualMachinePlatform 2>nul | find "State : Enabled" >nul 2>&1
if %errorlevel% neq 0 (
    echo Enabling VirtualMachinePlatform ...
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart >nul 2>&1
    if %errorlevel% equ 0 ( set "restart_needed=1" ) else ( echo [ERROR] enable failed & pause & exit /b 1 )
) else (
    echo [OK] VirtualMachinePlatform already enabled
)

if "!restart_needed!"=="1" (
    echo.
    echo [REBOOT REQUIRED]
    echo Please reboot Windows and then run setup.bat.
    echo.
    pause & exit /b 0
)

wsl --update >nul 2>&1
wsl --set-default-version 2 >nul 2>&1
echo [OK] WSL kernel updated and default version set to 2

set "WSLCFG=%USERPROFILE%\.wslconfig"
if not exist "%WSLCFG%" (
    if exist "%~dp0.wslconfig.example" (
        copy /y "%~dp0.wslconfig.example" "%WSLCFG%" >nul
        echo [OK] %WSLCFG% created from .wslconfig.example
    )
) else (
    echo [OK] %WSLCFG% already exists
)

echo.
echo [OK] Admin setup complete. Run setup.bat next.
echo.
pause
exit /b 0
