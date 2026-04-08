#!/usr/bin/env python3
"""
announce.py — Voice announcement played when Venere is launched.

Uses macOS built-in TTS voices:
  - "Alice" (Italian) says "Venere"
  - "Samantha Enhanced" (English) says "has been launched"
Both audio clips are concatenated into a single WAV file and played back.

Requirements: macOS only (uses `say` and `afplay` system commands)
"""

import subprocess
import wave
import os
import tempfile

# Temporary directory for audio files
TMP = tempfile.gettempdir()
P1  = os.path.join(TMP, "venere_p1.wav")   # first clip: "Venere" in Italian
P2  = os.path.join(TMP, "venere_p2.wav")   # second clip: "has been launched" in English
OUT = os.path.join(TMP, "venere_full.wav") # merged output

# Audio format: 16-bit little-endian, 22050 Hz
FMT = "LEI16@22050"

# Generate the two voice clips using macOS `say`
subprocess.run(["say", "-v", "Alice",               "Venere",             "--data-format", FMT, "-o", P1], check=True)
subprocess.run(["say", "-v", "Samantha (Enhanced)", "has been launched",  "--data-format", FMT, "-o", P2], check=True)

# Merge the two WAV files into a single file
with wave.open(P1) as w1, wave.open(P2) as w2:
    with wave.open(OUT, "w") as out:
        out.setparams(w1.getparams())
        out.writeframes(w1.readframes(w1.getnframes()))
        out.writeframes(w2.readframes(w2.getnframes()))

# Play the merged announcement
subprocess.run(["afplay", OUT])
