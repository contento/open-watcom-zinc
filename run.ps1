# run.ps1 - Launch DOSBox-X with the project config (Windows host)
# Usage: .\run.ps1        — build and run demo.exe
#        .\run.ps1 -s     — drop to DOS prompt (no demo.exe)

param(
    [Alias('s')]
    [switch]$Shell,
    [Alias('h')]
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\run.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -s, -Shell   Drop to DOS prompt (skip demo.exe)"
    Write-Host "  -h, -Help    Show this help"
    exit 0
}

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DemoExe     = Join-Path $ProjectRoot 'demo.exe'
$Conf        = Join-Path $ProjectRoot 'dosbox-x.conf'

if (-not $Shell -and -not (Test-Path $DemoExe)) {
    Write-Error "demo.exe not found. Build first: wmake"
    exit 1
}

if ($Shell) {
    $Conf = Join-Path $env:TEMP 'dosbox-shell.conf'
    @"
[autoexec]
mount c .
c:
"@ | Set-Content $Conf
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

& $DosBoxX -conf $Conf
