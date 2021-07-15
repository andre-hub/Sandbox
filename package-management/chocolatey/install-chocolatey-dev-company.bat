@echo off
SET localCachePath="C:\ZA AG\chocolatey"

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::REM choco source add -n=MyServer -s"http://servername:8000/api/odata"

:: default applications
choco install -y --cache-location=%localCachePath% chocolatey-autoupdater chocolateygui 7zip microsoft-windows-terminal aria2 Firefox keepassxc teamviewer bleachbit windirstat vscode ditto virtualbox sysinternals mRemoteNG

:: office applications
choco install -y --cache-location=%localCachePath% libreoffice capture2text greenshot choco install microsoft-teams yed

:: Default IT applications
choco install -y --cache-location=%localCachePath% SourceCodePro git fzf gitg meld pandoc vscode-csharp vscode-csharpextensions vscode-icons pencil

:: Default development applications
choco install -y --cache-location=%localCachePath% dotnetcore dotnetcore-sdk wixtoolset visualstudio2019professional visualstudio2019-workload-netweb visualstudio2019-workload-manageddesktop LINQPad5

:: database applications
choco install -y --cache-location=%localCachePath% mysql.workbench  sql-server-express sql-server-management-studio

@echo ==================================================================
@echo .
@echo     change the cache-location in the file 
@echo     %%ProgramData%%\chocolatey\config\chocolatey.config
@echo     to %localCachePath%
@echo ==================================================================

@echo outlook: http://www.xequte.com/download/textlightningsetup.exe