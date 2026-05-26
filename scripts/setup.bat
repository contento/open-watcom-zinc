@ECHO OFF
REM setup.bat — bootstrap Open Watcom and Open Zinc for local development (Windows)
REM Usage: scripts\setup.bat
SETLOCAL ENABLEDELAYEDEXPANSION

SET "REPO_ROOT=%~dp0.."
SET "VENDOR_DIR=%REPO_ROOT%\vendor"
SET "OW_DIR=%VENDOR_DIR%\watcom"
SET "ZINC_DIR=%VENDOR_DIR%\zinc"
SET "ZINC_URL=http://www.openzinc.com/Downloads/OZ1.zip"
SET "OW_ASSET=open-watcom-2_0-c-win-x64.exe"
SET "OW_RELEASES=https://github.com/open-watcom/open-watcom-v2/releases/latest/download"

WHERE curl >NUL 2>&1 || (ECHO [setup] ERROR: curl not found. Install it or use Windows 10+. & EXIT /B 1)

REM ── Open Watcom ────────────────────────────────────────────────────────────
IF EXIST "%OW_DIR%\binnt64\wmake.exe" (
    ECHO [setup] Open Watcom already present at %OW_DIR%
) ELSE (
    ECHO [setup] Downloading Open Watcom...
    IF NOT EXIST "%OW_DIR%" MKDIR "%OW_DIR%"
    curl -fsSL "%OW_RELEASES%/%OW_ASSET%" -o "%TEMP%\owatcom_setup.exe"
    REM Silent install to OW_DIR
    "%TEMP%\owatcom_setup.exe" /DIR="%OW_DIR%" /VERYSILENT /NORESTART
    DEL "%TEMP%\owatcom_setup.exe"
    ECHO [setup] Open Watcom installed ^→ %OW_DIR%
)

REM ── Open Zinc ──────────────────────────────────────────────────────────────
IF EXIST "%ZINC_DIR%\.built" (
    ECHO [setup] Open Zinc already built at %ZINC_DIR%
    GOTO SET_ENV
)

IF NOT EXIST "%ZINC_DIR%\.extracted" (
    ECHO [setup] Downloading Open Zinc...
    IF NOT EXIST "%ZINC_DIR%" MKDIR "%ZINC_DIR%"
    curl -fsSL "%ZINC_URL%" -o "%TEMP%\OZ1.zip"
    REM Use PowerShell to unzip (available on Windows 10+)
    powershell -NoProfile -Command "Expand-Archive -Path '%TEMP%\OZ1.zip' -DestinationPath '%ZINC_DIR%' -Force"
    DEL "%TEMP%\OZ1.zip"
    ECHO. > "%ZINC_DIR%\.extracted"
    ECHO [setup] Open Zinc extracted ^→ %ZINC_DIR%
)

ECHO [setup] Building Open Zinc for DOS/4GW...
SET "WATCOM=%OW_DIR%"
SET "PATH=%OW_DIR%\binnt64;%PATH%"
PUSHD "%ZINC_DIR%"
wmake -f makefile.ow target=dos4g
IF ERRORLEVEL 1 (
    ECHO [setup] ERROR: Zinc build failed.
    POPD
    EXIT /B 1
)
POPD
ECHO. > "%ZINC_DIR%\.built"
ECHO [setup] Open Zinc built.

:SET_ENV
SET "WATCOM=%OW_DIR%"
SET "ZINC_HOME=%ZINC_DIR%"
SET "PATH=%OW_DIR%\binnt64;%PATH%"

ECHO [setup] ────────────────────────────────────────
ECHO [setup] WATCOM    = %WATCOM%
ECHO [setup] ZINC_HOME = %ZINC_HOME%
ECHO [setup]
ECHO [setup] To build the demo:
ECHO [setup]   wmake
ECHO [setup] ────────────────────────────────────────

ENDLOCAL & SET "WATCOM=%WATCOM%" & SET "ZINC_HOME=%ZINC_HOME%" & SET "PATH=%PATH%"
