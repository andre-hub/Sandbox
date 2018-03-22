@echo off
SET localCachePath=\\{SERVERNAME}\Installer\chocolatey

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::REM choco source add -n=MyServer -s"http://servername:8000/api/odata"

:: Default applications
choco install -y --cache-location=%localCachePath% chocolateygui 7zip chromium f.lux keepass libreoffice skype

:: Default IT applications
choco install -y --cache-location=%localCachePath% SourceCodePro git git-lfs gitextensions meld kdiff3 LINQPad5 pandoc visualstudiocode vscode-csharp vscode-csharpextensions vscode-icons

:: Default development applications
choco install -y --cache-location=%localCachePath% gittfs dotnetcore DotNet4.5.2 DotNet4.6.1 sql-server-express sql-server-management-studio 
::  VisualStudio2017 or VisualStudio2015Professional

@echo ==================================================================
@echo .
@echo     change the cache-location in the file 
@echo     %%ProgramData%%\chocolatey\config\chocolatey.config
@echo     to %localCachePath%
@echo ==================================================================