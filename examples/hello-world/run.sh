#!/bin/sh
# run.sh - Launch DOSBox-X with the project config (macOS / Linux host)
# Usage: sh run.sh        — build and run hello.exe
#        sh run.sh -s     — drop to DOS prompt (no hello.exe)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMO_EXE="$SCRIPT_DIR/hello.exe"
CONF="$SCRIPT_DIR/dosbox-x.conf"

SHELL_ONLY=0
case "$1" in
    -s|--shell) SHELL_ONLY=1 ;;
    -h|--help)
        echo "Usage: sh run.sh [options]"
        echo ""
        echo "Options:"
        echo "  -s, --shell   Drop to DOS prompt (skip hello.exe)"
        echo "  -h, --help    Show this help"
        exit 0 ;;
esac

if [ "$SHELL_ONLY" = "0" ] && [ ! -f "$DEMO_EXE" ]; then
    echo "ERROR: hello.exe not found. Build first: wmake" >&2
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
