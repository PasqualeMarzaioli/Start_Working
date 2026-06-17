#!/usr/bin/env python3
"""
announce.py — Voice announcement played when StartWorking is launched.

Uses macOS built-in TTS voice:
  - "Samantha (Enhanced)" (English) says "you can start working now"

Requirements: macOS only (uses `say` and `afplay` system commands)
"""

import subprocess
import os
import tempfile

# Temporary directory for audio file
TMP = tempfile.gettempdir()
OUT = os.path.join(TMP, "startworking_announcement.wav")

# Audio format: 16-bit little-endian, 22050 Hz
FMT = "LEI16@22050"

# Generate the voice clip using macOS `say`
subprocess.run(["say", "-v", "Samantha (Enhanced)", "you can start working now", "--data-format", FMT, "-o", OUT], check=True)

# Play the announcement
subprocess.run(["afplay", OUT])

