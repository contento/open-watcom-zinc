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

# ow-snapshot.tar.xz contains host binaries for all platforms; pick the right subdir.
# There is no separate macOS asset — the snapshot is the canonical download.
case "$OS" in
    Darwin)
        # bino64 = macOS Intel x64, armo64 = macOS Apple Silicon
        if [ "$ARCH" = "arm64" ]; then
            OW_BINDIR="armo64"
        else
            OW_BINDIR="bino64"
        fi
        ;;
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            OW_BINDIR="binl64"
        elif [ "$ARCH" = "aarch64" ]; then
            OW_BINDIR="arml64"
        else
            OW_BINDIR="binl"
        fi
        ;;
    *)
        error "Unsupported OS: $OS — use setup.bat on Windows."
        ;;
esac

OW_DIR="$VENDOR_DIR/watcom"
OW_SNAPSHOT_URL="https://github.com/open-watcom/open-watcom-v2/releases/download/Current-build/ow-snapshot.tar.xz"

# ── Open Watcom ─────────────────────────────────────────────────────────────
require curl
require tar

if [ -d "$OW_DIR/$OW_BINDIR" ]; then
    info "Open Watcom already present at $OW_DIR"
else
    info "Downloading Open Watcom snapshot..."
    mkdir -p "$OW_DIR"
    curl -fsSL "$OW_SNAPSHOT_URL" -o /tmp/owatcom.tar.xz
    tar -xf /tmp/owatcom.tar.xz -C "$OW_DIR" --strip-components=1
    rm /tmp/owatcom.tar.xz
    info "Open Watcom installed → $OW_DIR"
fi

# ── Open Zinc ───────────────────────────────────────────────────────────────
# OZ1.zip is a pre-built binary distribution — no compilation required.
require unzip

if [ -f "$ZINC_DIR/LIB/OW19/D32_ZIL.LIB" ]; then
    info "Open Zinc already present at $ZINC_DIR"
else
    info "Downloading Open Zinc..."
    mkdir -p "$ZINC_DIR"
    curl -fsSL "$ZINC_URL" -o /tmp/OZ1.zip
    unzip -q /tmp/OZ1.zip -d "$ZINC_DIR"
    rm /tmp/OZ1.zip
    info "Open Zinc ready → $ZINC_DIR"
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
