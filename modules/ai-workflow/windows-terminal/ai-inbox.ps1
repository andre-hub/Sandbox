#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Koordinator-Inbox: zeigt Feedback-Meldungen fertiger Worker (aidone) an.
.DESCRIPTION
    Liest die Inbox-Datei (JSON-Lines, geschrieben von Add-AiInboxEntry ueber
    ai-worker-done.ps1 / aidone) und zeigt offene (noch nicht quittierte) Eintraege an.
    Es wird bewusst nur ID/Rolle/Status/Zeit gefuehrt - kein Freitext-Ergebnis.
    Mit -Clear werden alle Eintraege quittiert (Inbox geleert). Mutex-geschuetzt
    ('Global\AiWorkerInboxMutex'), damit Lesen/Leeren nicht mit parallel schreibenden
    Workern kollidiert.

    Nutzung:
        aiinbox              # offene Eintraege anzeigen
        aiinbox -All         # auch bereits quittierte anzeigen
        aiinbox -Clear       # alle Eintraege quittieren/leeren
#>
param(
    [switch]$Clear,
    [switch]$All
)
. "$PSScriptRoot\ai-worker-lib.ps1"

$path = Get-AiWorkerInboxPath
if (-not (Test-Path -LiteralPath $path)) {
    Write-Host "Inbox leer (keine Eintraege bisher)." -ForegroundColor DarkGray
    return
}

$mutex = New-Object System.Threading.Mutex($false, 'Global\AiWorkerInboxMutex')
$acquired = $false
try {
    $acquired = $mutex.WaitOne(5000)
    if (-not $acquired) { Write-Warning "Inbox-Mutex nicht erhalten (Timeout nach 5s) - lese trotzdem." }

    $lines = @(Get-Content -LiteralPath $path -Encoding UTF8 | Where-Object { $_ -and $_.Trim() })
    $entries = @()
    foreach ($l in $lines) {
        try { $entries += ($l | ConvertFrom-Json) } catch { Write-Warning "Ungueltige Inbox-Zeile ignoriert." }
    }

    if ($Clear) {
        if (@($entries).Count -eq 0) {
            Write-Host "Inbox bereits leer." -ForegroundColor DarkGray
        } else {
            '' | Out-File -FilePath $path -Encoding UTF8 -NoNewline
            Write-Host "Inbox quittiert/geleert ($(@($entries).Count) Eintraege)." -ForegroundColor Cyan
        }
        return
    }

    $shown = if ($All) { $entries } else { @($entries | Where-Object { -not $_.acked }) }
    if (-not $shown -or @($shown).Count -eq 0) {
        Write-Host "Keine offenen Inbox-Eintraege." -ForegroundColor DarkGray
    } else {
        $shown | Sort-Object timestamp | Format-Table -AutoSize `
            @{L='timestamp'; E={$_.timestamp}}, @{L='workerId'; E={$_.workerId}},
            @{L='role'; E={$_.role}}, @{L='status'; E={$_.status}}
    }
} finally {
    if ($acquired) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}

Write-Host ""
Write-Host "Quittieren/Leeren: aiinbox -Clear   Alle inkl. quittiert: aiinbox -All" -ForegroundColor DarkGray
