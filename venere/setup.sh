#!/bin/bash
# =============================================================================
# setup.sh — One-time setup script for Venere
#
# Run this once after cloning the repository:
#   bash venere/setup.sh
#
# What it does:
#   1. Installs the required Python packages (sounddevice, numpy)
#   2. Makes all shell scripts and the clap detector executable
#   3. Prints usage instructions
# =============================================================================

set -e

echo "=== Venere Setup ==="

# Install required Python dependencies
echo "→ Installing sounddevice and numpy..."
pip3 install sounddevice numpy

# Make scripts executable
chmod +x "$(dirname "$0")/launch_venere.sh"
chmod +x "$(dirname "$0")/clap_detector.py"
chmod +x "$(dirname "$0")/start_listener.sh"
chmod +x "$(dirname "$0")/boot_detector.sh"

echo ""
echo "=== SETUP COMPLETE ==="
echo ""
echo "How to use Venere:"
echo ""
echo "  1. MANUAL TRIGGER:"
echo "     bash venere/launch_venere.sh"
echo ""
echo "  2. DOUBLE-CLAP TRIGGER (start listener):"
echo "     bash venere/start_listener.sh"
echo "     → Then clap your hands TWICE"
echo ""
echo "  3. VOICE TRIGGER 'esili' (via Siri Shortcut):"
echo "     → Open the Shortcuts app"
echo "     → Create a new shortcut named 'esili'"
echo "     → Add action: Run Shell Script"
echo "     → Shell: /bin/bash | Script: bash $(realpath "$(dirname "$0")/launch_venere.sh")"
echo "     → Save. Now say 'Hey Siri, esili'"
echo ""
echo "  4. AUTO-START AT LOGIN (LaunchAgent):"
echo "     → See README.md for step-by-step instructions"
echo ""
echo "  SPOTIFY TIP: if your track doesn't play correctly,"
echo "  open Spotify → right-click the song → Share → Copy Spotify URI"
echo "  and paste it into launch_venere.sh (the 'play track' line)"
