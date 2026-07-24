@echo off
REM ============================================================
REM  wsl-setup.cmd - laedt modules\dev-machine\wsl\setup.bat auf
REM
REM  Sucht das sandbox-Repo an gaengigen Orten:
REM    1) %SANDBOX_HOME% (Env)
REM    2) C:\projects\sandbox.git
REM    3) C:\projects\sandbox
REM    4) %USERPROFILE%\workspace\sandbox.git
REM    5) %USERPROFILE%\workspace\sandbox
REM    6) C:\workspace\sandbox.git
REM ============================================================

setlocal

if defined SANDBOX_HOME (
    if exist "%SANDBOX_HOME%\modules\dev-machine\wsl\setup.bat" (
        call "%SANDBOX_HOME%\modules\dev-machine\wsl\setup.bat" %*
        exit /b %errorlevel%
    )
)

for %%P in (
    "C:\projects\sandbox.git"
    "C:\projects\sandbox"
    "%USERPROFILE%\workspace\sandbox.git"
    "%USERPROFILE%\workspace\sandbox"
    "C:\workspace\sandbox.git"
    "C:\workspace\sandbox"
) do (
    if exist "%%~P\modules\dev-machine\wsl\setup.bat" (
        echo Verwende sandbox unter %%~P
        call "%%~P\modules\dev-machine\wsl\setup.bat" %*
        exit /b %errorlevel%
    )
)

echo [ERROR] modules\dev-machine\wsl\setup.bat nicht gefunden.
echo Setze SANDBOX_HOME oder klone das Repo nach %USERPROFILE%\workspace\sandbox.git
exit /b 1
