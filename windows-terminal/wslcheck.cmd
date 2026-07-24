@echo off
REM ============================================================
REM  wslcheck.cmd — WSL, Minikube, Dashboard Statusanzeige
REM ============================================================

for /f "usebackq tokens=1,2,3 delims=~" %%A in (`powershell -NoProfile -Command "$w=if(Get-Process wslhost -EA SilentlyContinue){'running'}else{'stopped'};$mk=try{$s=(wsl -- bash -lc 'minikube status --format={{.Host}}' 2>$null).Trim();if($s -eq 'Running'){'running'}else{'stopped'}}catch{'stopped'};$tc=New-Object Net.Sockets.TcpClient;$ok=$tc.BeginConnect('dashboard.local',80,$null,$null).AsyncWaitHandle.WaitOne(800);$tc.Close();$db=if($ok){'running'}else{'stopped'};$w+'~'+$mk+'~'+$db"`) do (set "_WSL=%%A"&set "_MK=%%B"&set "_DB=%%C")

echo.
echo   WSL      :  %_WSL%
echo   Minikube :  %_MK%
echo   Dashboard:  %_DB%  http://dashboard.local/
echo.
set "_WSL=" & set "_MK=" & set "_DB="
