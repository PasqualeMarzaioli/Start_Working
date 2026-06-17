#!/bin/bash
# =============================================================================
# setup.sh — One-time setup script for StartWorking
#
# Description: Installs project dependencies, updates file execution permissions, and dynamically configures file paths inside the templates.
# Author: Pasquale Marzaioli
#
# Run this once after cloning the repository:
#   bash setup.sh
#
# What it does:
#   1. Installs the required Python packages (pynput)
#   2. Makes all shell scripts and the key detector executable
#   3. Prints usage instructions
# =============================================================================

set -e

echo "=== StartWorking Setup ==="

# Get the absolute directory where setup.sh is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install required Python dependencies (using venv pip if it exists)
echo "→ Installing pynput..."
if [ -f "$SCRIPT_DIR/venv/bin/pip" ]; then
    "$SCRIPT_DIR/venv/bin/pip" install pynput
else
    pip3 install pynput
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR/launch_start_working.sh"
chmod +x "$SCRIPT_DIR/key_detector.py"
chmod +x "$SCRIPT_DIR/start_listener.sh"
chmod +x "$SCRIPT_DIR/boot_detector.sh"

# Create logs directory
mkdir -p "$HOME/Library/Logs/StartWorking"

echo "→ Configuring paths and username dynamically..."

# Run Python post-installation config
python3 -c "
import os
import sys
import getpass

script_dir = os.path.dirname(os.path.abspath('$0')) if '$0' else os.getcwd()
if not script_dir or script_dir == '.':
    script_dir = os.getcwd()

# Get username dynamically
username = getpass.getuser()

# Determine Python binary
venv_python = os.path.join(script_dir, 'venv', 'bin', 'python3')
python_bin = venv_python if os.path.exists(venv_python) else '/usr/bin/python3'

# 1. Update boot_detector.sh
boot_path = os.path.join(script_dir, 'boot_detector.sh')
if os.path.exists(boot_path):
    with open(boot_path, 'r') as f:
        content = f.read()
    new_content = content.replace('YOUR_PROJECT_DIR', script_dir)
    new_content = new_content.replace('YOUR_USERNAME', username)
    with open(boot_path, 'w') as f:
        f.write(new_content)
    print(f'  - Configured boot_detector.sh with path: {script_dir} and user: {username}')

# 2. Update com.startworking.keydetector.plist
plist_path = os.path.join(script_dir, 'com.startworking.keydetector.plist')
if os.path.exists(plist_path):
    with open(plist_path, 'r') as f:
        content = f.read()
    new_content = content.replace('YOUR_PROJECT_DIR', script_dir)
    new_content = new_content.replace('YOUR_PYTHON_BIN', python_bin)
    new_content = new_content.replace('YOUR_USERNAME', username)
    with open(plist_path, 'w') as f:
        f.write(new_content)
    print(f'  - Configured com.startworking.keydetector.plist with path: {script_dir} and python: {python_bin}')
"

echo ""
echo "=== SETUP COMPLETE ==="
echo ""
echo "How to use StartWorking:"
echo ""
echo "  1. MANUAL TRIGGER:"
echo "     bash launch_start_working.sh"
echo ""
echo "  2. OPTION KEY TRIGGER (start listener):"
echo "     bash start_listener.sh"
echo "     → Then press the Option (Alt) key THREE times"
echo ""
echo "  3. VOICE TRIGGER 'Start StartWorking' (via Siri Shortcut):"
echo "     → Open the Shortcuts app"
echo "     → Create a new shortcut named 'Start StartWorking'"
echo "     → Add action: Run Shell Script"
echo "     → Shell: /bin/bash | Script: bash $(realpath "$SCRIPT_DIR/launch_start_working.sh")"
echo "     → Save. Now say 'Hey Siri, start StartWorking'"
echo ""
echo "  4. AUTO-START AT LOGIN (LaunchAgent):"
echo "     → See README.md for step-by-step instructions"
echo ""
echo "  SPOTIFY TIP: if your track doesn't play correctly,"
echo "  open Spotify → right-click the song → Share → Copy Spotify URI"
echo "  and paste it into launch_start_working.sh (the 'play track' line)"


