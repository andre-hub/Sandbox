@echo off
setlocal enabledelayedexpansion
title WSL Bootstrap

cd /d "%~dp0"

call :ensure_credentials
if errorlevel 1 ( echo [ERROR] Sichere zentrale Konfiguration ist nicht verfuegbar. & pause & exit /b 1 )

call :load_config
if %errorlevel% neq 0 ( echo [ERROR] config.ini not found. & pause & exit /b 1 )

set "WSL_USERNAME=!APP_USERNAME!"

set "WSLCFG=%USERPROFILE%\.wslconfig"
if not exist "!WSLCFG!" (
    ( echo [wsl2]
      echo networkingMode=!NETWORKING_MODE!
      echo memory=!WSL_MEMORY!
      echo processors=!WSL_PROCESSORS! ) > "!WSLCFG!"
    echo  [OK] .wslconfig created
)

echo.
echo  Distribution : !DISTRIBUTION!
echo.

call :print_step "1/3" "Reuse or install WSL distribution"
wsl --list --quiet 2>nul | findstr /x /i "!DISTRIBUTION!" >nul
if errorlevel 1 (
    wsl --install --distribution !DISTRIBUTION! --no-launch >nul 2>&1
    if errorlevel 1 ( echo [ERROR] WSL distribution installation failed. & exit /b 1 )
)
wsl --set-default !DISTRIBUTION! >nul 2>&1
set "wait_count=0"
:wait_wsl
    timeout /t 3 /nobreak >nul
    wsl --distribution !DISTRIBUTION! echo OK >nul 2>&1
    if %errorlevel% equ 0 goto :wsl_ready
    set /a wait_count+=1
    if !wait_count! lss 20 goto :wait_wsl
    echo  [ERROR] Timed out waiting for !DISTRIBUTION!
    pause & exit /b 1
:wsl_ready
echo  [OK] !DISTRIBUTION! is up

call :print_step "2/3" "Create user and enable systemd"
wsl --distribution !DISTRIBUTION! --user root getent passwd !WSL_USERNAME! >nul 2>&1
if %errorlevel% neq 0 (
    wsl --distribution !DISTRIBUTION! --user root useradd -m -s /bin/bash !WSL_USERNAME! >nul 2>&1
    wsl --distribution !DISTRIBUTION! --user root usermod -aG sudo !WSL_USERNAME! >nul 2>&1
    wsl --distribution !DISTRIBUTION! --user root bash -c "echo '!WSL_USERNAME! ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/!WSL_USERNAME!" >nul 2>&1
    echo  [OK] WSL user created
) else (
    echo  [OK] WSL user already exists
)
wsl --distribution !DISTRIBUTION! --user root bash -c "printf '[boot]\nsystemd=true\n\n[user]\ndefault=!WSL_USERNAME!\n' > /etc/wsl.conf" >nul 2>&1
echo  [OK] /etc/wsl.conf written (systemd=true)

powershell -NoProfile -Command "$root='%~dp0'; Get-ChildItem -Path $root -Recurse -Filter *.sh | ForEach-Object { $p=$_.FullName; $c=[System.IO.File]::ReadAllText($p); $c=$c -replace \"`r`n\",\"`n\"; [System.IO.File]::WriteAllText($p,$c,(New-Object System.Text.UTF8Encoding($false))) }"

wsl --terminate !DISTRIBUTION! >nul 2>&1
timeout /t 2 /nobreak >nul

call :print_step "3/3" "Run wsl-bootstrap.sh inside !DISTRIBUTION!"
set "WSL_SETUP_DIR=%~dp0"
set "WSL_SETUP_DIR=!WSL_SETUP_DIR:\=/!"
set "WSL_SETUP_DIR=!WSL_SETUP_DIR:C:=/mnt/c!"
set "WSL_SETUP_DIR=!WSL_SETUP_DIR:c:=/mnt/c!"
wsl --distribution !DISTRIBUTION! --user !WSL_USERNAME! bash -l -c "chmod +x '!WSL_SETUP_DIR!wsl-bootstrap.sh' '!WSL_SETUP_DIR!scripts/'*.sh && bash '!WSL_SETUP_DIR!wsl-bootstrap.sh' '!WSL_SETUP_DIR!'"
if %errorlevel% neq 0 ( echo. & echo [ERROR] wsl-bootstrap.sh failed. & pause & exit /b 1 )

echo.
echo ============================================================
echo  Bootstrap complete.
echo  Open a new shell with:  wsl -d !DISTRIBUTION!
echo ============================================================
echo.
pause
exit /b 0

:print_step
    echo.
    echo [%~1] %~2
    exit /b 0

:ensure_credentials
    set "credentials_script=%~dp0..\configure-credentials.ps1"
    set "credentials_config=%~dp0..\config.ini"
    if not exist "!credentials_script!" ( echo [ERROR] configure-credentials.ps1 not found. & exit /b 1 )
    if not exist "!credentials_config!" goto :configure_credentials
    powershell -NoProfile -ExecutionPolicy Bypass -File "!credentials_script!" -ValidateOnly
    if not errorlevel 1 exit /b 0
:configure_credentials
    powershell -NoProfile -ExecutionPolicy Bypass -File "!credentials_script!"
    if errorlevel 1 exit /b 1
    exit /b 0

:load_config
    set "config_file=%~dp0..\config.ini"
    if not exist "!config_file!" ( echo [ERROR] config.ini not found: !config_file! & exit /b 1 )
    for %%K in (DISTRIBUTION APP_USERNAME NETWORKING_MODE WSL_MEMORY WSL_PROCESSORS) do (
        for /f "tokens=1,* delims==" %%A in ('findstr /b /l "%%K=" "!config_file!"') do set "%%A=%%B"
    )
    exit /b 0
