#!/bin/sh
# run-headless.sh - Launch DOSBox-X headlessly (no window) on macOS/Linux
# Usage: sh run-headless.sh
# Runs demo.exe inside DOSBox-X; exits when the app quits normally.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMO_EXE="$SCRIPT_DIR/demo.exe"
CONF="$SCRIPT_DIR/dosbox-x-headless.conf"

if [ ! -f "$DEMO_EXE" ]; then
    echo "ERROR: demo.exe not found. Build first: wmake" >&2
    exit 1
fi

# Locate dosbox-x: PATH first, then common macOS locations
DOSBOXX="$(command -v dosbox-x 2>/dev/null)"

if [ -z "$DOSBOXX" ]; then
    for candidate in \
        /Applications/DOSBox-X.app/Contents/MacOS/dosbox-x \
        "$HOME/Applications/DOSBox-X.app/Contents/MacOS/dosbox-x" \
        /opt/homebrew/bin/dosbox-x \
        /usr/local/bin/dosbox-x
    do
        if [ -x "$candidate" ]; then
            DOSBOXX="$candidate"
            break
        fi
    done
fi

if [ -z "$DOSBOXX" ]; then
    echo "ERROR: dosbox-x not found. Install via Homebrew: brew install dosbox-x" >&2
    exit 1
fi

export SDL_VIDEODRIVER=dummy
export SDL_AUDIODRIVER=dummy

echo "Launching DOSBox-X headlessly..."
"$DOSBOXX" -conf "$CONF"
