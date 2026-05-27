#!/bin/sh
# run.sh - Launch DOSBox-X with the project config (macOS / Linux host)
# Usage: sh run.sh        — build and run demo.exe
#        sh run.sh -s     — drop to DOS prompt (no demo.exe)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMO_EXE="$SCRIPT_DIR/demo.exe"
CONF="$SCRIPT_DIR/dosbox-x.conf"

SHELL_ONLY=0
if [ "$1" = "-s" ] || [ "$1" = "--shell" ]; then
    SHELL_ONLY=1
fi

if [ "$SHELL_ONLY" = "0" ] && [ ! -f "$DEMO_EXE" ]; then
    echo "ERROR: demo.exe not found. Build first: wmake" >&2
    exit 1
fi

if [ "$SHELL_ONLY" = "1" ]; then
    CONF="$(mktemp /tmp/dosbox-shell-XXXXXX.conf)"
    cat > "$CONF" << 'EOF'
[autoexec]
mount c .
c:
EOF
    trap 'rm -f "$CONF"' EXIT
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

echo "Launching : $DOSBOXX"
echo "Config    : $CONF"
"$DOSBOXX" -conf "$CONF"
