@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "ROOT=%~dp0.."
set "SHARED=%ROOT%\shared"

call "%ROOT%\windows-11-setup-base\setup-base.bat" || exit /b 1

set /p "do_company_dev=Company-Dev-Tools und Snippets installieren? [J/n]: "
if "!do_company_dev!"=="" set "do_company_dev=j"
if /i "!do_company_dev!"=="j" call "%SHARED%\scripts\install-packages.bat" winget "%SHARED%\packages\company-dev.winget.txt" || exit /b 1
if /i "!do_company_dev!"=="j" if exist "%~dp0snippets\install-snippets.bat" call "%~dp0snippets\install-snippets.bat" || exit /b 1

set /p "do_ai=AI-Workflow installieren? Firmenfreigabe/Datenschutz vorher pruefen. [j/N]: "
if /i "!do_ai!"=="j" call "%SHARED%\scripts\install-packages.bat" winget "%SHARED%\packages\ai-workflow.winget.txt" || exit /b 1
if /i "!do_ai!"=="j" if exist "%ROOT%\modules\ai-workflow\setup-ai-workflow.bat" call "%ROOT%\modules\ai-workflow\setup-ai-workflow.bat" || exit /b 1

echo [OK] Company-Setup abgeschlossen.
exit /b 0
