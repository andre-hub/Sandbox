#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setzt einen Worker per geschuetzter Session-ID mit einem Folgeauftrag fort.
.PARAMETER Worker
    ID eines registrierten Workers mit gespeicherter Session.
.PARAMETER Message
    Nicht leerer Folgeauftrag.
#>
param(
    [Parameter(Mandatory, Position=0)][string]$Worker,
    [Parameter(Mandatory, Position=1, ValueFromRemainingArguments=$true)][string[]]$Message,
    [switch]$Interactive,
    [switch]$DryRun
)
. "$PSScriptRoot\ai-worker-lib.ps1"

$w = Get-AiWorker -Id $Worker
if (-not $w) { Write-Error "Worker '$Worker' nicht in Registry gefunden. 'aiworkers' zeigt bekannte IDs."; exit 1 }
$sessionId = Get-AiWorkerSession -Id $w.id
# Alte Klartext-Sessions werden einmalig geschuetzt ausgelagert.
if (-not $sessionId -and $w.PSObject.Properties.Name -contains 'sessionId') {
    $sessionId = $w.sessionId
    Set-AiWorkerSession -Id $w.id -SessionId $sessionId
}
if (-not $sessionId) { Write-Error "Worker '$Worker' kann nicht fortgesetzt werden."; exit 1 }

$msg = ($Message -join ' ').Trim()
if (-not $msg) { Write-Error "Kein Folgeauftrag angegeben."; exit 1 }

$role = if ($w.PSObject.Properties.Name -contains 'role' -and $w.role) { $w.role } else { 'worker' }
$wd   = if ($w.PSObject.Properties.Name -contains 'workdir' -and $w.workdir) { $w.workdir } else { (Get-Location).Path }

$spawn = Join-Path $PSScriptRoot 'ai-spawn-direct.ps1'
$params = @{
    Tool          = if ($w.PSObject.Properties.Name -contains 'tool' -and $w.tool) { $w.tool } else { 'copilot' }
    Role          = $role
    WorkerId      = $w.id
    ResumeSession = $sessionId
    WorkDir       = $wd
    Prompt        = $msg
}
if ($Interactive) { $params['Interactive'] = $true } else { $params['Headless'] = $true }
if ($DryRun)      { $params['DryRun'] = $true } else { Set-AiWorkerField -Id $w.id -Fields @{ status = 'running' } }
& $spawn @params

if (-not $DryRun) {
    Write-Host "Folgeauftrag an $($w.id) gesendet." -ForegroundColor Cyan
}
