#!/bin/sh
# Recompile the Open Zinc DOS/4GW library using Open Watcom 2.0.
# Required because OW 2.0 changed C++ name mangling (uppercase vs lowercase),
# making the pre-built OW19 library binary-incompatible.
#
# Run once from the project root: sh scripts/build-zinc-ow2.sh

set -e

ZINC_SRC=vendor/zinc/SOURCE
ZINC_INC=vendor/zinc/INCLUDE
OW_INC=vendor/watcom/h
OUT_DIR=vendor/zinc/LIB/OW2
OUT_LIB=$OUT_DIR/D32_ZIL.LIB
OBJ_DIR=/tmp/zinc_ow2_obj

# Same flags as ow19.mak D32 target, adapted for OW2 on Unix host
CFLAGS="-bt=dos4g -3 -mf -fp3 -dDOS386 -zq -w0 -I$ZINC_INC -I$OW_INC"

echo "Building Open Zinc DOS/4GW library for Open Watcom 2.0..."
echo "  Source : $ZINC_SRC"
echo "  Output : $OUT_LIB"
echo ""

mkdir -p "$OBJ_DIR" "$OUT_DIR"

# Compile every source file that was in the original D32_ZIL.LIB
SOURCES="
d_bnum d_border d_button d_combo d_cursor d_date
d_error d_error1 d_event d_fmtstr d_group d_hlist
d_icon d_image d_int d_intl d_keybrd d_max d_min
d_mouse d_notebk d_plldn d_plldn1 d_popup d_popup1
d_prompt d_real d_sbar d_scroll d_spin d_string d_sys
d_table d_table1 d_table2 d_tbar d_tdsp d_text d_time
d_title d_vlist d_win d_win1 d_win2
g_dsp g_event g_evt g_gen g_i18n g_jump g_lang g_lang1
g_loc g_loc1 g_mach g_pnorm g_win
i_file i_map i_str1 i_str2 i_str3 i_str4 i_str5 i_type i_wccat
z_bnum z_bnum1 z_bnum2 z_border z_button z_combo z_date z_date1
z_decor z_device z_dialog z_dsp z_error z_error1 z_event z_file
z_fmtstr z_gmgr z_gmgr1 z_gmgr2 z_gmgr3 z_group
z_help z_help1 z_hlist z_i18n z_icon z_image z_int z_intl
z_lang z_list z_list1 z_locale z_map1 z_map2 z_max z_min
z_msgwin z_notebk z_path z_plldn z_plldn1 z_popup z_popup1
z_printf z_prompt z_real z_region z_sbar z_scanf z_scroll z_spin
z_stdarg z_stored z_storer z_storew z_string z_sys
z_table z_table1 z_table2 z_tbar z_text z_time z_time1 z_timer
z_title z_utils z_utime z_utime1 z_vlist
z_win z_win1 z_win2 z_win3 z_win4
d_print d_wccdsp
"

OBJS=""
FAILED=0

for base in $SOURCES; do
    # source files are uppercase on disk
    src=$(echo "$ZINC_SRC/${base}.CPP")
    obj="$OBJ_DIR/${base}.obj"

    printf "  Compiling %-25s ... " "${base}.CPP"
    if wpp386 $CFLAGS -fo="$obj" "$src" 2>/tmp/zinc_compile_err; then
        echo "ok"
        OBJS="$OBJS +$obj"
    else
        echo "FAILED"
        cat /tmp/zinc_compile_err
        FAILED=$((FAILED + 1))
    fi
done

# z_app.CPP compiled with -dWCC: tries UI_WCC_DISPLAY first, falls back to
# UI_TEXT_DISPLAY automatically if the WCC display fails to initialize.
printf "  Compiling %-25s (WCC) ... " "z_app.CPP"
if wpp386 $CFLAGS -dWCC -fo="$OBJ_DIR/z_app.obj" "$ZINC_SRC/z_app.CPP" 2>/tmp/zinc_compile_err; then
    echo "ok"
else
    echo "FAILED"
    cat /tmp/zinc_compile_err
    FAILED=$((FAILED + 1))
fi

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "ERROR: $FAILED source files failed to compile. Library not created."
    exit 1
fi

echo ""
echo "Creating library $OUT_LIB ..."
rm -f "$OUT_LIB"
# wlib expects +obj args; pass them via response file to avoid arg length limits
RESP=/tmp/zinc_ow2.rsp
echo "$OUT_LIB" > "$RESP"
for obj in $OBJ_DIR/*.obj; do
    echo "+$obj" >> "$RESP"
done
wlib -p=64 -q "@$RESP"

echo "Done: $OUT_LIB"
