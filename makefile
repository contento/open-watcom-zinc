# Open Watcom wmake — DOS/4GW 32-bit target
# Usage:
#   wmake           — debug build
#   wmake release   — optimised build
#   wmake clean     — remove generated files
#
# Required environment variables:
#   WATCOM    — Open Watcom install root  (e.g. /opt/watcom)
#   ZINC_HOME — Open Zinc root with include/ and lib/ subdirs

TARGET   = demo.exe

CXX      = wpp386
LINKER   = wlink

ZINC_INC = $(ZINC_HOME)\include
ZINC_LIB = $(ZINC_HOME)\lib\zinc32d.lib

# Debug flags (default)
CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d2 &
           -I"$(ZINC_INC)"

# Object files
OBJS     = main.obj

# -----------------------------------------------------------------------
all: $(TARGET) .symbolic

$(TARGET): $(OBJS)
    $(LINKER) system dos4g &
        name $(TARGET) &
        file {$(OBJS)} &
        lib "$(ZINC_LIB)"

main.obj: src\main.cpp
    $(CXX) $(CXXFLAGS) -fo=$@ src\main.cpp

# -----------------------------------------------------------------------
release: CXXFLAGS = -bt=dos4g -3 -mf -fp3 -w4 -d0 -s -ox
release: $(TARGET) .symbolic

# -----------------------------------------------------------------------
clean: .symbolic
    @if exist *.obj del *.obj
    @if exist *.err del *.err
    @if exist $(TARGET) del $(TARGET)
