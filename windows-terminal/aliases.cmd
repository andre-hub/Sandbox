@echo off
REM  Datenschutz: nutzt %USERPROFILE%, kein fester Benutzername.

set "profileFolder=%USERPROFILE%\Documents\windows-terminal"

echo.
echo   Rechner  :  %COMPUTERNAME%

wsl -- true >nul 2>&1
if errorlevel 1 goto :banner_no_wsl

for /f "usebackq" %%A in (`powershell -NoProfile -Command "try{$t=New-Object Net.Sockets.TcpClient;$ok=$t.BeginConnect('dashboard.local',80,$null,$null).AsyncWaitHandle.WaitOne(800);$t.Close();if($ok){'running'}else{'stopped'}}catch{'stopped'}"`) do set "_OV_DB=%%A"
echo   Dashboard:  %_OV_DB%  http://dashboard.local/
echo.
echo   type 'aliases' for commands  ^|  'wslcheck' for WSL/Minikube status
set "_OV_DB="
goto :banner_done

:banner_no_wsl
echo.
echo   type 'aliases' for commands

:banner_done
echo.

where code >nul 2>&1 && (set "ALIAS_EDITOR=code" & goto :alias_editor_done)
where zed  >nul 2>&1 && (set "ALIAS_EDITOR=zed"  & goto :alias_editor_done)
where subl >nul 2>&1 && (set "ALIAS_EDITOR=subl" & goto :alias_editor_done)
set "ALIAS_EDITOR=notepad"
:alias_editor_done

doskey aliases=echo ls, ll, .., ..., ...., ht, chocoUp, wingetUp, allUp, editcfg, editalias, ins, insw, chocoHelp, mkstart, wslcheck, wslup, wslsetup, gitex, clearsession, gfa, gpa, gbd, hist (Ctrl+R), ff (Ctrl+T), cc/cdx/vb (direkt)
doskey cmdhelp=echo type aliases
doskey commands=echo type aliases

doskey ls=dir /B
doskey ll=dir
doskey la=dir /A
doskey ..=cd ..
doskey ...=cd ..\..
doskey ....=cd ..\..\..
doskey .....=cd ..\..\..\..
doskey ~=cd /d %USERPROFILE%
doskey home=cd /d %USERPROFILE%
doskey cls=cls
doskey clear=cls
doskey grep=findstr $*
doskey which=where $*
doskey cat=type $*
doskey touch=type nul ^> $*
doskey rmf=del /f /q $*
doskey rmrf=rmdir /s /q $*
doskey mkdirp=mkdir $*

doskey ht=taskmgr
doskey procexp=procexp64
doskey services=services.msc
doskey eventvwr=eventvwr.msc
doskey regedit=regedit
doskey explore=explorer .
doskey x=exit

doskey wslcheck=call "%profileFolder%\wslcheck.cmd"

doskey hist=doskey /history ^| fzf --tac --no-sort ^| clip
doskey ff=dir /b /s . 2^>nul ^| fzf
doskey mkstop=minikube stop
doskey mkstatus=minikube status
doskey mkdash=minikube dashboard
doskey k=kubectl $*

doskey wslup=wsl
doskey wsllist=wsl --list --verbose
doskey wslstop=wsl --shutdown
doskey wslsetup=call "%USERPROFILE%\Documents\windows-terminal\wsl-setup.cmd" $*

where claude >nul 2>&1 && doskey cc=claude $*
where codex  >nul 2>&1 && doskey cdx=codex $*
where vibe   >nul 2>&1 && doskey vb=vibe $*

where code  >nul 2>&1 && doskey edit=code $*    && goto :editor_set
where zed   >nul 2>&1 && doskey edit=zed $*     && goto :editor_set
where subl  >nul 2>&1 && doskey edit=subl $*    && goto :editor_set
doskey edit=notepad $*
:editor_set

doskey chocoUp=choco upgrade all -y
doskey wingetUp=winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
doskey allUp=chocoUp $T wingetUp

doskey ins=choco install -y $*
doskey insw=winget install --silent --accept-package-agreements --accept-source-agreements --id $*

doskey chocoHelp=echo chocoUp, ins ^<paket^>, insw ^<id^>

doskey gitex=call "%profileFolder%\gitex.cmd" $*
doskey clearsession=call "%profileFolder%\clearsession.cmd"
doskey gfa=call "%profileFolder%\git-fetch-all.cmd"
doskey gpa=call "%profileFolder%\git-pull-main.cmd"
doskey gbd=call "%profileFolder%\git-branch-diff.cmd"

doskey editcfg=%ALIAS_EDITOR% "%profileFolder%\settings.json"
doskey editalias=%ALIAS_EDITOR% "%profileFolder%\aliases.cmd"
doskey goprofile=explorer "%profileFolder%"

if exist "%profileFolder%\ai-aliases.cmd" call "%profileFolder%\ai-aliases.cmd"
