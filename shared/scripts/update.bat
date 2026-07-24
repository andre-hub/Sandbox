@echo off
setlocal EnableExtensions
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
exit /b %errorlevel%
