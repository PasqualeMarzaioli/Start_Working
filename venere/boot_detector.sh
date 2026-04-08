#!/bin/bash
# =============================================================================
# boot_detector.sh — Starts the clap detector after system boot
#
# This script is intended to be called by the LaunchAgent plist
# (com.venere.clapdetector.plist) at login.
#
# It waits 20 seconds for the audio subsystem to be fully initialized
# before starting clap_detector.py, which prevents "no audio device" errors
# that occur when launching immediately at boot.
#
# To install the LaunchAgent so this runs automatically at login, see README.
# =============================================================================

# Set a clean environment (necessary when running from launchd)
export HOME="/Users/YOUR_USERNAME"      # [CUSTOMIZE] replace with your macOS username
export USER="YOUR_USERNAME"             # [CUSTOMIZE] replace with your macOS username
export PATH="/usr/local/bin:/usr/bin:/bin"

# Wait for the audio subsystem to be ready
sleep 20

# Start the clap detector (replace the path below with the absolute path to clap_detector.py)
exec /usr/bin/python3 /Users/YOUR_USERNAME/Desktop/AntiGravity/venere/clap_detector.py
