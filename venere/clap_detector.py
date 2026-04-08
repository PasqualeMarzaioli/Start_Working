#!/usr/bin/env python3
"""
clap_detector.py — Listens to the microphone and triggers Venere on a double clap.

How it works:
  1. Continuously reads audio from the default microphone in 30 ms chunks.
  2. Computes the RMS (Root Mean Square) of each chunk as a volume measure.
  3. If two loud peaks ("claps") occur within CLAP_MAX_GAP seconds, it fires
     launch_venere.sh in the background.
  4. A cooldown period prevents accidental re-triggers right after launch.

Trigger also works via voice command "esili" if you set up a Siri Shortcut
that calls launch_venere.sh (see README for instructions).

Requirements:
  pip install sounddevice numpy
"""

import subprocess
import time
import sys
import os
import logging

# Log to console with timestamps
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [clap] %(message)s",
    datefmt="%H:%M:%S"
)

try:
    import sounddevice as sd
    import numpy as np
except ImportError:
    print("Missing dependencies. Run: pip install sounddevice numpy")
    sys.exit(1)

# ---------------------------------------------------------------------------
# Audio configuration
# ---------------------------------------------------------------------------
SAMPLE_RATE    = 44100          # microphone sample rate in Hz
CHUNK_DURATION = 0.03           # duration of each audio chunk in seconds (30 ms)
CHUNK_SAMPLES  = int(SAMPLE_RATE * CHUNK_DURATION)

# ---------------------------------------------------------------------------
# Clap detection tuning
# ---------------------------------------------------------------------------
CLAP_THRESHOLD  = 0.10   # RMS threshold to count as a clap (0.0–1.0).
                          # Increase if too many false positives, decrease if claps are not detected.
CLAP_MIN_GAP    = 0.08   # minimum seconds between two claps (avoids counting echo/reverb as a second clap)
CLAP_MAX_GAP    = 1.2    # maximum seconds between two claps to count as a "double clap"
COOLDOWN_SECONDS = 4.0   # seconds to ignore audio after a trigger (prevents immediate re-launch)

# Path to the launcher script (same directory as this file)
LAUNCHER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "launch_venere.sh")

# ---------------------------------------------------------------------------
# State variables
# ---------------------------------------------------------------------------
last_clap_time    = 0.0  # timestamp of the last detected clap
last_trigger_time = 0.0  # timestamp of the last Venere launch
clap_count        = 0    # how many claps have been detected in the current sequence

# Debug log file — logs every audio peak above 0.01 RMS
DEBUG_LOG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "clap_debug.log")


def on_audio_chunk(indata, frames, time_info, status):
    """Callback called by sounddevice for every audio chunk."""
    global last_clap_time, last_trigger_time, clap_count

    now = time.time()

    # Compute RMS energy of the current chunk
    rms = float(np.sqrt(np.mean(indata ** 2)))

    # Write any noticeable sound to the debug log (useful for threshold tuning)
    if rms > 0.01:
        with open(DEBUG_LOG, "a") as f:
            f.write(f"{time.strftime('%H:%M:%S')}.{int(now*1000)%1000:03d} RMS={rms:.4f}\n")

    # Skip detection during cooldown period
    if now - last_trigger_time < COOLDOWN_SECONDS:
        return

    if rms > CLAP_THRESHOLD:
        gap = now - last_clap_time

        if gap < CLAP_MIN_GAP:
            # Too close to the previous peak — likely the tail/echo of the same clap
            return

        if gap <= CLAP_MAX_GAP and clap_count >= 1:
            # Second clap detected within the valid window → trigger Venere
            clap_count = 0
            last_trigger_time = now
            logging.info("Double clap detected — launching Venere")
            subprocess.Popen(["bash", LAUNCHER])
        else:
            # First clap (or gap too long — restart the sequence)
            clap_count = 1
            last_clap_time = now
            logging.info(f"Clap 1 detected (rms={rms:.3f})")


def main():
    """
    Start the audio input stream.
    Retries automatically if the audio device is not ready yet (e.g. at boot).
    """
    for attempt in range(1, 20):
        try:
            logging.info(f"Clap detector started (attempt {attempt}) — clap TWICE to trigger Venere")
            logging.info(f"Threshold: {CLAP_THRESHOLD} | Window: {CLAP_MAX_GAP}s | Cooldown: {COOLDOWN_SECONDS}s")
            with sd.InputStream(
                samplerate=SAMPLE_RATE,
                channels=1,
                blocksize=CHUNK_SAMPLES,
                callback=on_audio_chunk,
                dtype="float32"
            ):
                while True:
                    time.sleep(0.1)
        except KeyboardInterrupt:
            logging.info("Stopped.")
            return
        except Exception as e:
            logging.warning(f"Audio error: {e} — retrying in 10s")
            time.sleep(10)


if __name__ == "__main__":
    main()
