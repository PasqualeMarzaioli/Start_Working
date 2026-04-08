#!/bin/bash
# =============================================================================
# start_listener.sh — Manually start the clap detector in the background
#
# Use this if you want to start the listener without rebooting.
# It kills any existing clap_detector.py instance first, then relaunches it
# and tails the log so you can see what's happening.
#
# Usage:
#   bash venere/start_listener.sh
#
# To stop:
#   pkill -f clap_detector.py
# =============================================================================

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LOG="$SCRIPT_DIR/clap_detector.log"

# Kill any already running instance
pkill -f "clap_detector.py" 2>/dev/null || true

echo "Starting clap detector... (log: $LOG)"
nohup python3 "$SCRIPT_DIR/clap_detector.py" >> "$LOG" 2>&1 &
echo "PID: $!"
echo ""
echo "Clap TWICE to trigger Venere."
echo "To stop the listener: pkill -f clap_detector.py"
