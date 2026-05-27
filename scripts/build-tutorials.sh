#!/bin/sh
# Build Open Zinc tutorial examples for DOS/4GW (32-bit DOS extended mode).
# Produces hello1.exe, hello2.exe, hello3.exe in tutorials/hello/
#
# Run from the project root: sh scripts/build-tutorials.sh
#
# Prerequisites: Open Watcom 2.0 in PATH, Zinc library already built.
#   If vendor/zinc/LIB/OW2/D32_ZIL.LIB is missing, run scripts/build-zinc-ow2.sh first.

set -e

ZINC_SRC=vendor/zinc/SOURCE
ZINC_INC=vendor/zinc/INCLUDE
TUTOR_HELLO=vendor/zinc/TUTOR/HELLO
ZINC_LIB=vendor/zinc/LIB/OW2/D32_ZIL.LIB
OW_INC=vendor/watcom/h
OW_LIB=vendor/watcom/lib386
OW_LIBDOS=vendor/watcom/lib386/dos
OUT_DIR=tutorials/hello
OBJ_DIR=/tmp/zinc_tutor_obj

CFLAGS="-bt=dos4g -3 -mf -fp3 -dDOS386 -zq -w0 -I$ZINC_INC -I$OW_INC"

# ── sanity checks ─────────────────────────────────────────────────────────────

if [ ! -f "$ZINC_LIB" ]; then
    echo "ERROR: $ZINC_LIB not found. Run scripts/build-zinc-ow2.sh first."
    exit 1
fi

if ! command -v wpp386 >/dev/null 2>&1; then
    echo "ERROR: wpp386 not found in PATH. Set WATCOM and add \$WATCOM/binl64 to PATH."
    exit 1
fi

# ── setup ─────────────────────────────────────────────────────────────────────

mkdir -p "$OBJ_DIR" "$OUT_DIR"

echo "Building Open Zinc HELLO tutorials for DOS/4GW..."
echo "  Library : $ZINC_LIB"
echo "  Output  : $OUT_DIR/"
echo ""

# ── text-mode z_app override ──────────────────────────────────────────────────
#
# The Zinc library was built with -dWCC (WCC graphics, falls back to text).
# For tutorials we force text-only by recompiling z_app.CPP with -dZIL_TEXT_ONLY
# and linking the override object *before* the library so the linker uses it.
# This avoids pulling in graph.lib and makes the tutorials stable in DOSBox-X.

printf "  Compiling z_app.CPP (text-only override) ... "
wpp386 $CFLAGS -dZIL_TEXT_ONLY \
    -fo="$OBJ_DIR/z_app_txt.obj" \
    "$ZINC_SRC/z_app.CPP" 2>/tmp/tutor_compile_err
echo "ok"

# ── helper: compile one source ────────────────────────────────────────────────

compile_src() {
    _src="$1"
    _obj="$2"
    _extra="$3"
    printf "  Compiling %-30s ... " "$(basename "$_src")"
    # shellcheck disable=SC2086  # CFLAGS and _extra need word splitting
    if wpp386 $CFLAGS $_extra -fo="$_obj" "$_src" 2>/tmp/tutor_compile_err; then
        echo "ok"
    else
        echo "FAILED"
        cat /tmp/tutor_compile_err
        return 1
    fi
}

# ── helper: link one tutorial EXE ────────────────────────────────────────────
#
# Text-only tutorials do NOT need graph.lib or its OW1→OW2 symbol aliases.
# The z_app_txt.obj override is listed before the library so the linker
# resolves UI_APPLICATION from the override rather than the library copy.
# A response file avoids shell quoting issues with wlink's directive syntax.

link_exe() {
    _name="$1"
    _obj="$2"
    _outexe="$OUT_DIR/${_name}.exe"
    _rsp="/tmp/tutor_link_${_name}.rsp"

    cat > "$_rsp" << WLINK_RSP
option quiet
system dos4g
name $_outexe
file $OBJ_DIR/z_app_txt.obj
file $_obj
lib $ZINC_LIB
libpath $OW_LIB
libpath $OW_LIBDOS
WLINK_RSP

    printf "  Linking  %-30s ... " "${_name}.exe"
    if wlink @"$_rsp" 2>/tmp/tutor_link_err; then
        echo "ok  ($(du -k "$_outexe" | cut -f1) KB)"
    else
        echo "FAILED"
        cat /tmp/tutor_link_err
        return 1
    fi
}

# ── hello1 ── simplest: one window, no .dat file ──────────────────────────────

compile_src "$TUTOR_HELLO/HELLO1.CPP" "$OBJ_DIR/hello1.obj"
link_exe hello1 "$OBJ_DIR/hello1.obj"

# ── hello2 ── help + error systems, uses hello.dat ───────────────────────────

compile_src "$TUTOR_HELLO/HELLO2.CPP" "$OBJ_DIR/hello2.obj" "-I$TUTOR_HELLO"
link_exe hello2 "$OBJ_DIR/hello2.obj"

# ── hello3 ── loads windows from hello.dat (Zinc Designer output) ─────────────

compile_src "$TUTOR_HELLO/HELLO3.CPP" "$OBJ_DIR/hello3.obj" "-I$TUTOR_HELLO"
link_exe hello3 "$OBJ_DIR/hello3.obj"

# ── copy runtime data files ───────────────────────────────────────────────────

printf "  Copying  hello.dat                        ... "
cp "$TUTOR_HELLO/HELLO.DAT" "$OUT_DIR/hello.dat"
echo "ok"

# ── summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Done. EXEs in $OUT_DIR/:"
ls -lh "$OUT_DIR/"
echo ""
echo "To test in DOSBox-X:"
echo "  dosbox-x -conf tutorials/hello/dosbox.conf"
echo ""
echo "  hello1.exe — minimal window (no .dat required)"
echo "  hello2.exe — help/error/exit systems (needs hello.dat)"
echo "  hello3.exe — loads windows from hello.dat"
