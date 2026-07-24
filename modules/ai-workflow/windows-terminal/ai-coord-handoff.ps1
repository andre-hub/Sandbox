#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Startet einen Nachfolge-Koordinator aus Prompt oder Checkpoint-Datei.
.PARAMETER Prompt
    Direkter Auftrag; alternativ PromptFile verwenden.
.PARAMETER PromptFile
    Checkpoint-Datei; alternativ Prompt verwenden.
#>
param(
    [string]$Prompt = "",
    [string]$PromptFile = "",
    [string]$ResumeSession = "",
    [string]$Role = "coordinator",
    [string]$WorkDir = "",
    [string]$SelfId = "",
    [switch]$Interactive = $true,
    [switch]$DryRun
)
. "$PSScriptRoot\ai-worker-lib.ps1"

if (-not $Prompt -and -not $PromptFile) {
    Write-Error "Nachfolger braucht -Prompt oder -PromptFile (Resume-Checkpoint/Plan-Status)."; exit 1
}
if (-not $WorkDir) { $WorkDir = (Get-Location).Path }

$before = @(Get-AiWorkers | Where-Object { $_.role -eq $Role -and $_.status -in @('starting','running') } | ForEach-Object { $_.id })

$spawn = Join-Path $PSScriptRoot 'ai-spawn-direct.ps1'
$params = @{ Role = $Role; WorkDir = $WorkDir; NewWindow = $true }
if ($Interactive) { $params['Interactive'] = $true }
if ($Prompt)        { $params['Prompt'] = $Prompt }
if ($PromptFile)    { $params['PromptFile'] = $PromptFile }
if ($ResumeSession) { $params['ResumeSession'] = $ResumeSession }
if ($DryRun)        { $params['DryRun'] = $true }
& $spawn @params

if ($DryRun) { Write-Host "(DryRun) Nachfolger wuerde als eigenes Fenster starten." -ForegroundColor DarkGray; return }

$successor = $null
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Milliseconds 500
    $successor = Get-AiWorkers | Where-Object {
        $_.role -eq $Role -and $_.status -in @('starting','running') -and ($before -notcontains $_.id)
    } | Sort-Object startedAt | Select-Object -Last 1
    if ($successor) { break }
}

if (-not $successor) {
    Write-Warning "Nachfolger nicht in Registry bestaetigt - bitte pruefen."
    exit 1
}
Write-Host "Nachfolger laeuft: $($successor.id)." -ForegroundColor Cyan

if (-not $SelfId) {
    Write-Host "Kein -SelfId angegeben. Aktuelles Koordinator-Fenster bitte selbst schliessen." -ForegroundColor DarkGray
    return
}

$self = Get-AiWorker -Id $SelfId
if (-not $self) { Write-Warning "Eigene ID '$SelfId' nicht gefunden - nicht geschlossen."; return }
Assert-AiWorkerId -Id $self.id
Set-AiWorkerField -Id $self.id -Fields @{ status = 'closed'; closedAt = (Get-Date -Format s); handoffTo = $successor.id }

$hostPid = if ($self.PSObject.Properties.Name -contains 'pid' -and $self.pid) { [int]$self.pid } else { 0 }
if (-not $hostPid) { Write-Host "Kein eigener PID registriert - Fenster bitte manuell schliessen." -ForegroundColor DarkGray; return }

# Abgekoppelter Helfer schliesst das eigene Koordinator-Fenster, sobald der Nachfolger laeuft.
# PID-Reuse-geschuetzter Kill ueber die Shared-Lib (Stop-AiWorkerProcessTree), kein rohes
# Stop-Process nach PID. Die eigene ID ist per Assert-AiWorkerId auf [a-z0-9-] beschraenkt.
$libPath = Join-Path $PSScriptRoot 'ai-worker-lib.ps1'
$sid = $self.id
$killer = @"
Start-Sleep -Milliseconds 800
try { . '$libPath' } catch { return }
`$self = Get-AiWorker -Id '$sid'
if (`$self) {
    `$p = if (`$self.PSObject.Properties.Name -contains 'pid' -and `$self.pid) { Get-Process -Id ([int]`$self.pid) -ErrorAction SilentlyContinue } else { `$null }
    if (`$p) { try { Stop-AiWorkerProcessTree -WorkerEntry `$self -Process `$p } catch {} }
    try { Close-WtTabIfHanging -WorkerId '$sid' } catch {}
}
"@
$enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($killer))
$sh = (Get-Command pwsh -ErrorAction SilentlyContinue); if (-not $sh) { $sh = Get-Command powershell -ErrorAction SilentlyContinue }
Start-Process -FilePath $sh.Source -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',$enc)
Write-Host "Uebergabe abgeschlossen. Eigenes Fenster wird geschlossen." -ForegroundColor DarkGray
