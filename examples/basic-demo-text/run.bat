@ECHO OFF
REM Run script for DOSBox-X — executes the demo from C:\
REM DOS/4GW is embedded in the EXE stub; no separate DOS4GW.EXE needed.

IF NOT EXIST DEMO.EXE (
    ECHO ERROR: DEMO.EXE not found. Build first with wmake on the host.
    PAUSE
    GOTO END
)

ECHO Starting Open Zinc demo (DOS/4GW 32-bit - text mode)...
DEMO.EXE

:END
