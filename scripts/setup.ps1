<#
.SYNOPSIS
  Install Open Watcom 2.0 + Open Zinc to vendor\ for DOS/4GW development.

.DESCRIPTION
  Dot-source to persist env vars in current session:
    .\scripts\setup.ps1

  Or run directly (env vars will not persist after exit):
    powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$VendorDir    = Join-Path $RepoRoot 'vendor'
$OWDir        = Join-Path $VendorDir 'watcom'
$ZincDir      = Join-Path $VendorDir 'zinc'
$ZincUrl      = 'http://www.openzinc.com/Downloads/OZ1.zip'
$OWRelease    = 'https://github.com/open-watcom/open-watcom-v2/releases/download/Current-build'

function Info { Write-Host "[setup]" $args -ForegroundColor Cyan }
function Err  { Write-Host "[setup] ERROR:" $args -ForegroundColor Red; exit 1 }

# ── Step 1: Open Watcom 2.0 ─────────────────────────────────────────────────────
$OWBin = Join-Path $OWDir 'binnt64'

if (Test-Path (Join-Path $OWBin 'wmake.exe')) {
    Info "Open Watcom already present at $OWDir"
} else {
    # Choose installer: 64-bit Windows, or fall back to 32-bit
    $ExeName = 'open-watcom-2_0-c-win-x64.exe'
    Info "Downloading Open Watcom installer ($ExeName)..."
    $Installer = Join-Path $env:TEMP $ExeName
    Invoke-WebRequest -Uri "$OWRelease/$ExeName" -OutFile $Installer -UseBasicParsing
    Info "Running installer (silent mode)..."
    $proc = Start-Process -FilePath $Installer -ArgumentList "/DIR=`"$OWDir`" /VERYSILENT /NORESTART" -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        Err "Installer exited with code $($proc.ExitCode). Try running $Installer manually."
    }
    Remove-Item $Installer -ErrorAction SilentlyContinue
    if (-not (Test-Path (Join-Path $OWBin 'wmake.exe'))) {
        Err "Installer ran but wmake.exe not found at $OWBin — check install path."
    }
    Info "Open Watcom installed → $OWDir"
}

# ── Step 2: Open Zinc source ────────────────────────────────────────────────────
$ExtractFlag = Join-Path $ZincDir '.extracted'

if (Test-Path $ExtractFlag) {
    Info "Open Zinc already present at $ZincDir"
} else {
    Info "Downloading Open Zinc..."
    $Zip = Join-Path $env:TEMP 'OZ1.zip'
    Invoke-WebRequest -Uri $ZincUrl -OutFile $Zip -UseBasicParsing
    Info "Extracting Open Zinc..."
    if (-not (Test-Path $ZincDir)) { New-Item -ItemType Directory -Path $ZincDir | Out-Null }
    Expand-Archive -Path $Zip -DestinationPath $ZincDir -Force
    Remove-Item $Zip -ErrorAction SilentlyContinue
    New-Item -ItemType File -Path $ExtractFlag | Out-Null
    Info "Open Zinc extracted → $ZincDir"
}

# ── Step 3: Build Zinc library for OW2 ──────────────────────────────────────────
$Ow2Lib = Join-Path $ZincDir 'LIB/OW2/D32_ZIL.LIB'

if (Test-Path $Ow2Lib) {
    Info "Zinc OW2 library already built"
} else {
    Info "Building Zinc library for Open Watcom 2.0..."
    $env:WATCOM = $OWDir
    $env:PATH = "$OWBin;$env:PATH"
    Push-Location $RepoRoot
    try {
        & "scripts/build-zinc-ow2.sh"
        if (-not (Test-Path $Ow2Lib)) {
            Err "build-zinc-ow2.sh completed but $Ow2Lib not found."
        }
    } catch {
        Pop-Location
        Err "Zinc build failed: $_"
    }
    Pop-Location
    Info "Zinc OW2 library built → $Ow2Lib"
}

# ── export env vars for caller ─────────────────────────────────────────────────
$env:WATCOM    = $OWDir
$env:ZINC_HOME = $ZincDir
$env:PATH      = "$OWBin;$env:PATH"

Info "────────────────────────────────────────"
Info "Setup complete."
Info "  WATCOM    = $OWDir"
Info "  ZINC_HOME = $ZincDir"
Info ""
Info "To persist in this shell, dot-source the script:"
Info "  .\scripts\setup.ps1"
Info ""
Info "Now build any example:"
Info "  cd examples\hello-world && wmake"
Info "────────────────────────────────────────"