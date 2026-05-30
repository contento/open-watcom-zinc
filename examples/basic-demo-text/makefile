# Open Watcom wmake - DOS/4GW 32-bit target
# Basic Demo (text mode)
#
# Usage:
#   wmake           - debug build (text mode, safe on DOSBox-X)
#   wmake release   - optimised build
#   wmake clean     - remove generated files
#   wmake ZINC_DISPLAY=WCC  - VGA graphics (may crash DOSBox-X, needs HELVB.FON)

PROJECT_ROOT = ../..
TARGET = demo.exe
OBJS   = main.obj

!include $(PROJECT_ROOT)/scripts/common.mk

FONT_SRC = $(ZINC_HOME)/BIN/HELVB.FON
FONT_DST = HELVB.FON

all: $(ZINC_LIB) $(FONT_DST) $(TARGET) .symbolic

$(FONT_DST): $(FONT_SRC)
	cp "$(FONT_SRC)" "$(FONT_DST)"

main.obj: src/main.cpp
	$(CXX) $(CXXFLAGS) -fo=$@ src/main.cpp

clean: .symbolic
	rm -f *.obj *.err $(TARGET) $(FONT_DST) z_app.obj