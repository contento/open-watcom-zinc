#!/bin/bash
# Script to build and launch the project in DOSBox-X

# Build first (sets WATCOM automatically)
sh build.sh || exit 1

# Launch
dosbox-x -conf dosbox-x.conf
