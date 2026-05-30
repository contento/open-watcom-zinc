# ── Open Watcom + Open Zinc shared makefile fragment ──────────────────────────
# Include from an example makefile:
#   PROJECT_ROOT = ../..
#   !include $(PROJECT_ROOT)/scripts/common.mk
#
# Variables your makefile must define before including:
#   PROJECT_ROOT  - relative path to project root (e.g. ../.. or .)
#   TARGET        - executable name (e.g. demo.exe)
#   OBJS          - object files (e.g. main.obj)
#
# Optional variables:
#   ZINC_DISPLAY  - "TEXT" (default, safe on DOSBox-X + real DOS)
#                   "WCC"  (VGA graphics, may crash DOSBox-X, needs HELVB.FON)
#   ZINC_HOME     - override default $(PROJECT_ROOT)/vendor/zinc

!ifndef PROJECT_ROOT
!error PROJECT_ROOT must be set before including common.mk
!endif

!ifndef ZINC_HOME
ZINC_HOME = $(PROJECT_ROOT)/vendor/zinc
!endif

!ifndef ZINC_DISPLAY
ZINC_DISPLAY = TEXT
!endif

# ── paths ──────────────────────────────────────────────────────────────────────
ZINC_INC  = $(ZINC_HOME)/INCLUDE
ZINC_LIB  = $(ZINC_HOME)/LIB/OW2/D32_ZIL.LIB
OW_INC    = $(PROJECT_ROOT)/vendor/watcom/h
OW_LIB    = $(PROJECT_ROOT)/vendor/watcom/lib386
OW_LIBDOS = $(PROJECT_ROOT)/vendor/watcom/lib386/dos
BUILD_ZINC_SH = $(PROJECT_ROOT)/scripts/build-zinc-ow2.sh

CXX      = wpp386
LINKER   = wlink

# ── compiler flags ─────────────────────────────────────────────────────────────
!ifeq RELEASE 1
CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d0 -s -ox &
           -I"$(ZINC_INC)" -I"$(OW_INC)"
!else
CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d2 &
           -I"$(ZINC_INC)" -I"$(OW_INC)"
!endif

# ── display mode ───────────────────────────────────────────────────────────────
# Compile z_app.CPP with the chosen display mode and link it before the library
# so the linker resolves UI_APPLICATION from the override, not the WCC default.
!ifeq ZINC_DISPLAY TEXT
ZAPP_FLAGS = -dZIL_TEXT_ONLY
!else
ZAPP_FLAGS = -dWCC
!endif

ZAPP_OBJ = z_app.obj

# ── wlink OW1→OW2 symbol aliases for graph.lib ────────────────────────────────
# graph.lib was compiled with OW 1.9 which uses _name (no trailing underscore).
# OW 2.0 exports _name_, so we alias all graph function references.
GRAPH_ALIASES = &
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
		alias _setvideomoderows_ = _setvideomoderows &
		alias _settextposition_ = _settextposition &
		alias malloc            = malloc_ &
		alias memset            = memset_ &
		alias free              = free_ &
		alias _ExtenderRealModeSelector = __ExtenderRealModeSelector &
		alias _Extender         = __Extender &
		alias _DPMI             = __DPMI &
		alias _STACKLOW         = __STACKLOW &
		alias dos_get_dbcs_lead_table = dos_get_dbcs_lead_table_

# ── targets ────────────────────────────────────────────────────────────────────
all: $(ZINC_LIB) $(TARGET) .symbolic

$(ZINC_LIB):
	sh $(BUILD_ZINC_SH)

$(ZAPP_OBJ): $(ZINC_HOME)/SOURCE/z_app.CPP
	$(CXX) $(CXXFLAGS) $(ZAPP_FLAGS) -fo=$@ $(ZINC_HOME)/SOURCE/z_app.CPP

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
		$(GRAPH_ALIASES)