@echo off
setlocal enabledelayedexpansion
title Dev-Maschine (lightweight) - Setup

cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0configure-credentials.ps1"
if errorlevel 1 goto :err

net session >nul 2>&1
if errorlevel 1 (
    echo [INFO] Keine Administrator-Rechte erkannt.
    echo [INFO] Starte Skript mit erhoehten Rechten neu...
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b 0
)

call :load_config
if "!DISTRIBUTION!"=="" set "DISTRIBUTION=Ubuntu-24.04"

echo.
echo ============================================================
echo  Dev-Maschine (lightweight) - generischer Infra-Stack
echo  WSL-Distro     : !DISTRIBUTION!
echo  Namespace      : !NAMESPACE!
echo ============================================================
echo.

echo.
echo ------------------------------------------------------------
echo  [2/4] WSL2 einrichten
echo ------------------------------------------------------------
if not exist "%~dp0wsl\setup-admin.bat" ( echo [ERROR] wsl\setup-admin.bat fehlt. & goto :err )
call "%~dp0wsl\setup-admin.bat"
if errorlevel 1 ( echo [ERROR] wsl\setup-admin.bat fehlgeschlagen. & goto :err )

if not exist "%~dp0wsl\setup.bat" ( echo [ERROR] wsl\setup.bat fehlt. & goto :err )
call "%~dp0wsl\setup.bat"
if errorlevel 1 ( echo [ERROR] wsl\setup.bat fehlgeschlagen. & goto :err )

echo.
echo ------------------------------------------------------------
echo  [3/4] Minikube starten + Infra-Stack deployen
echo ------------------------------------------------------------

set "PKG_WSL=%~dp0"
if "!PKG_WSL:~-1!"=="\" set "PKG_WSL=!PKG_WSL:~0,-1!"
set "PKG_WSL=!PKG_WSL:\=/!"
set "PKG_WSL=!PKG_WSL:C:=/mnt/c!"
set "PKG_WSL=!PKG_WSL:c:=/mnt/c!"

wsl --distribution !DISTRIBUTION! bash -lc "command -v minikube >/dev/null 2>&1 && command -v kubectl >/dev/null 2>&1"
if errorlevel 1 (
    echo [WARN] minikube oder kubectl wurden in der WSL-Distribution nicht gefunden.
    echo [WARN] Bitte in WSL installieren ^(z.B. via Minikube-Installer^) und dann erneut:
    echo [WARN]   wsl -d !DISTRIBUTION! bash -lc "bash '!PKG_WSL!/k8s/deploy-stack.sh' '!PKG_WSL!'"
    echo [WARN] Schritt 3 wird uebersprungen.
    goto :summary
)

echo [INFO] Deploye Infra-Stack in WSL...
wsl --distribution !DISTRIBUTION! bash -lc "chmod +x '!PKG_WSL!/k8s/deploy-stack.sh'; bash '!PKG_WSL!/k8s/deploy-stack.sh' '!PKG_WSL!'"
if errorlevel 1 ( echo [WARN] Deploy-Stack mit Fehlern beendet - bitte Ausgabe pruefen. )

:summary
echo.
echo ------------------------------------------------------------
echo  [4/4] Service-URLs (lokaler Dev-Stack)
echo ------------------------------------------------------------
echo.
echo   Hostname-Zugriff (benoetigt /etc/hosts -^> minikube ip + Gateway Port-Forward):
echo     http://rabbitmq.local       RabbitMQ Management  (Zugangsdaten im Kubernetes-Secret)
echo     http://mongodb.local        Mongo Express UI
echo     http://mongo-express.local  Mongo Express UI
echo     http://grafana.local        Grafana              (Zugangsdaten im Kubernetes-Secret)
echo     http://prometheus.local     Prometheus
echo     http://loki.local           Loki
echo     http://alertmanager.local   Alertmanager
echo.
echo   Direktzugriff via Port-Forward (Beispiele):
echo     kubectl port-forward svc/mongodb-service  !MONGODB_PORT!:27017  -n !NAMESPACE!
echo     kubectl port-forward svc/rabbitmq-service !RABBITMQ_AMQP_PORT!:5672   -n !NAMESPACE!
echo     kubectl port-forward svc/grafana-service  !GRAFANA_PORT!:3000   -n monitoring
echo.
echo ============================================================
echo  Setup abgeschlossen.
echo ============================================================
echo.
pause
exit /b 0

:load_config
    set "config_file=%~dp0config.ini"
    if not exist "!config_file!" exit /b 1
    for %%K in (DISTRIBUTION NAMESPACE MONGODB_PORT RABBITMQ_AMQP_PORT GRAFANA_PORT) do (
        for /f "tokens=1,* delims==" %%A in ('findstr /b /l "%%K=" "!config_file!"') do set "%%A=%%B"
    )
    exit /b 0

:err
echo.
echo [ERROR] Ein Schritt ist fehlgeschlagen. Setup abgebrochen.
pause
exit /b 1
