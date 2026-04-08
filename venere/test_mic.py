#!/usr/bin/env python3
"""
test_mic.py — Real-time microphone RMS monitor.

Use this script to calibrate the CLAP_THRESHOLD value in clap_detector.py.

How to use:
  1. Run this script: python3 venere/test_mic.py
  2. Stay quiet — note the baseline RMS (should be near 0.00–0.01)
  3. Clap your hands — note the peak RMS value
  4. Set CLAP_THRESHOLD in clap_detector.py to a value between the baseline and the clap peak
     (e.g. if baseline ≈ 0.005 and clap ≈ 0.30, try CLAP_THRESHOLD = 0.10)
  5. Press Ctrl+C to stop

Requirements:
  pip install sounddevice numpy
"""

import sounddevice as sd
import numpy as np
import time

SAMPLE_RATE = 44100
CHUNK = int(SAMPLE_RATE * 0.03)  # 30 ms chunks, same as clap_detector.py


def callback(indata, frames, t, status):
    rms = float(np.sqrt(np.mean(indata ** 2)))
    if rms > 0.01:
        # Visual bar: each '#' represents 0.01 RMS units
        bar = "#" * int(rms * 100)
        print(f"RMS: {rms:.4f}  {bar}")


print("Speak or clap — press Ctrl+C to stop")
with sd.InputStream(samplerate=SAMPLE_RATE, channels=1, blocksize=CHUNK, callback=callback, dtype="float32"):
    while True:
        time.sleep(0.1)
