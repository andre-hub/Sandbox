#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Zeigt registrierte Worker ohne Sitzungskennungen an.
#>
param(
    [switch]$Active,
    [switch]$Prune,
    [switch]$Full
)
. "$PSScriptRoot\ai-worker-lib.ps1"

$workers = Get-AiWorkers
foreach ($w in $workers) {
    $alive = $false
    if ($w.PSObject.Properties.Name -contains 'pid' -and $w.pid) {
        $alive = [bool](Get-Process -Id $w.pid -ErrorAction SilentlyContinue)
    }
    $w | Add-Member -NotePropertyName 'alive' -NotePropertyValue $alive -Force
}

if ($Prune) {
    foreach ($w in $workers) {
        if (-not $w.alive -and $w.status -notin @('done','failed','closed')) {
            Set-AiWorkerField -Id $w.id -Fields @{ status = 'closed' }
        }
    }
    $workers = Get-AiWorkers
    foreach ($w in $workers) {
        $alive = $false
        if ($w.PSObject.Properties.Name -contains 'pid' -and $w.pid) { $alive = [bool](Get-Process -Id $w.pid -ErrorAction SilentlyContinue) }
        $w | Add-Member -NotePropertyName 'alive' -NotePropertyValue $alive -Force
    }
}

if ($Active) { $workers = $workers | Where-Object { $_.alive -or $_.status -in @('starting','running') } }

if (-not $workers -or @($workers).Count -eq 0) { Write-Host "Keine Worker registriert." -ForegroundColor DarkGray; return }

if ($Full) {
    $workers | Format-List id, role, status, alive, pid, task, handoff, workdir, startedAt, updatedAt, finishedAt, exitCode
} else {
    $workers | Sort-Object startedAt | Format-Table -AutoSize `
        @{L='id';E={$_.id}}, @{L='role';E={$_.role}}, @{L='status';E={$_.status}},
        @{L='alive';E={if($_.alive){'ja'}else{'-'}}}, @{L='pid';E={$_.pid}},
        @{L='task';E={ if($_.task){ $_.task.Substring(0,[Math]::Min(40,$_.task.Length)) } }}
}
Write-Host ""
Write-Host "Fernsteuern: aisend <id> `"<auftrag>`"   Schliessen: aiclose <id>   Details: aiworkers -Full" -ForegroundColor DarkGray
