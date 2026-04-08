#!/bin/bash
# =============================================================================
# launch_venere.sh — Main Venere launcher script
#
# Triggered by:
#   - A double clap (via clap_detector.py)
#   - A voice command "esili" (via Siri Shortcut — see README)
#   - Running this script directly: bash venere/launch_venere.sh
#
# What it does:
#   1. Opens the AntiGravity app
#   2. Opens MATLAB
#   3. Plays a Spotify track via AppleScript
#   4. Opens Safari tabs: Overleaf and Gemini
#   5. Waits for everything to load, then plays the voice announcement
#
# CUSTOMIZATION: edit the sections below to open your own apps/URLs/songs.
# =============================================================================

# ---------------------------------------------------------------------------
# [CUSTOMIZE] Path to your AntiGravity project folder
# ---------------------------------------------------------------------------
ANTIGRAVITY_DIR="$HOME/Desktop/AntiGravity"

# ---------------------------------------------------------------------------
# [CUSTOMIZE] Apps to open
# Remove or replace lines with your own apps.
# Usage: open -a "App Name"
# ---------------------------------------------------------------------------

# Open the AntiGravity native app (if installed)
open /Applications/Antigravity.app

# Open MATLAB (change version string to match your installation)
open -a "MATLAB_R2025b"

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
/usr/bin/python3 "$(dirname "$0")/announce.py"
