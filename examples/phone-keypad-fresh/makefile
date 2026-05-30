# Open Watcom wmake - DOS/4GW 32-bit target
# Phone Keypad example (fresh)
#
# Usage:
#   wmake           - debug build (text mode, safe on DOSBox-X)
#   wmake release   - optimised build
#   wmake clean     - remove generated files
#   wmake ZINC_DISPLAY=WCC  - VGA graphics (may crash DOSBox-X, needs HELVB.FON)

PROJECT_ROOT = ../..
TARGET = keypad.exe
OBJS   = main.obj

!include $(PROJECT_ROOT)/scripts/common.mk

main.obj: src/main.cpp
	$(CXX) $(CXXFLAGS) -fo=$@ src/main.cpp

clean: .symbolic
	rm -f *.obj *.err $(TARGET) z_app.obj