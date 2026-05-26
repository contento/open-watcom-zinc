#!/usr/bin/env bash
# setup.sh — bootstrap Open Watcom and Open Zinc for local development
# Usage:  bash scripts/setup.sh
#         source scripts/setup.sh   (to also export env vars in current shell)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/vendor"
ZINC_DIR="$VENDOR_DIR/zinc"
ZINC_URL="http://www.openzinc.com/Downloads/OZ1.zip"

# ── helpers ────────────────────────────────────────────────────────────────
info()  { echo "[setup] $*"; }
error() { echo "[setup] ERROR: $*" >&2; exit 1; }

require() {
    command -v "$1" &>/dev/null || error "'$1' not found — please install it first."
}

# ── detect host platform ────────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin)
        OW_ASSET="open-watcom-2_0-c-macosx-x64.tar.gz"
        OW_BINDIR="binl64"
        ;;
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            OW_ASSET="open-watcom-2_0-c-linux-x64.tar.gz"
            OW_BINDIR="binl64"
        else
            OW_ASSET="open-watcom-2_0-c-linux-x86.tar.gz"
            OW_BINDIR="binl"
        fi
        ;;
    *)
        error "Unsupported OS: $OS — use setup.bat on Windows."
        ;;
esac

OW_DIR="$VENDOR_DIR/watcom"
OW_RELEASES="https://github.com/open-watcom/open-watcom-v2/releases/latest/download"

# ── Open Watcom ─────────────────────────────────────────────────────────────
require curl
require tar

if [ -d "$OW_DIR/$OW_BINDIR" ]; then
    info "Open Watcom already present at $OW_DIR"
else
    info "Downloading Open Watcom ($OW_ASSET)..."
    mkdir -p "$OW_DIR"
    curl -fsSL "$OW_RELEASES/$OW_ASSET" -o /tmp/owatcom.tar.gz
    tar -xf /tmp/owatcom.tar.gz -C "$OW_DIR" --strip-components=1
    rm /tmp/owatcom.tar.gz
    info "Open Watcom installed → $OW_DIR"
fi

# ── Open Zinc ───────────────────────────────────────────────────────────────
require unzip

if [ -f "$ZINC_DIR/.built" ]; then
    info "Open Zinc already built at $ZINC_DIR"
else
    if [ ! -f "$ZINC_DIR/.extracted" ]; then
        info "Downloading Open Zinc..."
        mkdir -p "$ZINC_DIR"
        curl -fsSL "$ZINC_URL" -o /tmp/OZ1.zip
        unzip -q /tmp/OZ1.zip -d "$ZINC_DIR"
        rm /tmp/OZ1.zip
        touch "$ZINC_DIR/.extracted"
        info "Open Zinc extracted → $ZINC_DIR"
    fi

    info "Building Open Zinc for DOS/4GW..."
    export WATCOM="$OW_DIR"
    export PATH="$OW_DIR/$OW_BINDIR:$PATH"
    (cd "$ZINC_DIR" && wmake -f makefile.ow target=dos4g)
    touch "$ZINC_DIR/.built"
    info "Open Zinc built."
fi

# ── print env exports ────────────────────────────────────────────────────────
export WATCOM="$OW_DIR"
export ZINC_HOME="$ZINC_DIR"
export PATH="$OW_DIR/$OW_BINDIR:$PATH"

info "────────────────────────────────────────"
info "WATCOM   = $WATCOM"
info "ZINC_HOME= $ZINC_HOME"
info ""
info "To persist these in your current shell, run:"
info "  source scripts/setup.sh"
info ""
info "To build the demo:"
info "  wmake"
info "────────────────────────────────────────"
