# Open Watcom wmake - DOS/4GW 32-bit target
# Phone Keypad example
#
# Usage:
#   wmake           - debug build
#   wmake release   - optimised build
#   wmake clean     - remove generated files
#
# ZINC_HOME is resolved automatically from ../../vendor/zinc if not set.

TARGET   = keypad.exe

CXX      = wpp386
LINKER   = wlink

!ifndef ZINC_HOME
ZINC_HOME = ../../vendor/zinc
!endif

ZINC_INC  = $(ZINC_HOME)/INCLUDE
ZINC_LIB  = $(ZINC_HOME)/LIB/OW2/D32_ZIL.LIB
OW_INC    = ../../vendor/watcom/h
OW_LIB    = ../../vendor/watcom/lib386
OW_LIBDOS = ../../vendor/watcom/lib386/dos

!ifeq RELEASE 1
CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d0 -s -ox &
           -I"$(ZINC_INC)" -I"$(OW_INC)"
!else
CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d2 &
           -I"$(ZINC_INC)" -I"$(OW_INC)"
!endif

OBJS = main.obj
ZINC_APP_OBJ = z_app_txt.obj

all: $(ZINC_LIB) $(TARGET) .symbolic

$(ZINC_LIB):
	sh ../../scripts/build-zinc-ow2.sh

$(ZINC_APP_OBJ): ../../vendor/zinc/SOURCE/z_app.CPP
	$(CXX) $(CXXFLAGS) -dZIL_TEXT_ONLY -fo=$@ ../../vendor/zinc/SOURCE/z_app.CPP

$(TARGET): $(OBJS) $(ZINC_APP_OBJ)
	$(LINKER) system dos4g &
		name $(TARGET) &
		file $(ZINC_APP_OBJ) &
		file {$(OBJS)} &
		lib "$(ZINC_LIB)" &
		lib "$(OW_LIBDOS)/clib3r.lib" &
		libpath "$(OW_LIB)" &
		libpath "$(OW_LIBDOS)"

main.obj: main.cpp
	$(CXX) $(CXXFLAGS) -fo=$@ main.cpp

release: .symbolic
	wmake RELEASE=1

clean: .symbolic
	rm -f *.obj *.err $(TARGET) $(ZINC_APP_OBJ)
