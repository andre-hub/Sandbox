[CmdletBinding()]
param(
    [switch]$Reconfigure,
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
$configPath = Join-Path $PSScriptRoot 'config.ini'
$examplePath = Join-Path $PSScriptRoot 'config.example.ini'

function Get-ConfigValue {
    param([string]$Content, [string]$Key)
    $match = [regex]::Match($Content, "(?m)^\s*$([regex]::Escape($Key))\s*=(.*)$")
    if (-not $match.Success) { return '' }
    return $match.Groups[1].Value.TrimEnd([char[]]@("`r"))
}

function Test-Username {
    param([string]$Value)
    return $Value -cmatch '^[a-z][a-z0-9_-]{2,31}$'
}

function Test-Password {
    param([string]$Value)
    return $Value.Length -ge 12 -and $Value.Length -le 256 -and
        $Value.IndexOfAny([char[]]@("`r", "`n", [char]0)) -lt 0
}

function ConvertTo-PlainText {
    param([Security.SecureString]$Value)
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Value)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer) }
}

function Get-RequiredSids {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent().User
    return @(
        $current,
        (New-Object Security.Principal.SecurityIdentifier('S-1-5-32-544')),
        (New-Object Security.Principal.SecurityIdentifier('S-1-5-18'))
    )
}

function Set-PrivateAcl {
    param([string]$Path)
    $security = New-Object Security.AccessControl.FileSecurity
    $security.SetAccessRuleProtection($true, $false)
    foreach ($sid in (Get-RequiredSids)) {
        $rule = New-Object Security.AccessControl.FileSystemAccessRule(
            $sid, [Security.AccessControl.FileSystemRights]::FullControl,
            [Security.AccessControl.AccessControlType]::Allow)
        [void]$security.AddAccessRule($rule)
    }
    Set-Acl -LiteralPath $Path -AclObject $security
}

function Test-PrivateAcl {
    param([string]$Path)
    try { $acl = Get-Acl -LiteralPath $Path } catch { return $false }
    if (-not $acl.AreAccessRulesProtected) { return $false }
    $required = @((Get-RequiredSids) | ForEach-Object { $_.Value })
    $allowed = @{}
    foreach ($rule in $acl.Access) {
        $sid = $rule.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value
        if ($rule.AccessControlType -eq 'Allow' -and $sid -notin $required) { return $false }
        if ($rule.AccessControlType -eq 'Allow' -and $sid -in $required) { $allowed[$sid] = $true }
    }
    return @($required | Where-Object { -not $allowed.ContainsKey($_) }).Count -eq 0
}

function Set-ConfigValue {
    param([string]$Content, [string]$Key, [string]$Value)
    $pattern = "(?m)^(\s*$([regex]::Escape($Key))\s*=).*$"
    $regex = New-Object regex($pattern)
    if ($regex.IsMatch($Content)) {
        return $regex.Replace($Content, { param($m) $m.Groups[1].Value + $Value }, 1)
    }
    return $Content.TrimEnd() + "`r`n$Key=$Value`r`n"
}

function Get-MissingTemplateKeys {
    param([string]$Content, [string]$Template)
    $missing = @()
    foreach ($match in [regex]::Matches($Template, '(?m)^([A-Z][A-Z0-9_]*)=(.*)$')) {
        $key = $match.Groups[1].Value
        if ($key -in @('APP_USERNAME', 'APP_PASSWORD')) { continue }
        if (-not [regex]::IsMatch($Content, "(?m)^$([regex]::Escape($key))=")) { $missing += $key }
    }
    return $missing
}

function Add-MissingTemplateValues {
    param([string]$Content, [string]$Template, [string[]]$Keys)
    foreach ($key in $Keys) {
        $Content = Set-ConfigValue $Content $key (Get-ConfigValue $Template $key)
    }
    return $Content
}

function Write-ConfigAtomically {
    param([string]$Content)
    $temporaryPath = "$configPath.tmp-$([guid]::NewGuid().ToString('N'))"
    try {
        [IO.File]::WriteAllBytes($temporaryPath, [byte[]]@())
        Set-PrivateAcl -Path $temporaryPath
        [IO.File]::WriteAllText($temporaryPath, $Content, (New-Object Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $configPath) {
            Set-PrivateAcl -Path $configPath
            [IO.File]::Replace($temporaryPath, $configPath, $null, $true)
        } else {
            [IO.File]::Move($temporaryPath, $configPath)
        }
    } finally {
        if (Test-Path -LiteralPath $temporaryPath) { Remove-Item -LiteralPath $temporaryPath -Force }
    }
}

if (-not (Test-Path -LiteralPath $examplePath -PathType Leaf)) { throw 'Konfigurationsvorlage fehlt.' }
$template = [IO.File]::ReadAllText($examplePath)
$exists = Test-Path -LiteralPath $configPath -PathType Leaf
$content = if ($exists) { [IO.File]::ReadAllText($configPath) } else { $template }
$credentialsComplete = (Test-Username (Get-ConfigValue $content 'APP_USERNAME')) -and
    (Test-Password (Get-ConfigValue $content 'APP_PASSWORD'))
$missingKeys = @(Get-MissingTemplateKeys $content $template)
$complete = $credentialsComplete -and $missingKeys.Count -eq 0
$secure = $exists -and (Test-PrivateAcl $configPath)

if ($ValidateOnly) {
    if (-not $complete -or -not $secure) { throw 'Lokale Zugangsdaten-Konfiguration fehlt, ist unvollstaendig oder unsicher.' }
    exit 0
}
if ($complete -and $secure -and -not $Reconfigure) { exit 0 }
if ($credentialsComplete -and $secure -and $missingKeys.Count -gt 0 -and -not $Reconfigure) {
    Write-ConfigAtomically (Add-MissingTemplateValues $content $template $missingKeys)
    exit 0
}
if ($exists -and -not $Reconfigure -and $credentialsComplete -and -not $secure) {
    throw 'Bestehende Zugangsdaten-Konfiguration hat keine sichere ACL. Explizit mit -Reconfigure erneuern.'
}

$username = Read-Host 'APP_USERNAME'
if (-not (Test-Username $username)) { throw 'APP_USERNAME ist ungueltig.' }
$firstSecure = Read-Host 'APP_PASSWORD' -AsSecureString
$secondSecure = Read-Host 'APP_PASSWORD wiederholen' -AsSecureString
$first = ConvertTo-PlainText $firstSecure
$second = ConvertTo-PlainText $secondSecure
try {
    if (-not (Test-Password $first)) { throw 'APP_PASSWORD erfuellt die Sicherheitsanforderungen nicht.' }
    if ($first -cne $second) { throw 'Die Passwoerter stimmen nicht ueberein.' }
    $content = Add-MissingTemplateValues $content $template $missingKeys
    $content = Set-ConfigValue $content 'APP_USERNAME' $username
    $content = Set-ConfigValue $content 'APP_PASSWORD' $first
    Write-ConfigAtomically $content
} finally {
    $first = $null
    $second = $null
    $firstSecure.Dispose()
    $secondSecure.Dispose()
}
Write-Host '[OK] Lokale Zugangsdaten-Konfiguration ist bereit.'
