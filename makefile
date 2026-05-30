# Open Watcom wmake - DOS/4GW 32-bit target
# Root demo (WCC graphics mode — VGA graphics, may crash DOSBox-X)
#
# Usage:
#   wmake                        - debug build (WCC mode, needs HELVB.FON)
#   wmake ZINC_DISPLAY=TEXT      - text mode (safe on DOSBox-X)
#   wmake release                - optimised build
#   wmake clean                  - remove generated files

PROJECT_ROOT = .
TARGET = demo.exe
OBJS   = main.obj
ZINC_DISPLAY = WCC

!include $(PROJECT_ROOT)/scripts/common.mk

FONT_SRC = $(ZINC_HOME)/BIN/HELVB.FON
FONT_DST = HELVB.FON

all: $(ZINC_LIB) $(FONT_DST) $(TARGET) .symbolic

$(FONT_DST): $(FONT_SRC)
	cp "$(FONT_SRC)" "$(FONT_DST)"

$(TARGET): $(OBJS) $(ZAPP_OBJ)
	$(LINKER) system dos4g &
		name $(TARGET) &
		file $(ZAPP_OBJ) &
		file {$(OBJS)} &
		lib "$(ZINC_LIB)" &
		lib "$(OW_LIBDOS)/graph.lib" &
		lib "$(OW_LIBDOS)/clib3r.lib" &
		libpath "$(OW_LIB)" &
		libpath "$(OW_LIBDOS)" &
		alias _registerfonts_   = _registerfonts &
		alias _getvideoconfig_  = _getvideoconfig &
		alias _gettextcursor_   = _gettextcursor &
		alias _setvideomode_    = _setvideomode &
		alias _remappalette_    = _remappalette &
		alias _settextcursor_   = _settextcursor &
		alias _clearscreen_     = _clearscreen &
		alias _setviewport_     = _setviewport &
		alias _setcolor_        = _setcolor &
		alias _setpixel_        = _setpixel &
		alias _setfillmask_     = _setfillmask &
		alias _ellipse_         = _ellipse &
		alias _pie_             = _pie &
		alias _getpixel_        = _getpixel &
		alias _moveto_          = _moveto &
		alias _lineto_          = _lineto &
		alias _polygon_         = _polygon &
		alias _rectangle_       = _rectangle &
		alias _setlinestyle_    = _setlinestyle &
		alias _imagesize_       = _imagesize &
		alias _getimage_        = _getimage &
		alias _putimage_        = _putimage &
		alias _outgtext_        = _outgtext &
		alias _setfont_         = _setfont &
		alias _setplotaction_   = _setplotaction &
		alias _getfontinfo_     = _getfontinfo &
		alias _getgtextextent_  = _getgtextextent &
		alias malloc            = malloc_ &
		alias memset            = memset_ &
		alias free              = free_ &
		alias _ExtenderRealModeSelector = __ExtenderRealModeSelector &
		alias _Extender         = __Extender &
		alias _DPMI             = __DPMI &
		alias _STACKLOW         = __STACKLOW &
		alias dos_get_dbcs_lead_table = dos_get_dbcs_lead_table_

main.obj: src/main.cpp
	$(CXX) $(CXXFLAGS) -fo=$@ src/main.cpp

clean: .symbolic
	rm -f *.obj *.err $(TARGET) HELVB.FON