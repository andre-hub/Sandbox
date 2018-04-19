@echo off
SET localCachePath=\\{SERVERNAME}\Installer\chocolatey

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::REM choco source add -n=MyServer -s"http://servername:8000/api/odata"

:: default applications
choco install -y --cache-location=%localCachePath% chocolateygui 7zip Firefox Thunderbird f.lux keepass libreoffice vlc

:: extended applications
choco install -y --cache-location=%localCachePath% meld pandoc visualstudiocode gajim ditto skype mumble gimp virtualbox

:: Default IT applications
choco install -y --cache-location=%localCachePath% SourceCodePro git git-lfs fzf gitg vscode-csharp vscode-csharpextensions vscode-icons mRemoteNG pencil

:: Default development applications
choco install -y --cache-location=%localCachePath% gittfs dotnetcore dotnetcore-sdk dotnet4.6.2 DotNet4.7 visualstudio2015community
:: sql-server-express sql-server-management-studio VisualStudio2017 or VisualStudio2015Professional

@echo ==================================================================
@echo .
@echo     change the cache-location in the file 
@echo     %%ProgramData%%\chocolatey\config\chocolatey.config
@echo     to %localCachePath%
@echo ==================================================================