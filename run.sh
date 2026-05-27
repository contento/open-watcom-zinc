#!/bin/sh
# run.sh - Launch DOSBox-X with the project config (macOS / Linux host)
# Usage: sh run.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMO_EXE="$SCRIPT_DIR/demo.exe"
CONF="$SCRIPT_DIR/dosbox-x.conf"

if [ ! -f "$DEMO_EXE" ]; then
    echo "ERROR: demo.exe not found. Build first: wmake" >&2
    exit 1
fi

echo "Launching: dosbox-x"
echo "Config   : $CONF"
dosbox-x -conf "$CONF"
