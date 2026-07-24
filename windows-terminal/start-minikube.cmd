@echo off
REM ============================================================
REM  start-minikube.cmd - startet Minikube und haelt Session offen
REM
REM  Wird vom Terminal-Profil "Minikube" geladen (cmd.exe /k).
REM  Laedt Aliases, prueft Cluster-Status, startet wenn noetig.
REM ============================================================

call "%USERPROFILE%\Documents\windows-terminal\aliases.cmd"

title Minikube

echo.
echo === Minikube ===
where minikube >nul 2>&1
if errorlevel 1 (
    echo [WARN] minikube nicht im PATH gefunden.
    echo Installiere via: winget install Kubernetes.minikube
    goto :shell
)

minikube status >nul 2>&1
if errorlevel 7 (
    echo Cluster ist nicht aktiv. Starte minikube ...
    minikube start
) else if errorlevel 1 (
    echo Cluster-Status unklar. Starte minikube ...
    minikube start
) else (
    echo [OK] Cluster laeuft.
    minikube status
)

REM Hilfreiche Aliases (zusaetzlich zu denen aus aliases.cmd)
doskey mkstart=minikube start
doskey mkstop=minikube stop
doskey mkstatus=minikube status
doskey mkdash=minikube dashboard
doskey mkssh=minikube ssh
doskey kctx=kubectl config use-context $*
doskey k=kubectl $*

echo.
echo Aliases: mkstart, mkstop, mkstatus, mkdash, mkssh, kctx, k
echo.

:shell
