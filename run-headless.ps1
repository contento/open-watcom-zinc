# run-headless.ps1 - Launch DOSBox-X headlessly (no window) on Windows
# Usage: .\run-headless.ps1
# Runs demo.exe inside DOSBox-X; exits when the app quits normally.

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DemoExe     = Join-Path $ProjectRoot 'demo.exe'
$Conf        = Join-Path $ProjectRoot 'dosbox-x-headless.conf'

if (-not (Test-Path $DemoExe)) {
    Write-Error "demo.exe not found. Build first: wmake"
    exit 1
}

# Locate DOSBox-X
$DosBoxX = Get-Command 'dosbox-x' -ErrorAction SilentlyContinue |
           Select-Object -ExpandProperty Source

if (-not $DosBoxX) {
    $Candidates = @(
        "$env:ProgramFiles\DOSBox-X\dosbox-x.exe",
        "$env:ProgramFiles(x86)\DOSBox-X\dosbox-x.exe",
        "$env:LocalAppData\DOSBox-X\dosbox-x.exe"
    )
    $DosBoxX = $Candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $DosBoxX) {
    Write-Error "DOSBox-X not found. Install it or add it to PATH."
    exit 1
}

# Suppress the SDL window and audio for this process only
$env:SDL_VIDEODRIVER = 'dummy'
$env:SDL_AUDIODRIVER = 'dummy'

Write-Host "Launching DOSBox-X headlessly..."
& $DosBoxX -conf $Conf
