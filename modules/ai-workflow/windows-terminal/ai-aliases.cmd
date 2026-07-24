@echo off

set "_aiwt=%USERPROFILE%\Documents\windows-terminal"

where pwsh >nul 2>&1 && ( set "_aips=pwsh" ) || ( set "_aips=powershell" )

doskey aispawn="%_aiwt%\ai-spawn.cmd" $*
doskey aimulti="%_aiwt%\ai-multi.cmd" $*

doskey aiworkers=%_aips% -NoProfile -ExecutionPolicy Bypass -File "%_aiwt%\ai-workers.ps1" $*
doskey aisend=%_aips% -NoProfile -ExecutionPolicy Bypass -File "%_aiwt%\ai-send.ps1" $*
doskey aiclose=%_aips% -NoProfile -ExecutionPolicy Bypass -File "%_aiwt%\ai-close.ps1" $*
doskey aidone=%_aips% -NoProfile -ExecutionPolicy Bypass -File "%_aiwt%\ai-worker-done.ps1" $*
doskey aihandoff=%_aips% -NoProfile -ExecutionPolicy Bypass -File "%_aiwt%\ai-coord-handoff.ps1" $*
doskey aiinbox=%_aips% -NoProfile -ExecutionPolicy Bypass -File "%_aiwt%\ai-inbox.ps1" $*

doskey aihelp=echo aispawn copilot ^<prompt-file^>  ^|  aimulti copilot ^<prompt-file-1^> ^<prompt-file-2^>  ^|  aiworkers [-Active^|-Full^|-Prune]  ^|  aisend ^<id^> "auftrag"  ^|  aiclose ^<id^>  ^|  aidone ^<id^> -Status done  ^|  aihandoff -PromptFile ^<status.md^>  ^|  aiinbox [-All^|-Clear]
