# Open Watcom wmake - DOS/4GW 32-bit target
# Usage:
#   wmake           - debug build
#   wmake release   - optimised build
#   wmake clean     - remove generated files
#
# ZINC_HOME is resolved automatically from vendor/zinc if not set.

TARGET   = demo.exe

CXX      = wpp386
LINKER   = wlink

!ifndef ZINC_HOME
ZINC_HOME = vendor/zinc
!endif

ZINC_INC  = $(ZINC_HOME)/INCLUDE
ZINC_LIB  = $(ZINC_HOME)/LIB/OW2/D32_ZIL.LIB
OW_INC    = vendor/watcom/h
OW_LIB    = vendor/watcom/lib386
OW_LIBDOS = vendor/watcom/lib386/dos

!ifeq RELEASE 1
CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d0 -s -ox &
           -I"$(ZINC_INC)" -I"$(OW_INC)"
!else
CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d2 &
           -I"$(ZINC_INC)" -I"$(OW_INC)"
!endif

OBJS = main.obj

all: $(ZINC_LIB) $(TARGET) .symbolic

$(ZINC_LIB):
	sh scripts/build-zinc-ow2.sh

$(TARGET): $(OBJS)
	$(LINKER) system dos4g &
		name $(TARGET) &
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

release: .symbolic
	wmake RELEASE=1

clean: .symbolic
	rm -f *.obj *.err $(TARGET) HELVB.FON
