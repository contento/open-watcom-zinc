#!/usr/bin/env bash
# scripts/setup.sh — Install Open Watcom 2.0 + Open Zinc to vendor/
#
# Usage:
#   bash scripts/setup.sh                 # install, print env to set manually
#   source scripts/setup.sh               # install + export env in current shell
#
# Supported: macOS (Intel + Apple Silicon), Linux (x86_64, aarch64)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/vendor"
OW_DIR="$VENDOR_DIR/watcom"
ZINC_DIR="$VENDOR_DIR/zinc"
ZINC_URL="http://www.openzinc.com/Downloads/OZ1.zip"

OW_RELEASE="https://github.com/open-watcom/open-watcom-v2/releases/download/Current-build"
OW_SNAPSHOT="$OW_RELEASE/ow-snapshot.tar.xz"

# ── helpers ────────────────────────────────────────────────────────────────────
info()  { echo "[setup] $*"; }
err()   { echo "[setup] ERROR: $*" >&2; exit 1; }
req()   { command -v "$1" &>/dev/null || err "'$1' not found — install it first."; }

# ── detect platform ────────────────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin)
        [ "$ARCH" = "arm64" ] && OW_BINDIR="armo64" || OW_BINDIR="bino64"
        OW_EXE="$OW_DIR/$OW_BINDIR"
        ;;
    Linux)
        [ "$ARCH" = "aarch64" ] && OW_BINDIR="arml64" || OW_BINDIR="binl64"
        OW_EXE="$OW_DIR/$OW_BINDIR"
        ;;
    *)
        err "Use scripts/setup.ps1 on Windows."
        ;;
esac

# ── Step 1: Open Watcom 2.0 ────────────────────────────────────────────────────
req curl
req tar

if [ -f "$OW_EXE/wmake" ]; then
    info "Open Watcom already present at $OW_DIR"
else
    info "Downloading Open Watcom snapshot (~140 MB)..."
    mkdir -p "$OW_DIR"
    curl -fsSL "$OW_SNAPSHOT" -o /tmp/ow-snapshot.tar.xz
    tar -xf /tmp/ow-snapshot.tar.xz -C "$OW_DIR" --strip-components=1
    rm /tmp/ow-snapshot.tar.xz
    if [ ! -f "$OW_EXE/wmake" ]; then
        err "Snapshot extracted but $OW_EXE/wmake not found — unexpected layout."
    fi
    info "Open Watcom installed → $OW_DIR"
fi

# ── Step 2: Open Zinc source ───────────────────────────────────────────────────
req unzip

if [ -d "$ZINC_DIR/SOURCE" ]; then
    info "Open Zinc already present at $ZINC_DIR"
else
    info "Downloading Open Zinc..."
    mkdir -p "$ZINC_DIR"
    curl -fsSL "$ZINC_URL" -o /tmp/OZ1.zip
    unzip -q /tmp/OZ1.zip -d "$ZINC_DIR"
    rm /tmp/OZ1.zip
    if [ ! -d "$ZINC_DIR/SOURCE" ]; then
        err "Zinc zip extracted but SOURCE/ directory not found."
    fi
    info "Open Zinc ready → $ZINC_DIR"
fi

# ── Step 3: Build Zinc library for OW2 ─────────────────────────────────────────
# build-zinc-ow2.sh is also run automatically by every makefile via common.mk,
# but we build it here so the first `wmake` is fast.
if [ -f "$ZINC_DIR/LIB/OW2/D32_ZIL.LIB" ]; then
    info "Zinc OW2 library already built"
else
    info "Building Zinc library for Open Watcom 2.0..."
    PATH="$OW_EXE:$PATH" WATCOM="$OW_DIR" \
        bash "$REPO_ROOT/scripts/build-zinc-ow2.sh"
    info "Zinc OW2 library built → $ZINC_DIR/LIB/OW2/D32_ZIL.LIB"
fi

# ── export env vars for caller ─────────────────────────────────────────────────
export WATCOM="$OW_DIR"
export ZINC_HOME="$ZINC_DIR"
export PATH="$OW_EXE:$PATH"

info "────────────────────────────────────────"
info "Setup complete."
info "  WATCOM    = $OW_DIR"
info "  ZINC_HOME = $ZINC_DIR"
info ""
info "To persist in this shell, source the script:"
info "  source scripts/setup.sh"
info ""
info "Now build any example:"
info "  cd examples/hello-world && wmake"
info "────────────────────────────────────────"