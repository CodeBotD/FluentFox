# FluentFox theme installer (Windows)
# Copies chrome\ + user.js into the default Firefox profile, with backups.

$ErrorActionPreference = "Stop"

$ThemeDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ChromeSrc = Join-Path $ThemeDir "chrome"
$UserJsSrc = Join-Path $ThemeDir "user.js"

function Die([string]$Message) {
  Write-Error $Message
  exit 1
}

if (-not (Test-Path $ChromeSrc)) { Die "missing $ChromeSrc" }
if (-not (Test-Path $UserJsSrc)) { Die "missing $UserJsSrc" }

$FirefoxDir = Join-Path $env:APPDATA "Mozilla\Firefox"
$ProfilesIni = Join-Path $FirefoxDir "profiles.ini"
if (-not (Test-Path $ProfilesIni)) {
  Die "profiles.ini not found at $ProfilesIni — is Firefox installed?"
}

$ini = Get-Content $ProfilesIni
$installDefault = $null
$profileDefault = $null
$firstPath = $null
$currentPath = $null
$inInstall = $false
$inProfile = $false
$pathRel = @{}

foreach ($line in $ini) {
  if ($line -match '^\[Install') { $inInstall = $true; $inProfile = $false; continue }
  if ($line -match '^\[Profile') { $inInstall = $false; $inProfile = $true; $currentPath = $null; continue }
  if ($line -match '^\[') { $inInstall = $false; $inProfile = $false; continue }

  if ($inInstall -and $line -match '^Default=(.+)$') {
    $installDefault = $Matches[1].Trim()
  }
  if ($inProfile -and $line -match '^Path=(.+)$') {
    $currentPath = $Matches[1].Trim()
    if (-not $firstPath) { $firstPath = $currentPath }
    if (-not $pathRel.ContainsKey($currentPath)) { $pathRel[$currentPath] = $true }
  }
  if ($inProfile -and $line -match '^IsRelative=(.+)$' -and $currentPath) {
    $pathRel[$currentPath] = ($Matches[1].Trim() -ne "0")
  }
  if ($inProfile -and $line -match '^Default=1$' -and $currentPath) {
    $profileDefault = $currentPath
  }
}

$path = if ($installDefault) { $installDefault } elseif ($profileDefault) { $profileDefault } else { $firstPath }
if (-not $path) { Die "could not determine default profile from $ProfilesIni" }

$isRelative = $true
if ($pathRel.ContainsKey($path)) { $isRelative = [bool]$pathRel[$path] }

$Profile = if ($isRelative) { Join-Path $FirefoxDir $path } else { $path }
if (-not (Test-Path $Profile)) { Die "profile directory does not exist: $Profile" }

$ChromeDest = Join-Path $Profile "chrome"
New-Item -ItemType Directory -Force -Path $ChromeDest | Out-Null

function Backup-IfExists([string]$File) {
  if (Test-Path $File) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = "$File.fluentfox-backup-$stamp"
    Copy-Item $File $backup
    Write-Host "  backed up $(Split-Path $File -Leaf) → $(Split-Path $backup -Leaf)"
  }
}

Write-Host "FluentFox theme installer"
Write-Host "  Firefox dir: $FirefoxDir"
Write-Host "  Profile:     $Profile"
Write-Host ""

Backup-IfExists (Join-Path $ChromeDest "userChrome.css")
Backup-IfExists (Join-Path $ChromeDest "userContent.css")
Backup-IfExists (Join-Path $Profile "user.js")

Copy-Item (Join-Path $ChromeSrc "userChrome.css") (Join-Path $ChromeDest "userChrome.css") -Force
Copy-Item (Join-Path $ChromeSrc "userContent.css") (Join-Path $ChromeDest "userContent.css") -Force
Copy-Item $UserJsSrc (Join-Path $Profile "user.js") -Force

Write-Host ""
Write-Host "Installed:"
Write-Host "  $ChromeDest\userChrome.css"
Write-Host "  $ChromeDest\userContent.css"
Write-Host "  $Profile\user.js"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Quit Firefox completely."
Write-Host "  2. Re-open Firefox so prefs and chrome CSS load."
Write-Host "  3. Use the System theme (or Default) under about:addons → Themes."
Write-Host "  4. Load the FluentFox extension (see README)."
Write-Host ""
Write-Host "Uninstall: remove chrome\userChrome.css, chrome\userContent.css, and user.js"
Write-Host "  (or restore *.fluentfox-backup-* files), then set"
Write-Host "  browser.tabs.allow_transparent_browser → false in about:config and restart."
