<#
.SYNOPSIS
  Bootstrap Open Watcom and Open Zinc for local development (PowerShell)

.DESCRIPTION
  PowerShell equivalent of scripts\setup.bat. Download and install Open
  Watcom into vendor\watcom and extract/build Open Zinc into
  vendor\zinc. Prints environment variables to persist in the caller.

.USAGE
  Dot-source to persist environment variables in the current session:
    .\scripts\setup.ps1

  Or run in a clean session (environment vars will not persist):
    powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
#>

Set-StrictMode -Version Latest
[CmdletBinding()]
param()

function Info { Write-Host "[setup]" $args -ForegroundColor Cyan }
function Err  { Write-Host "[setup] ERROR:" $args -ForegroundColor Red }

$RepoRoot = Split-Path -Parent $PSScriptRoot
$VendorDir = Join-Path $RepoRoot 'vendor'
$OWDir = Join-Path $VendorDir 'watcom'
$ZincDir = Join-Path $VendorDir 'zinc'
$ZincUrl = 'http://www.openzinc.com/Downloads/OZ1.zip'
$OWReleases = 'https://github.com/open-watcom/open-watcom-v2/releases/latest/download'

# Choose installer asset for Windows
$OWAsset = 'open-watcom-2_0-c-win-x64.exe'

if (Test-Path (Join-Path $OWDir 'binnt64\wmake.exe')) {
    Info "Open Watcom already present at $OWDir"
} else {
    Info "Downloading Open Watcom..."
    if (-not (Test-Path $OWDir)) { New-Item -ItemType Directory -Path $OWDir | Out-Null }
    $installer = Join-Path $env:TEMP 'owatcom_setup.exe'
    Invoke-WebRequest -Uri "$OWReleases/$OWAsset" -OutFile $installer -UseBasicParsing -ErrorAction Stop
    Info "Running Open Watcom installer (silent)..."
    $args = "/DIR=`"$OWDir`" /VERYSILENT /NORESTART"
    $proc = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        Err "Open Watcom installer failed with exit code $($proc.ExitCode)"
        Remove-Item $installer -ErrorAction SilentlyContinue
        exit 1
    }
    Remove-Item $installer -ErrorAction SilentlyContinue
    Info "Open Watcom installed → $OWDir"
}

if (Test-Path (Join-Path $ZincDir '.built')) {
    Info "Open Zinc already built at $ZincDir"
    goto SetEnv
}

if (-not (Test-Path (Join-Path $ZincDir '.extracted'))) {
    Info "Downloading Open Zinc..."
    if (-not (Test-Path $ZincDir)) { New-Item -ItemType Directory -Path $ZincDir | Out-Null }
    $zip = Join-Path $env:TEMP 'OZ1.zip'
    Invoke-WebRequest -Uri $ZincUrl -OutFile $zip -UseBasicParsing -ErrorAction Stop
    Info "Extracting Open Zinc..."
    Expand-Archive -Path $zip -DestinationPath $ZincDir -Force
    Remove-Item $zip -ErrorAction SilentlyContinue
    New-Item -ItemType File -Path (Join-Path $ZincDir '.extracted') | Out-Null
    Info "Open Zinc extracted → $ZincDir"
}

Info "Building Open Zinc for DOS/4GW..."
$env:WATCOM = $OWDir
$env:PATH = "$(Join-Path $OWDir 'binnt64');$env:PATH"
Push-Location $ZincDir
try {
    $build = Start-Process -FilePath 'wmake' -ArgumentList '-f','makefile.ow','target=dos4g' -NoNewWindow -Wait -PassThru
    if ($build.ExitCode -ne 0) {
        Err "Zinc build failed (exit code $($build.ExitCode))."
        Pop-Location
        exit 1
    }
} catch {
    Err "Failed to invoke wmake: $_"
    Pop-Location
    exit 1
}
Pop-Location
New-Item -ItemType File -Path (Join-Path $ZincDir '.built') | Out-Null
Info "Open Zinc built."

:SetEnv
$env:WATCOM = $OWDir
$env:ZINC_HOME = $ZincDir
$env:PATH = "$(Join-Path $OWDir 'binnt64');$env:PATH"

Info "────────────────────────────────────────"
Info "WATCOM   = $env:WATCOM"
Info "ZINC_HOME= $env:ZINC_HOME"
Write-Host ""
Info "To persist these in your current PowerShell session, dot-source this script:";
Write-Host "  .\scripts\setup.ps1"
Write-Host ""
Info "To build the demo:";
Write-Host "  wmake"
Info "────────────────────────────────────────"

# End of script
