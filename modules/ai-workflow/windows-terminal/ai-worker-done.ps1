#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Persistiert ausschliesslich Worker-ID, Status und Abschlusszeit, meldet den
    Abschluss an die Koordinator-Inbox und schliesst den eigenen Tab.
.DESCRIPTION
    Letzter Schritt eines fertigen Workers. Es wird bewusst kein Freitext-Ergebnis
    gespeichert - nur ID, Status und Zeit (Datensparsamkeit). Zusaetzlich wird ein
    Feedback-Eintrag in die Koordinator-Inbox geschrieben (aiinbox liest/quittiert das)
    und der eigene Tab ueber einen abgekoppelten, PID-Reuse-geschuetzten Helfer beendet.
.PARAMETER Worker
    ID eines registrierten Workers.
.PARAMETER Status
    Erlaubt sind done, blocked und failed.
.PARAMETER NoClose
    Meldet nur den Status, ohne den eigenen Tab zu schliessen.
#>
param(
    [Parameter(Mandatory, Position=0)][string]$Worker,
    [ValidateSet('done','blocked','failed')][string]$Status = 'done',
    [switch]$NoClose
)
. "$PSScriptRoot\ai-worker-lib.ps1"

$w = Get-AiWorker -Id $Worker
if (-not $w) { Write-Error "Worker '$Worker' nicht gefunden."; exit 1 }

$handoff = Join-Path (Get-AiWorkerHandoffDir) "$($w.id).jsonl"

$stamp = Get-Date -Format s
@{ workerId = $w.id; status = $Status; finishedAt = $stamp } |
    ConvertTo-Json -Compress |
    Out-File -LiteralPath $handoff -Append -Encoding UTF8
Set-AiWorkerField -Id $w.id -Fields @{ status = $Status; finishedAt = $stamp }

# Feedback-Loop: Koordinator-Inbox informieren (aiinbox liest/quittiert das).
# Datensparsam: nur ID/Rolle/Status/Zeit, kein Freitext-Ergebnis.
$roleForInbox = if ($w.PSObject.Properties.Name -contains 'role' -and $w.role) { $w.role } else { '' }
try {
    Add-AiInboxEntry -WorkerId $w.id -Role $roleForInbox -Status $Status
} catch {
    Write-Warning "Inbox-Eintrag fehlgeschlagen: $($_.Exception.Message)"
}

Write-Host "[$($w.id)] Status gemeldet (status=$Status)." -ForegroundColor Cyan

if ($NoClose) { return }

$hostPid = if ($w.PSObject.Properties.Name -contains 'pid' -and $w.pid) { [int]$w.pid } else { 0 }
if (-not $hostPid) { Write-Host "Kein PID registriert - Tab bitte manuell schliessen." -ForegroundColor DarkGray; return }

Assert-AiWorkerId -Id $w.id
Set-AiWorkerField -Id $w.id -Fields @{ closedAt = $stamp }

# Abgekoppelter Helfer: schliesst den Tab-Prozessbaum, nachdem dieses Skript endet
# (dieses Skript liegt selbst im zu schliessenden Prozessbaum). Der Helfer laedt die
# Shared-Lib erneut und nutzt Stop-AiWorkerProcessTree - inkl. PID-Reuse-Schutz -,
# danach den UIA-Tab-Close-Fallback. Kein unvalidiertes Force-Kill nach PID.
# Die Worker-ID ist per Assert-AiWorkerId auf [a-z0-9-] beschraenkt (Injektionsschutz).
$libPath = Join-Path $PSScriptRoot 'ai-worker-lib.ps1'
$wid = $w.id
$killer = @"
Start-Sleep -Milliseconds 800
try { . '$libPath' } catch { return }
`$w = Get-AiWorker -Id '$wid'
if (`$w) {
    `$p = if (`$w.PSObject.Properties.Name -contains 'pid' -and `$w.pid) { Get-Process -Id ([int]`$w.pid) -ErrorAction SilentlyContinue } else { `$null }
    if (`$p) { try { Stop-AiWorkerProcessTree -WorkerEntry `$w -Process `$p } catch {} }
    try { Close-WtTabIfHanging -WorkerId '$wid' } catch {}
}
"@
$enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($killer))
$sh = (Get-Command pwsh -ErrorAction SilentlyContinue); if (-not $sh) { $sh = Get-Command powershell -ErrorAction SilentlyContinue }
Start-Process -FilePath $sh.Source -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',$enc)
Write-Host "Tab wird geschlossen ..." -ForegroundColor DarkGray
