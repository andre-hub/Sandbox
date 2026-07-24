#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Startet und registriert einen Copilot-Worker in Windows Terminal.
.PARAMETER Prompt
    Direkter Auftrag; alternativ PromptFile verwenden.
.PARAMETER PromptFile
    UTF-8-Datei mit dem Auftrag; Recherche-Rohdaten sind gesperrt.
.PARAMETER Headless
    Startet ohne UI und schliesst nur nach erfolgreichem Abschluss automatisch.
.PARAMETER NoAutonomy
    Fuegt keine freigegebenen Arbeitsordner hinzu.
.PARAMETER NoAskUser
    Deaktiviert ask_user nur bei expliziter Angabe.
.PARAMETER ResumeSession
    Setzt eine Session mit gueltiger GUID fort.
.PARAMETER WorkerId
    Verwendet eine validierte bestehende Worker-ID.
.PARAMETER NewWindow
    Oeffnet ein eigenes Fenster statt eines Tabs im gemeinsamen Fenster.
.PARAMETER AllowDirs
    Freigegebene Arbeitsordner (--add-dir). Standard leer; ordnerspezifische Pfade
    bewusst nicht vorbelegt, um keine internen Verzeichnisse anzunehmen.
.PARAMETER Tier
    Optionales Tier (klein | standard | hoch); fuellt Model/Effort, falls nicht gesetzt.
#>
param(
    [string]$Tool = "copilot",
    [string]$Prompt = "",
    [string]$PromptFile = "",
    [string]$Role = "worker",
    [string]$WorkDir = "",
    [switch]$Interactive,
    [switch]$Headless,
    [string[]]$AllowDirs = @(),
    [switch]$NoAutonomy,
    [switch]$NoAskUser,
    [string]$ResumeSession = "",
    [string]$WorkerId = "",
    [string]$Tier = "",
    [string]$Model = "",
    [string]$Effort = "",
    [switch]$NoAutoClose,
    [string]$Window = "",
    [switch]$NewWindow,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\ai-worker-lib.ps1"
if (-not $DryRun) { Initialize-AiWorkerHome }

if (-not $WorkDir) { $WorkDir = (Get-Location).Path }

# Tier -> Modell/Effort aufloesen (nur fuellen, was nicht explizit gesetzt wurde).
if ($Tier) {
    $resolved = Resolve-AiModelTier -Tier $Tier
    if (-not $Model)  { $Model  = $resolved.model }
    if (-not $Effort) { $Effort = $resolved.effort }
}

if ($Tool -ine 'copilot') { Write-Error "Nur copilot wird unterstuetzt; Claude und Codex haben abweichende CLI-Argumente."; exit 1 }
$toolCmd = Get-Command $Tool -ErrorAction SilentlyContinue
if (-not $toolCmd) { Write-Error "'$Tool' nicht im PATH."; exit 1 }
$toolSrc = $toolCmd.Source

$wtCommand = Get-Command wt -ErrorAction SilentlyContinue
$wtPath = if ($wtCommand) { $wtCommand.Source } else { "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe" }
if (-not (Test-Path $wtPath)) { Write-Error "wt.exe nicht gefunden. Windows Terminal installieren."; exit 1 }

$shellCommand = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $shellCommand) { $shellCommand = Get-Command powershell -ErrorAction SilentlyContinue }
if (-not $shellCommand) { Write-Error "PowerShell nicht gefunden."; exit 1 }
$shellPath = $shellCommand.Source
if ($shellPath.IndexOfAny([char[]]@('"', ',', ';', "`r", "`n")) -ge 0) { Write-Error 'Ungueltiger PowerShell-Programmpfad.'; exit 1 }

if ($PromptFile) {
    $rp = Resolve-Path $PromptFile -ErrorAction SilentlyContinue
    if (-not $rp) { Write-Error "PromptFile nicht gefunden: $PromptFile"; exit 1 }
    if ($rp.Path -match '\\_recherche-rohdaten\\') { Write-Error "PromptFile aus _recherche-rohdaten ist nicht zulaessig."; exit 1 }
    $Prompt = Get-Content -LiteralPath $rp.Path -Raw -Encoding UTF8
}
$interactiveMode = -not $Headless
if ($Headless -and -not $Prompt -and -not $ResumeSession) {
    Write-Error "Headless-Worker (-Headless) braucht -Prompt oder -PromptFile."; exit 1
}

if (-not $WorkerId) { $WorkerId = New-AiWorkerId -Role $Role }
Assert-AiWorkerId -Id $WorkerId
$existing = if ($DryRun) { $null } else { Get-AiWorker -Id $WorkerId }
if ($ResumeSession) {
    $parsedSession = [guid]::Empty
    if (-not [guid]::TryParse($ResumeSession, [ref]$parsedSession)) { Write-Error 'Ungueltige Sitzungskennung.'; exit 1 }
    $sessionId = $ResumeSession
} else {
    $sessionId = if ($DryRun) { [guid]::NewGuid().ToString() } else { Get-AiWorkerSession -Id $WorkerId }
    # Alte Klartext-Sessions werden einmalig geschuetzt ausgelagert.
    if (-not $sessionId -and $existing -and $existing.PSObject.Properties.Name -contains 'sessionId') { $sessionId = $existing.sessionId }
    if (-not $sessionId) { $sessionId = [guid]::NewGuid().ToString() }
}
if (-not $DryRun) { Set-AiWorkerSession -Id $WorkerId -SessionId $sessionId }

$handoffPath = Join-Path (Get-AiWorkerHandoffDir) "$WorkerId.jsonl"

$origPrompt = $Prompt

# Interaktive Tabs bleiben bewusst zur Kontrolle offen.
$autoHandoff = (-not $NoAutonomy) -and $Prompt -and (-not $ResumeSession)
if ($autoHandoff) {
    $donePath  = Join-Path $PSScriptRoot 'ai-worker-done.ps1'
    $shellName = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
    $Prompt = $Prompt + "`n`n---`nAbschluss-Protokoll: Melde am Ende ausschliesslich strukturierten Status, niemals Freitext:`n$shellName -NoProfile -ExecutionPolicy Bypass -File `"$donePath`" -Worker $WorkerId -Status done`nBei Blocker/Abbruch -Status blocked bzw. -Status failed verwenden. Ergebnisse schreibender Aufgaben sind ausschliesslich Diff und Artefakte."
}

$copArgs = @()
if ($ResumeSession) {
    $copArgs += "--resume=$sessionId"
} else {
    $copArgs += @('--session-id', $sessionId, '--name', $WorkerId)
}
if (-not $NoAutonomy) {
    foreach ($d in $AllowDirs) { if ($d) { $copArgs += @('--add-dir', $d) } }
}
if ($NoAskUser) { $copArgs += '--no-ask-user' }
if ($Model)  { $copArgs += @('--model', $Model) }
if ($Effort) { $copArgs += @('--effort', $Effort) }
if ($interactiveMode) {
    if ($Prompt) { $copArgs += @('-i', $Prompt) }
} else {
    $copArgs += @('-p', $Prompt)
}

$autoClose = (-not $interactiveMode) -and (-not $NoAutoClose)

$taskShort = if ($origPrompt) { '(nicht persistiert)' } else { '(interaktiv)' }
if (-not $DryRun) { Register-AiWorker @{
    id         = $WorkerId
    name       = $WorkerId
    role       = $Role
    tool       = $Tool
    status     = 'starting'
    task       = $taskShort
    workdir    = $WorkDir
    handoff    = $handoffPath
    interactive= [bool]$interactiveMode
    autoClose  = [bool]$autoClose
    startedAt  = (Get-Date -Format s)
} }

function Quote-Ps([string]$s) { return "'" + ($s -replace "'", "''") + "'" }
$argLiteral = '@(' + (($copArgs | ForEach-Object { Quote-Ps $_ }) -join ', ') + ')'

$L = @()
$L += "`$ErrorActionPreference = 'Continue'"
$L += "Set-Location $(Quote-Ps $WorkDir)"
$L += ". $(Quote-Ps (Join-Path $PSScriptRoot 'ai-worker-lib.ps1'))"
$L += "`$env:AI_WORKER_HOME = $(Quote-Ps (Get-AiWorkerHome))"
$L += "try { `$Host.UI.RawUI.WindowTitle = 'AIW $WorkerId' } catch {}"
$L += "Set-AiWorkerField -Id $(Quote-Ps $WorkerId) -Fields @{ pid = `$PID; status = 'running' }"
$L += "`$tool = $(Quote-Ps $toolSrc)"
$L += "`$copArgs = $argLiteral"
$L += "`$exit = 0"
if ($interactiveMode) {
    $L += "try { & `$tool @copArgs; `$exit = `$LASTEXITCODE } catch { `$exit = 1; Write-Host `$_ }"
} else {
    $L += "`$handoffBefore = if (Test-Path -LiteralPath $(Quote-Ps $handoffPath)) { (Get-Item -LiteralPath $(Quote-Ps $handoffPath)).Length } else { -1 }"
    $L += "try { & `$tool @copArgs 2>&1 | Out-Null; `$exit = `$LASTEXITCODE } catch { `$exit = 1 }"
    $L += "`$handoffAfter = if (Test-Path -LiteralPath $(Quote-Ps $handoffPath)) { (Get-Item -LiteralPath $(Quote-Ps $handoffPath)).Length } else { -1 }"
    $L += "`$headlessStatus = if (`$exit -eq 0) { 'done' } else { 'failed' }"
    $L += "if (`$handoffAfter -eq `$handoffBefore) { @{ workerId = $(Quote-Ps $WorkerId); status = `$headlessStatus; finishedAt = (Get-Date -Format s) } | ConvertTo-Json -Compress | Out-File -LiteralPath $(Quote-Ps $handoffPath) -Append -Encoding UTF8 }"
}
$L += "if (`$null -eq `$exit) { `$exit = 0 }"
$L += "`$st = if (`$exit -eq 0) { 'done' } else { 'failed' }"
$L += "`$currentWorker = Get-AiWorker -Id $(Quote-Ps $WorkerId)"
$L += "if (-not `$currentWorker -or `$currentWorker.status -in @('starting','running')) { Set-AiWorkerField -Id $(Quote-Ps $WorkerId) -Fields @{ status = `$st; exitCode = `$exit; finishedAt = (Get-Date -Format s) }; `$effectiveStatus = `$st } else { `$effectiveStatus = `$currentWorker.status }"
$autoCloseLiteral = if ($autoClose) { '$true' } else { '$false' }
$L += "`$keepOpen = (`$effectiveStatus -ne 'done') -or (-not $autoCloseLiteral)"
$L += "if (`$keepOpen) { Write-Host ''; Write-Host ('[AIW $WorkerId] status=' + `$effectiveStatus + ' exit=' + `$exit + '  -- Tab bleibt offen. Enter zum Schliessen.') -ForegroundColor Cyan; try { [void][System.Console]::ReadLine() } catch { Start-Sleep -Seconds 3600 } }"
$L += "Remove-Item -LiteralPath `$MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue"
$launcherSource = $L -join "`n"
$launcherCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($launcherSource))

if (-not $Window) { $Window = if ($env:AI_WORKER_WINDOW) { $env:AI_WORKER_WINDOW } else { 'ai-workers' } }
if ($Window -cnotmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$') {
    Write-Error 'Ungueltiger Windows-Terminal-Fenstername.'; exit 1
}
$wtTarget = if ($NewWindow) { 'new' } else { $Window }
$wtArgs = @('-w', $wtTarget, 'nt', '--title', "AIW $WorkerId", $shellPath, '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $launcherCommand)
# Validierung, Base64 und Quoting verhindern WT-Subcommand-Injection.
$wtArgumentLine = ($wtArgs | ForEach-Object { '"' + ([string]$_) + '"' }) -join ' '
if ($DryRun) {
    Write-Host "DryRun erfolgreich: Argumente und Launcher enthalten vertrauliche Werte und werden nicht ausgegeben." -ForegroundColor Yellow
} else {
    Start-Process -FilePath $wtPath -ArgumentList $wtArgumentLine
}

Write-Host "Worker gestartet:" -ForegroundColor Cyan
Write-Host "  id        : $WorkerId"
Write-Host "  role      : $Role"
Write-Host "  modus     : $(if ($interactiveMode) {'interaktiv-autonom (-i, UI sichtbar)'} else {'headless (-p)'})  autoClose=$autoClose"
Write-Host "  handoff   : $handoffPath"
Write-Host "  fernsteuern: aisend $WorkerId `"<folgeauftrag>`"   |  schliessen: aiclose $WorkerId"
