@echo off
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
::REM choco source add -n=MyServer -s"http://servername:8000/api/odata"
choco install -y chocolateygui 7zip chromium dotnetcore git gitextensions libreoffice LINQPad5 pandoc skype visualstudiocode vscode-csharp vscode-csharpextensions vscode-icons