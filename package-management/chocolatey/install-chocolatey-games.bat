@echo off
SET localCachePath=d:\Installer\chocolatey

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::REM choco source add -n=MyServer -s"http://servername:8000/api/odata"

:: default applications
choco install -y --cache-location=%localCachePath% chocolatey-autoupdater chocolateygui 7zip Firefox keepassxc bleachbit windirstat vscode ditto sysinternals

:: driver
choco install -y --cache-location=%localCachePath% nvidia-display-driver 

:: communication
choco install -y --cache-location=%localCachePath% gajim mumble teamspeak nextcloud-client

:: Game Launcher
choco install -y --cache-location=%localCachePath% battle.net origin steam epicgameslauncher uplay goggalaxy

:: for minecraft
choco install -y --cache-location=%localCachePath% jre8

@echo ==================================================================
@echo .
@echo     change the cache-location in the file 
@echo     %%ProgramData%%\chocolatey\config\chocolatey.config
@echo     to %localCachePath%
@echo ==================================================================