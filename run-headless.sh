#!/bin/sh
# run-headless.sh - Launch DOSBox-X headlessly (no window) on macOS/Linux
# Usage: sh run-headless.sh
# Runs demo.exe inside DOSBox-X; exits when the app quits normally.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMO_EXE="$SCRIPT_DIR/demo.exe"
CONF="$SCRIPT_DIR/dosbox-x-headless.conf"

if [ ! -f "$DEMO_EXE" ]; then
    echo "ERROR: demo.exe not found. Build first: wmake" >&2
    exit 1
fi

# Suppress the SDL window and audio — DOSBox-X still runs the DOS session
export SDL_VIDEODRIVER=dummy
export SDL_AUDIODRIVER=dummy

echo "Launching DOSBox-X headlessly..."
dosbox-x -conf "$CONF"
