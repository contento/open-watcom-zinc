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
#                   "WCC"  (VGA graphics, may crash DOSBox-X, works on real HW)
#   ZINC_HOME     - override default $(PROJECT_ROOT)/vendor/zinc
#
# Targets provided:  all, release, clean, z_app.obj, $(TARGET)

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
!ifeq ZINC_DISPLAY TEXT
ZAPP_FLAGS = -dZIL_TEXT_ONLY
!else
ZAPP_FLAGS = -dWCC
!endif

ZAPP_OBJ = z_app.obj

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
		lib "$(OW_LIBDOS)/clib3r.lib" &
		libpath "$(OW_LIB)" &
		libpath "$(OW_LIBDOS)"

release: .symbolic
	wmake RELEASE=1

clean: .symbolic
	rm -f *.obj *.err $(TARGET)