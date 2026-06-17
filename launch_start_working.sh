#!/bin/bash
# =============================================================================
# launch_start_working.sh — Main StartWorking launcher script
#
# Description: Automates starting the work environment by launching specific apps, browser tabs, music, and playing a voice alert.
# Author: Pasquale Marzaioli
#
# Triggered by:
#   - A triple Option-key press (via key_detector.py)
#   - A voice command "Start StartWorking" (via Siri Shortcut — see README)
#   - Running this script directly: bash launch_start_working.sh
#
# What it does:
#   1. Opens Visual Studio Code
#   2. Opens MATLAB (optional)
#   3. Plays a Spotify track via AppleScript
#   4. Opens Safari tabs: Overleaf and Gemini
#   5. Waits for everything to load, then plays the voice announcement
#
# CUSTOMIZATION: edit the sections below to open your own apps/URLs/songs.
# =============================================================================

# ---------------------------------------------------------------------------
# [CUSTOMIZE] Path to your StartWorking project folder
# ---------------------------------------------------------------------------
START_WORKING_DIR="$(dirname "$(realpath "$0")")"


# ---------------------------------------------------------------------------
# [CUSTOMIZE] Apps to open
# Remove or replace lines with your own apps.
# Usage: open -a "App Name"
# ---------------------------------------------------------------------------

# Open the Visual Studio Code native app (if installed)
open -a "Visual Studio Code"

# Open MATLAB (change version string to match your installation)
# open -a "MATLAB_R2025b"

# ---------------------------------------------------------------------------
# [CUSTOMIZE] Spotify — play a specific track or playlist
#
# To find your Spotify URI:
#   1. Open Spotify
#   2. Right-click on a song/playlist → Share → Copy Spotify URI
#      (looks like: spotify:track:4bSFUiGlGQqPD0B8xGMHi8)
#   3. Replace the URI string below with yours
#
# To play a playlist instead of a single track, use:
#   play track "spotify:playlist:XXXXXXXXXXXXXXXXXXXXXXXX"
# ---------------------------------------------------------------------------
osascript <<'EOF'
tell application "Spotify"
    activate
    delay 1.5
    play track "spotify:track:5fdNHVZHbWB1AaXk4RBGVD"
end tell
EOF

# ---------------------------------------------------------------------------
# [CUSTOMIZE] Websites to open in Safari
# Add or remove `open -a Safari "URL"` lines as needed.
# ---------------------------------------------------------------------------
open -a Safari "https://www.overleaf.com"
open -a Safari "https://gemini.google.com"

# ---------------------------------------------------------------------------
# Wait for all apps and pages to fully load, then play the voice announcement
# Increase the value (in seconds) if some apps are slow to start on your Mac
# ---------------------------------------------------------------------------
sleep 15
# Run announcement using the virtual environment python if available
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
if [ -f "$SCRIPT_DIR/venv/bin/python3" ]; then
    "$SCRIPT_DIR/venv/bin/python3" "$SCRIPT_DIR/announce.py"
else
    /usr/bin/python3 "$SCRIPT_DIR/announce.py"
fi
