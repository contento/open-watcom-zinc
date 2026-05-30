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

!include $(PROJECT_ROOT)/scripts/common.mk

FONT_SRC = $(ZINC_HOME)/BIN/HELVB.FON
FONT_DST = HELVB.FON

all: $(ZINC_LIB) $(FONT_DST) $(TARGET) .symbolic

$(FONT_DST): $(FONT_SRC)
	cp "$(FONT_SRC)" "$(FONT_DST)"

main.obj: src/main.cpp
	$(CXX) $(CXXFLAGS) -fo=$@ src/main.cpp

clean: .symbolic
	rm -f *.obj *.err $(TARGET) HELVB.FON z_app.obj