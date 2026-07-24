<#
.SYNOPSIS
    Verwaltet Registry, Handoffs und geschuetzte Sessions der AI-Worker.
#>

# Kein StrictMode, da alte Registry-Eintraege optionale Felder haben.

function Get-AiWorkerHome {
    if ($env:AI_WORKER_HOME) { return $env:AI_WORKER_HOME }
    return (Join-Path $env:USERPROFILE 'ai-workers')
}

function Get-AiWorkerRegistryPath { return (Join-Path (Get-AiWorkerHome) 'registry.json') }
function Get-AiWorkerHandoffDir   { return (Join-Path (Get-AiWorkerHome) 'handoff') }
function Get-AiWorkerLogDir       { return (Join-Path (Get-AiWorkerHome) 'logs') }
function Get-AiWorkerSessionDir   { return (Join-Path (Get-AiWorkerHome) 'sessions') }
function Get-AiWorkerInboxPath    { return (Join-Path (Get-AiWorkerHome) 'inbox.jsonl') }

function Assert-AiWorkerId {
    param([Parameter(Mandatory)][string]$Id)
    if ($Id -cnotmatch '^[a-z0-9][a-z0-9-]{0,63}$') {
        throw "Ungueltige Worker-ID. Erlaubt sind 1-64 Kleinbuchstaben, Ziffern und Bindestriche."
    }
}

function Initialize-AiWorkerHome {
    $root = Get-AiWorkerHome
    foreach ($d in @($root, (Get-AiWorkerHandoffDir), (Get-AiWorkerLogDir), (Get-AiWorkerSessionDir))) {
        if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }
    $reg = Get-AiWorkerRegistryPath
    if (-not (Test-Path -LiteralPath $reg)) { '[]' | Out-File -FilePath $reg -Encoding UTF8 }
}

function ConvertTo-AiWorkerJson {
    param($Workers)
    $items = @($Workers | Where-Object { $_ })
    if ($items.Count -eq 0) { return '[]' }
    $parts = $items | ForEach-Object { $_ | ConvertTo-Json -Depth 8 -Compress }
    return "[`n" + ($parts -join ",`n") + "`n]"
}

# Der globale Mutex serialisiert parallele Registry-Aenderungen.
function Invoke-AiWorkerRegistryUpdate {
    param([Parameter(Mandatory)][scriptblock]$Action)
    Initialize-AiWorkerHome
    $mutex = New-Object System.Threading.Mutex($false, 'Global\AiWorkerRegistryMutex')
    [void]$mutex.WaitOne()
    try {
        $reg = Get-AiWorkerRegistryPath
        $json = Get-Content -LiteralPath $reg -Raw -Encoding UTF8
        $workers = @()
        if ($json -and $json.Trim()) { $workers = @($json | ConvertFrom-Json) }
        $result = & $Action $workers
        ConvertTo-AiWorkerJson $result | Out-File -FilePath $reg -Encoding UTF8
    } finally {
        $mutex.ReleaseMutex(); $mutex.Dispose()
    }
}

# Fuegt der Koordinator-Inbox einen Feedback-Eintrag hinzu (Worker-Abschluss).
# Datensparsam: nur Worker-ID, Rolle, Status und Zeit werden persistiert - bewusst
# KEIN Freitext-Ergebnis (die Registry/Handoffs speichern ebenfalls nur ID/Status/Zeit).
# JSON-Lines, Mutex-geschuetzt gegen Interleaving paralleler Worker.
function Add-AiInboxEntry {
    param(
        [Parameter(Mandatory)][string]$WorkerId,
        [string]$Role = '',
        [ValidateSet('done','blocked','failed')][string]$Status = 'done'
    )
    Assert-AiWorkerId -Id $WorkerId
    Initialize-AiWorkerHome
    $path = Get-AiWorkerInboxPath
    $entry = [ordered]@{
        workerId  = $WorkerId
        role      = $Role
        status    = $Status
        timestamp = (Get-Date -Format s)
        acked     = $false
    }
    $line = $entry | ConvertTo-Json -Compress -Depth 5
    $mutex = New-Object System.Threading.Mutex($false, 'Global\AiWorkerInboxMutex')
    $acquired = $false
    try {
        $acquired = $mutex.WaitOne(5000)
        if (-not $acquired) { Write-Warning 'Inbox-Mutex nicht erhalten (Timeout nach 5s) - Eintrag wird trotzdem versucht.' }
        Add-Content -LiteralPath $path -Value $line -Encoding UTF8
    } finally {
        if ($acquired) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

function Get-AiWorkers {
    Initialize-AiWorkerHome
    $registryPath = Get-AiWorkerRegistryPath
    $json = Get-Content -LiteralPath $registryPath -Raw -Encoding UTF8
    if (-not $json -or -not $json.Trim()) { return @() }
    # Alte Klartext-Sessions werden einmalig geschuetzt ausgelagert.
    if ($json -match '"sessionId"') {
        Invoke-AiWorkerRegistryUpdate {
            param($workers)
            foreach ($worker in $workers) {
                if ($worker.PSObject.Properties.Name -contains 'sessionId') {
                    $legacySession = [string]$worker.sessionId
                    $worker.PSObject.Properties.Remove('sessionId')
                    $parsedSession = [guid]::Empty
                    if ($worker.id -cmatch '^[a-z0-9][a-z0-9-]{0,63}$' -and [guid]::TryParse($legacySession, [ref]$parsedSession)) {
                        Protect-AiWorkerSession -Id $worker.id -SessionId $legacySession
                    }
                }
            }
            $workers
        }
        $json = Get-Content -LiteralPath $registryPath -Raw -Encoding UTF8
    }
    return @($json | ConvertFrom-Json)
}

function Get-AiWorker {
    param([Parameter(Mandatory)][string]$Id)
    Assert-AiWorkerId -Id $Id
    foreach ($w in (Get-AiWorkers)) {
        $props = $w.PSObject.Properties.Name
        $wid = if ($props -contains 'id')   { $w.id }   else { $null }
        $wnm = if ($props -contains 'name') { $w.name } else { $null }
        if ($wid -eq $Id -or $wnm -eq $Id) { return $w }
    }
    return $null
}

function Register-AiWorker {
    param([Parameter(Mandatory)][hashtable]$Worker)
    if (-not $Worker.ContainsKey('updatedAt')) { $Worker['updatedAt'] = (Get-Date -Format s) }
    $id = $Worker['id']
    Assert-AiWorkerId -Id $id
# Sitzungskennungen duerfen nicht in die lesbare Registry gelangen.
    if ($Worker.ContainsKey('sessionId')) { $Worker.Remove('sessionId') }
    Invoke-AiWorkerRegistryUpdate {
        param($workers)
        @($workers | Where-Object { $_.id -ne $id }) + ([pscustomobject]$Worker)
    }.GetNewClosure()
}

function Set-AiWorkerField {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][hashtable]$Fields
    )
    Assert-AiWorkerId -Id $Id
    if ($Fields.ContainsKey('sessionId')) { throw 'sessionId darf nicht in der Registry gespeichert werden.' }
    Invoke-AiWorkerRegistryUpdate {
        param($workers)
        foreach ($w in $workers) {
            $props = $w.PSObject.Properties.Name
            $wid = if ($props -contains 'id')   { $w.id }   else { $null }
            $wnm = if ($props -contains 'name') { $w.name } else { $null }
            if ($wid -eq $Id -or $wnm -eq $Id) {
                foreach ($k in $Fields.Keys) {
                    $w | Add-Member -NotePropertyName $k -NotePropertyValue $Fields[$k] -Force
                }
                $w | Add-Member -NotePropertyName 'updatedAt' -NotePropertyValue (Get-Date -Format s) -Force
            }
        }
        $workers
    }.GetNewClosure()
}

function Remove-AiWorker {
    param([Parameter(Mandatory)][string]$Id)
    Assert-AiWorkerId -Id $Id
    Invoke-AiWorkerRegistryUpdate {
        param($workers)
        @($workers | Where-Object {
            $props = $_.PSObject.Properties.Name
            $wid = if ($props -contains 'id')   { $_.id }   else { $null }
            $wnm = if ($props -contains 'name') { $_.name } else { $null }
            $wid -ne $Id -and $wnm -ne $Id
        })
    }.GetNewClosure()
}

function New-AiWorkerId {
    param([string]$Role = 'worker')
    $safeRole = ($Role -replace '[^a-zA-Z0-9]', '').ToLower()
    if (-not $safeRole) { $safeRole = 'worker' }
    if ($safeRole.Length -gt 53) { $safeRole = $safeRole.Substring(0, 53) }
    $stamp = Get-Date -Format 'HHmmss'
    $rand  = -join ((48..57) + (97..122) | Get-Random -Count 3 | ForEach-Object { [char]$_ })
    return "$safeRole-$stamp-$rand"
}

function Set-AiWorkerSession {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$SessionId
    )
    Assert-AiWorkerId -Id $Id
    $parsedSession = [guid]::Empty
    if (-not [guid]::TryParse($SessionId, [ref]$parsedSession)) { throw 'Ungueltige Sitzungskennung.' }
    Initialize-AiWorkerHome
    Protect-AiWorkerSession -Id $Id -SessionId $SessionId
}

function Protect-AiWorkerSession {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$SessionId
    )
    $secure = ConvertTo-SecureString -String $SessionId -AsPlainText -Force
    $protected = ConvertFrom-SecureString -SecureString $secure
    $path = Join-Path (Get-AiWorkerSessionDir) "$Id.txt"
    [System.IO.File]::WriteAllText($path, $protected, (New-Object System.Text.UTF8Encoding($false)))
}

function Get-AiWorkerSession {
    param([Parameter(Mandatory)][string]$Id)
    Assert-AiWorkerId -Id $Id
    $path = Join-Path (Get-AiWorkerSessionDir) "$Id.txt"
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    $protected = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    if (-not $protected) { return $null }
    $secure = ConvertTo-SecureString -String $protected
    $credential = New-Object System.Management.Automation.PSCredential('session', $secure)
    return $credential.GetNetworkCredential().Password
}

# Tier -> Modell/Effort-Tabelle (Single Source of Truth), generisch/service-frei.
# Tier: klein | standard | hoch. Ohne -Tier wird die Rolle ueber RoleTierMap abgebildet.
function Resolve-AiModelTier {
    param(
        [string]$Tier = '',
        [string]$Role = ''
    )
    $TierTable = @{
        'klein'    = @{ model = 'claude-sonnet-5';  effort = 'low'    }
        'standard' = @{ model = 'claude-sonnet-5';  effort = 'medium' }
        'hoch'     = @{ model = 'claude-opus-4-8';  effort = 'high'   }
    }
    $RoleTierMap = @{
        'reviewer'             = 'klein'
        'tester'               = 'klein'
        'documenter'           = 'klein'
        'explorer'             = 'klein'
        'developer'            = 'standard'
        'anforderer'           = 'standard'
        'architect'            = 'hoch'
        'refactorer'           = 'standard'
        'frontend'             = 'standard'
        'devops'               = 'standard'
        'enterprise-architect' = 'hoch'
        'security'             = 'hoch'
    }
    if (-not $Tier -and $Role) {
        $safeRole = $Role.ToLower() -replace '[^a-z0-9-]', ''
        if ($RoleTierMap.ContainsKey($safeRole)) { $Tier = $RoleTierMap[$safeRole] }
    }
    if (-not $Tier) { $Tier = 'klein' }
    if (-not $TierTable.ContainsKey($Tier)) {
        throw "Ungueltiger Tier '$Tier'. Erlaubt: klein | standard | hoch"
    }
    return @{ tier = $Tier; model = $TierTable[$Tier].model; effort = $TierTable[$Tier].effort }
}

# Prueft, dass der registrierte Prozess sicher zum Worker gehoert (Schutz vor PID-Reuse).
# Zeitkorridor zwischen startedAt und updatedAt; zwei Sekunden gleichen Zeitpraezision aus.
function Test-AiWorkerProcess($WorkerEntry, $Process) {
    if ($Process.ProcessName -notin @('pwsh', 'powershell')) { return $false }
    if ($WorkerEntry.PSObject.Properties.Name -notcontains 'startedAt' -or -not $WorkerEntry.startedAt) { return $false }
    if ($WorkerEntry.PSObject.Properties.Name -notcontains 'updatedAt' -or -not $WorkerEntry.updatedAt) { return $false }

    $registeredAt = [datetime]::MinValue
    if (-not [datetime]::TryParse([string]$WorkerEntry.startedAt, [ref]$registeredAt)) { return $false }
    $pidRecordedAt = [datetime]::MinValue
    if (-not [datetime]::TryParse([string]$WorkerEntry.updatedAt, [ref]$pidRecordedAt)) { return $false }

    return ($Process.StartTime -ge $registeredAt.AddSeconds(-2) -and
        $Process.StartTime -le $pidRecordedAt.AddSeconds(2))
}

function Get-AiWorkerProcessTreeIds([int]$RootPid) {
    $processes = @(Get-CimInstance Win32_Process -ErrorAction Stop | Select-Object ProcessId, ParentProcessId)
    $treeIds = @($RootPid)
    do {
        $previousCount = $treeIds.Count
        $children = @($processes | Where-Object { $_.ParentProcessId -in $treeIds } | ForEach-Object { [int]$_.ProcessId })
        $treeIds = @($treeIds + $children | Select-Object -Unique)
    } while ($treeIds.Count -gt $previousCount)
    return $treeIds
}

# Beendet den validierten Prozessbaum eines Workers (taskkill /T /F) - nur nach PID-Reuse-Schutz.
# Zentral in der Shared-Lib, damit ai-close.ps1 UND die Selbstschliessung (ai-worker-done.ps1)
# denselben gehaerteten Kill nutzen, ohne die Validierung zu umgehen.
function Stop-AiWorkerProcessTree($WorkerEntry, $Process) {
    if (-not (Test-AiWorkerProcess $WorkerEntry $Process)) {
        throw "Der registrierte Prozess passt nicht sicher zum Worker '$($WorkerEntry.id)'; Abbruch zum Schutz vor PID-Reuse."
    }

    $treeIds = @(Get-AiWorkerProcessTreeIds -RootPid $Process.Id)
    $taskkill = Join-Path $env:SystemRoot 'System32\taskkill.exe'
    & $taskkill /PID ([string]$Process.Id) /T /F 2>&1 | Out-Null

    $deadline = (Get-Date).AddSeconds(10)
    do {
        $remaining = @($treeIds | Where-Object { Get-Process -Id $_ -ErrorAction SilentlyContinue })
        if ($remaining.Count -eq 0) { return }
        Start-Sleep -Milliseconds 100
    } while ((Get-Date) -lt $deadline)

    throw "Der Prozessbaum von Worker '$($WorkerEntry.id)' wurde nicht vollstaendig beendet."
}

# Kurativer UIA-Fallback: findet den Windows-Terminal-Tab am Worker-Titel und betaetigt dessen
# "Close Tab"-Button per InvokePattern (kein SendKeys/Fokuswechsel). Genutzt von ai-close.ps1
# und der Selbstschliessung in ai-worker-done.ps1, falls das Force-Kill nur ein Exit-/Restart-
# Overlay hinterlaesst statt den Tab wirklich zu schliessen.
function Close-WtTabIfHanging([string]$WorkerId) {
    try {
        Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes -ErrorAction Stop
    } catch { return }
    Start-Sleep -Milliseconds 500  # WT Zeit geben, Exit-Overlay zu rendern
    try {
        $root = [System.Windows.Automation.AutomationElement]::RootElement
        $winCond = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ClassNameProperty, 'CASCADIA_HOSTING_WINDOW_CLASS')
        $wtWindows = $root.FindAll([System.Windows.Automation.TreeScope]::Children, $winCond)
        $hit = $null
        foreach ($win in $wtWindows) {
            $tabCond = New-Object System.Windows.Automation.PropertyCondition(
                [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
                [System.Windows.Automation.ControlType]::TabItem)
            $tabs = $win.FindAll([System.Windows.Automation.TreeScope]::Descendants, $tabCond)
            foreach ($t in $tabs) {
                if ($t.Current.Name -like "*$WorkerId*") { $hit = $t; break }
            }
            if ($hit) { break }
        }
        if (-not $hit) { return }  # Tab schon weg (closeOnExit hat gegriffen oder bereits geschlossen)
        $btnCond = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::Button)
        $btn = $hit.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $btnCond)
        if ($btn) { $btn.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke() }
    } catch { return }
}
