@echo off
SET localCachePath=d:\Installer\chocolatey

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::REM choco source add -n=MyServer -s"http://servername:8000/api/odata"

:: default applications
choco install -y --cache-location=%localCachePath% chocolateygui 7zip aria2 Firefox Thunderbird f.lux keepass libreoffice vlc adobereader teamviewer

:: extended applications
choco install -y --cache-location=%localCachePath% meld pandoc visualstudiocode gajim ditto skype mumble teamspeak gimp virtualbox jre8 

:: Games
choco install -y battle.net steam uplay

:: WLAN Controler
#choco install -y ubiquiti-unifi-controller

@echo ==================================================================
@echo .
@echo     change the cache-location in the file 
@echo     %%ProgramData%%\chocolatey\config\chocolatey.config
@echo     to %localCachePath%
@echo ==================================================================