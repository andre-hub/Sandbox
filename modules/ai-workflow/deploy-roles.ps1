<#
.SYNOPSIS
    Deployt freigegebene Rollenseiten als Custom-Agents.
.PARAMETER RollenDir
    Ordner mit den zentralen Rollenseiten.
.PARAMETER AgentsMd
    Datei mit der Rollentabelle fuer die Beschreibungen.
.PARAMETER CopilotDir
    Zielordner fuer Copilot-Agents.
.PARAMETER ClaudeDir
    Zielordner fuer Claude-Agents.
.PARAMETER TrustedRoles
    Explizite Allowlist der freigegebenen Rollen.
.PARAMETER ApproveDeployment
    Erforderliche aktuelle Freigabe fuer das aktive Deployment.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RollenDir,
    [Parameter(Mandatory)][string]$AgentsMd,
    [Parameter(Mandatory)][string]$CopilotDir,
    [Parameter(Mandatory)][string]$ClaudeDir,
    [Parameter(Mandatory)][string[]]$TrustedRoles,
    [switch]$ApproveDeployment
)

$ErrorActionPreference = 'Stop'

if (-not $ApproveDeployment) { throw 'Deployment nicht freigegeben. Nach aktueller Benutzerfreigabe -ApproveDeployment angeben.' }

$knownRoles = @(
    'anforderer', 'architect', 'assistant', 'developer', 'devops', 'documenter',
    'enterprise-architect', 'explorer', 'frontend', 'quality', 'refactorer',
    'researcher', 'reviewer', 'security', 'tester'
)
$approvedRoles = @($TrustedRoles | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ } | Select-Object -Unique)
if ($approvedRoles.Count -eq 0) { throw 'TrustedRoles darf nicht leer sein.' }
foreach ($role in $approvedRoles) {
    if ($knownRoles -notcontains $role) { throw "Nicht freigegebene Rolle in TrustedRoles: $role" }
}

if (-not (Test-Path -LiteralPath $RollenDir)) { throw "RollenDir fehlt: $RollenDir" }
if (-not (Test-Path -LiteralPath $AgentsMd))  { throw "AgentsMd fehlt: $AgentsMd" }
foreach ($role in $approvedRoles) {
    if (-not (Test-Path -LiteralPath (Join-Path $RollenDir "$role.md") -PathType Leaf)) {
        throw "Freigegebene Rollendatei fehlt: $role.md"
    }
}

$desc = @{}
foreach ($line in Get-Content -LiteralPath $AgentsMd) {
    if ($line -match '^\|\s*`([a-z-]+)`\s*\|\s*(.+?)\s*\|\s*$') {
        $desc[$matches[1]] = $matches[2].Trim()
    }
}

foreach ($dir in @($CopilotDir, $ClaudeDir)) {
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

# Die gesicherten Zielordner werden bewusst auf die freigegebene Allowlist reduziert.
Get-ChildItem -LiteralPath $CopilotDir -Filter *.agent.md -File | Remove-Item -Force
Get-ChildItem -LiteralPath $ClaudeDir -Filter *.md -File | Remove-Item -Force

$count = 0
foreach ($role in $approvedRoles) {
    $file = Get-Item -LiteralPath (Join-Path $RollenDir "$role.md")

    $body = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $d = $desc[$role]
    if (-not $d) { $d = $role }
    $d = $d -replace '"', "'"

    $content = "---`nname: $role`ndescription: `"$d`"`n---`n`n" + $body
    $content = ($content -replace "`r`n", "`n") -replace "`n", "`r`n"

    [System.IO.File]::WriteAllText((Join-Path $CopilotDir "$role.agent.md"), $content, (New-Object System.Text.UTF8Encoding($false)))
    [System.IO.File]::WriteAllText((Join-Path $ClaudeDir  "$role.md"),       $content, (New-Object System.Text.UTF8Encoding($false)))
    $count++
}

Write-Host "[OK] $count Rollen als Custom-Agents deployed (copilot: .agent.md, claude: .md)."
