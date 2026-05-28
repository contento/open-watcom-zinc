#!/bin/bash
# Build wrapper that sets WATCOM if not already set

if [ -z "$WATCOM" ]; then
    # Auto-detect WATCOM from vendor directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    export WATCOM="$SCRIPT_DIR/../../vendor/watcom"
    echo "Setting WATCOM=$WATCOM"
fi

wmake "$@"
