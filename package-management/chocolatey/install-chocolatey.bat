@echo off
SET localCachePath=d:\Installer\chocolatey

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::REM choco source add -n=MyServer -s"http://servername:8000/api/odata"

:: default applications
choco install -y --cache-location=%localCachePath% chocolatey-autoupdater chocolateygui 7zip aria2 Firefox keepassxc teamviewer bleachbit windirstat vscode ditto virtualbox sysinternals mRemoteNG

:: communication
choco install -y --cache-location=%localCachePath% gajim skype mumble teamspeak 
:: claws-mail Thunderbird

:: office applications
choco install -y --cache-location=%localCachePath% gimp nextcloud-client libreoffice vlc adobereader capture2text
:: adobedigitaleditions

:: Default IT applications
choco install -y --cache-location=%localCachePath% SourceCodePro git fzf gitg meld pandoc vscode-csharp vscode-csharpextensions vscode-icons pencil

:: Default development applications
choco install -y --cache-location=%localCachePath% dotnetcore dotnetcore-sdk wixtoolset visualstudio2019community visualstudio2019-workload-netweb isualstudio2019-workload-manageddesktop

:: WLAN Controler
:: choco install -y ubiquiti-unifi-controller

@echo ==================================================================
@echo .
@echo     change the cache-location in the file 
@echo     %%ProgramData%%\chocolatey\config\chocolatey.config
@echo     to %localCachePath%
@echo ==================================================================