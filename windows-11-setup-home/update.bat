@echo off
setlocal EnableExtensions
call "%~dp0..\shared\scripts\update.bat"
exit /b %errorlevel%
