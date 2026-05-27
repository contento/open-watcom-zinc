# run.ps1 - Launch DOSBox-X with the project config (Windows host)
# Usage: .\run.ps1
# Requires DOSBox-X installed and on PATH, or in a standard location.

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DemoExe     = Join-Path $ProjectRoot 'demo.exe'
$Conf        = Join-Path $ProjectRoot 'dosbox-x.conf'

if (-not (Test-Path $DemoExe)) {
    Write-Error "demo.exe not found. Build first: wmake"
    exit 1
}

# Locate DOSBox-X — check PATH first, then common install locations
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

Write-Host "Launching: $DosBoxX"
Write-Host "Config   : $Conf"
Write-Host "Project  : $ProjectRoot"

& $DosBoxX -conf $Conf
