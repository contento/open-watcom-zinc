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
		alias _getvideoconfig_ = _getvideoconfig &
		alias _setvideomode_ = _setvideomode &
		alias _setvideomoderows_ = _setvideomoderows &
		alias _gettextcursor_ = _gettextcursor &
		alias _settextcursor_ = _settextcursor &
		alias _settextposition_ = _settextposition &
		alias _clearscreen_ = _clearscreen &
		alias memset = memset_ &
		alias _ExtenderRealModeSelector = __ExtenderRealModeSelector &
		alias _Extender = __Extender &
		alias _DPMI = __DPMI &
		alias _STACKLOW = __STACKLOW &
		alias dos_get_dbcs_lead_table = dos_get_dbcs_lead_table_ &
		libpath "$(OW_LIB)" &
		libpath "$(OW_LIBDOS)"

main.obj: src/main.cpp
	$(CXX) $(CXXFLAGS) -fo=$@ src/main.cpp

release: .symbolic
	wmake RELEASE=1

clean: .symbolic
	@if exist *.obj del *.obj
	@if exist *.err del *.err
	@if exist $(TARGET) del $(TARGET)
