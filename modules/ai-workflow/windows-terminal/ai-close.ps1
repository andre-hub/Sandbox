#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bereinigt beendete Worker; -Force beendet einen validierten Prozessbaum.
.PARAMETER Force
    Beendet einen laufenden Worker nur nach Schutz vor PID-Reuse.
#>
param(
    [Parameter(Position=0)][string]$Worker,
    [switch]$All,
    [switch]$Dead,
    [switch]$Force
)
. "$PSScriptRoot\ai-worker-lib.ps1"

# Der PID-Reuse-geschuetzte Prozessbaum-Kill (Stop-AiWorkerProcessTree, Test-AiWorkerProcess)
# und der UIA-Tab-Close-Fallback (Close-WtTabIfHanging) leben in ai-worker-lib.ps1 (Shared-Lib),
# damit auch die Selbstschliessung in ai-worker-done.ps1 dieselbe gehaertete Validierung nutzt.

function Close-One($w) {
    $process = if ($w.PSObject.Properties.Name -contains 'pid' -and $w.pid) { Get-Process -Id ([int]$w.pid) -ErrorAction SilentlyContinue } else { $null }
    if ($process -and -not $Force) {
        Write-Error "Worker '$($w.id)' laeuft noch. Zum Beenden -Force angeben."
        return $false
    }
    if ($process) { Stop-AiWorkerProcessTree -WorkerEntry $w -Process $process }
    Close-WtTabIfHanging -WorkerId $w.id
    Set-AiWorkerField -Id $w.id -Fields @{ status = 'closed'; closedAt = (Get-Date -Format s) }
    Write-Host "geschlossen: $($w.id)" -ForegroundColor Yellow
    return $true
}

$workers = Get-AiWorkers
if ($All -or $Dead) {
    foreach ($w in $workers) {
        $alive = $false
        if ($w.PSObject.Properties.Name -contains 'pid' -and $w.pid) { $alive = [bool](Get-Process -Id $w.pid -ErrorAction SilentlyContinue) }
        if ($Dead -and $alive) { continue }
        if ($w.status -eq 'closed') { continue }
        Close-One $w
    }
    return
}

if (-not $Worker) { Write-Error "Worker-ID angeben oder -All/-Dead nutzen."; exit 1 }
$w = Get-AiWorker -Id $Worker
if (-not $w) { Write-Error "Worker '$Worker' nicht gefunden."; exit 1 }
Close-One $w | Out-Null
