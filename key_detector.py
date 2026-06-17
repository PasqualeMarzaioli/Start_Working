#!/usr/bin/env python3
"""
key_detector.py — Listens to keyboard events and triggers StartWorking on triple Option-key press.

Description: Listens for Option key press sequences to trigger the workspace launcher script.
Author: Pasquale Marzaioli

How it works:
  1. Hooks into macOS global accessibility/keyboard events using pynput.
  2. Tracks the press/release states of the Option (Alt) key.
  3. Uses key-repeat protection to ignore repeating signals when the key is held down.
  4. Triggers launch_start_working.sh when the Option key is tapped 3 times in less than 1.0 second.
  5. A cooldown period prevents accidental re-triggers right after launch.

Requirements:
  pip install pynput
  macOS System Settings → Privacy & Security → Accessibility (must authorize Terminal/Python)
"""

import subprocess
import time
import sys
import os
import logging
import argparse

# Log to console with timestamps
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [key] %(message)s",
    datefmt="%H:%M:%S"
)

try:
    from pynput import keyboard
except ImportError:
    logging.error("Missing dependency. Run: pip install pynput")
    sys.exit(1)

# ---------------------------------------------------------------------------
# Key detection tuning
# ---------------------------------------------------------------------------
KEY_TAP_GAP      = 1.0   # maximum time allowed from the first to the third tap (seconds)
REQUIRED_TAPS    = 3     # number of taps required to trigger
COOLDOWN_SECONDS = 4.0   # wait time before StartWorking can fire again (seconds)

# Path to the launcher script (same directory as this file)
LAUNCHER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "launch_start_working.sh")

# ---------------------------------------------------------------------------
# State variables
# ---------------------------------------------------------------------------
tap_times         = []    # timestamps of the recent Option key presses
last_trigger_time = 0.0   # timestamp of the last StartWorking launch
pressed_keys      = set() # currently pressed keys (for key-repeat protection)
DEBUG_MODE        = False # enabled via --debug flag


def on_press(key):
    """Callback for key press events."""
    global tap_times, last_trigger_time, pressed_keys

    now = time.time()

    # Normalize key (pynput treats left/right Alt as different keys; we group them as Key.alt)
    if key in (keyboard.Key.alt, keyboard.Key.alt_l, keyboard.Key.alt_r):
        target_key = keyboard.Key.alt
    else:
        return

    # Check cooldown period
    if now - last_trigger_time < COOLDOWN_SECONDS:
        if DEBUG_MODE:
            logging.info("Ignored Option press: currently in cooldown.")
        return

    # Key-repeat protection: ignore autorepeat presses when held down
    if target_key in pressed_keys:
        return
    pressed_keys.add(target_key)

    if DEBUG_MODE:
        logging.info("Option key press detected")

    # Record the tap time
    tap_times.append(now)

    # Filter out taps that are older than the gap limit
    tap_times = [t for t in tap_times if now - t <= KEY_TAP_GAP]

    if len(tap_times) >= REQUIRED_TAPS:
        logging.info(f"{REQUIRED_TAPS} Option key taps detected within {KEY_TAP_GAP}s — launching StartWorking!")
        tap_times = []
        last_trigger_time = now
        subprocess.Popen(["bash", LAUNCHER])
    else:
        if DEBUG_MODE:
            logging.info(f"Taps in window: {len(tap_times)}/{REQUIRED_TAPS}")


def on_release(key):
    """Callback for key release events."""
    global pressed_keys

    # Normalize key
    if key in (keyboard.Key.alt, keyboard.Key.alt_l, keyboard.Key.alt_r):
        target_key = keyboard.Key.alt
    else:
        return

    if target_key in pressed_keys:
        pressed_keys.remove(target_key)
        if DEBUG_MODE:
            logging.info("Option key release detected")


def main():
    """Start the global keyboard listener."""
    global DEBUG_MODE
    parser = argparse.ArgumentParser(description="Listens for global key events and triggers StartWorking on triple Option-key press.")
    parser.add_argument("--debug", action="store_true", help="Enable verbose debug logging of key transitions")
    args = parser.parse_args()

    DEBUG_MODE = args.debug

    logging.info("Key detector started — tap the Option key 3 times rapidly to trigger StartWorking")
    if DEBUG_MODE:
        logging.info("Verbose debug logging enabled.")
    logging.info(f"Required: {REQUIRED_TAPS} taps | Window: {KEY_TAP_GAP}s | Cooldown: {COOLDOWN_SECONDS}s")

    try:
        # Start listener as a blocking call
        with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
            listener.join()
    except KeyboardInterrupt:
        logging.info("Stopped.")
    except Exception as e:
        logging.error(f"Error starting listener: {e}")
        logging.error("Ensure Terminal/Python has Accessibility permissions in System Settings.")
        sys.exit(1)


if __name__ == "__main__":
    main()
