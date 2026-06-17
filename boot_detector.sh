#!/bin/bash
# =============================================================================
# boot_detector.sh — Starts the key detector after system boot
#
# Description: Delays and starts the key detector listener after system login.
# Author: Pasquale Marzaioli
#
# This script is intended to be called by the LaunchAgent plist
# (com.startworking.keydetector.plist) at login.
#
# It waits 20 seconds for the system to be fully initialized
# before starting key_detector.py.
#
# To install the LaunchAgent so this runs automatically at login, see README.
# =============================================================================

# Set a clean environment (necessary when running from launchd)
export HOME="/Users/pasquale_marzaioli"      # [CUSTOMIZE] replace with your macOS username
export USER="pasquale_marzaioli"             # [CUSTOMIZE] replace with your macOS username
export PATH="/usr/local/bin:/usr/bin:/bin"

# Wait for the system to be ready
sleep 20

# Start the key detector
SCRIPT_DIR="/Users/pasquale_marzaioli/Desktop/Coding/start_working"
if [ -f "$SCRIPT_DIR/venv/bin/python3" ]; then
    PYTHON_BIN="$SCRIPT_DIR/venv/bin/python3"
else
    PYTHON_BIN="/usr/bin/python3"
fi

exec "$PYTHON_BIN" "$SCRIPT_DIR/key_detector.py"
