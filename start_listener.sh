#!/bin/bash
# =============================================================================
# start_listener.sh — Manually start the key detector in the background
#
# Use this if you want to start the listener without rebooting.
# It kills any existing key_detector.py instance first, then relaunches it
# and tails the log so you can see what's happening.
#
# Usage:
#   bash start_listener.sh
#
# To stop:
#   pkill -f key_detector.py
# =============================================================================

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LOG="$SCRIPT_DIR/key_detector.log"

# Kill any already running instance
pkill -f "key_detector.py" 2>/dev/null || true

# Determine Python binary to use (check if venv exists)
if [ -f "$SCRIPT_DIR/venv/bin/python3" ]; then
    PYTHON_BIN="$SCRIPT_DIR/venv/bin/python3"
else
    PYTHON_BIN="python3"
fi

# Check for debug flag
DEBUG_FLAG=""
if [ "$1" == "--debug" ]; then
    DEBUG_FLAG="--debug"
    echo "Starting in DEBUG mode..."
fi

echo "Starting key detector... (log: $LOG)"
nohup "$PYTHON_BIN" "$SCRIPT_DIR/key_detector.py" $DEBUG_FLAG >> "$LOG" 2>&1 &
echo "PID: $!"
echo ""
echo "Press the Option key THREE times to trigger StartWorking."
echo "To stop the listener: pkill -f key_detector.py"



