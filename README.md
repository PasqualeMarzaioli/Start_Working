# Venere — Smart Context Launcher for macOS

**Venere** is a macOS automation system that launches your entire work environment in one action.

Trigger it by:
- **Clapping your hands twice** (always-on microphone listener)
- **Saying a voice command** via Siri Shortcut (e.g. "esili")
- **Running the script directly** from Terminal

When triggered, Venere opens all your apps, plays your Spotify track, opens your websites, and announces itself with a custom voice message.

---

## What it opens (default configuration)

| Step | What |
|------|------|
| 1 | AntiGravity.app |
| 2 | MATLAB |
| 3 | Spotify — plays a specific track via URI |
| 4 | Safari — opens Overleaf and Gemini |
| 5 | Voice announcement: *"Venere has been launched"* |

Everything in `launch_venere.sh` is clearly marked `[CUSTOMIZE]` — change it to open whatever you want.

---

## Requirements

- **macOS** (tested on macOS Sequoia / Sonoma)
- **Python 3.9+** (comes with macOS or via [python.org](https://www.python.org))
- **pip** (comes with Python)
- **Spotify desktop app** (only if you want Spotify integration)

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/AntiGravity.git
cd AntiGravity
```

### 2. Run the setup script

```bash
bash venere/setup.sh
```

This installs `sounddevice` and `numpy`, and makes all scripts executable.

### 3. Grant microphone access

The first time `clap_detector.py` runs, macOS will ask for microphone permission.
Go to **System Settings → Privacy & Security → Microphone** and allow Terminal (or your Python binary).

### 4. Customize `launch_venere.sh`

Open [venere/launch_venere.sh](venere/launch_venere.sh) and edit the `[CUSTOMIZE]` sections:

#### Change the apps to open

```bash
# Open any app by name:
open -a "App Name"

# Examples:
open -a "Visual Studio Code"
open -a "Xcode"
open -a "Notion"
```

#### Change the Spotify track or playlist

1. Open Spotify
2. Right-click on any song or playlist → **Share** → **Copy Spotify URI**
   - Track URI looks like: `spotify:track:4bSFUiGlGQqPD0B8xGMHi8`
   - Playlist URI looks like: `spotify:playlist:37i9dQZF1DXcBWIGoYBM5M`
3. Paste it in `launch_venere.sh`:

```bash
osascript <<'EOF'
tell application "Spotify"
    activate
    delay 1.5
    play track "spotify:track:YOUR_TRACK_URI_HERE"
end tell
EOF
```

#### Change the websites to open

```bash
# Open any URL in Safari:
open -a Safari "https://your-website.com"

# Or in Chrome:
open -a "Google Chrome" "https://your-website.com"
```

---

## Usage

### Option A — Manual trigger

```bash
bash venere/launch_venere.sh
```

### Option B — Double-clap trigger (background listener)

```bash
bash venere/start_listener.sh
```

Then **clap your hands twice** (within ~1 second). Venere fires.

To stop the listener:
```bash
pkill -f clap_detector.py
```

### Option C — Voice command via Siri Shortcut

1. Open the **Shortcuts** app on your Mac
2. Click **+** to create a new shortcut
3. Name it `esili` (or whatever word you want to say)
4. Add the action **Run Shell Script**
5. Set Shell to `/bin/bash` and paste:
   ```bash
   bash /Users/YOUR_USERNAME/Desktop/AntiGravity/venere/launch_venere.sh
   ```
6. Save the shortcut
7. Say: **"Hey Siri, esili"** (or your chosen name)

### Option D — Auto-start at login (LaunchAgent)

This makes the clap detector start automatically every time you log in.

1. Copy the template plist and edit it:

```bash
cp venere/com.venere.clapdetector.plist ~/Library/LaunchAgents/
```

2. Open the file and replace every `YOUR_USERNAME` with your actual macOS username:

```bash
nano ~/Library/LaunchAgents/com.venere.clapdetector.plist
```

Your macOS username is shown by running: `whoami`

3. Register the agent:

```bash
launchctl load ~/Library/LaunchAgents/com.venere.clapdetector.plist
```

4. Log out and back in — the clap detector will start automatically.

To disable auto-start:
```bash
launchctl unload ~/Library/LaunchAgents/com.venere.clapdetector.plist
```

---

## Calibrating clap sensitivity

If claps are not detected (or the system fires too easily), run:

```bash
python3 venere/test_mic.py
```

Stay quiet and note the baseline RMS, then clap and note the peak.
Open [venere/clap_detector.py](venere/clap_detector.py) and adjust:

```python
CLAP_THRESHOLD  = 0.10   # set between baseline and clap peak
CLAP_MAX_GAP    = 1.2    # seconds allowed between the two claps
COOLDOWN_SECONDS = 4.0   # wait time before Venere can fire again
```

---

## File structure

```
AntiGravity/
└── venere/
    ├── launch_venere.sh              # Main launcher — edit this to customize
    ├── clap_detector.py              # Microphone listener (double-clap trigger)
    ├── announce.py                   # Voice announcement on launch
    ├── start_listener.sh             # Manually start the clap detector
    ├── boot_detector.sh              # Called by LaunchAgent at login
    ├── setup.sh                      # One-time setup (install deps + chmod)
    ├── test_mic.py                   # Microphone calibration tool
    └── com.venere.clapdetector.plist # LaunchAgent template (auto-start at login)
```

---

## Troubleshooting

**Clap detector doesn't detect my claps**
→ Run `python3 venere/test_mic.py` and lower `CLAP_THRESHOLD` in `clap_detector.py`

**Too many false positives (fires on background noise)**
→ Increase `CLAP_THRESHOLD` in `clap_detector.py`

**Spotify doesn't play**
→ Make sure Spotify is installed and you're logged in. Re-copy the URI as described above.

**"No audio device" error at login**
→ The 20-second delay in `boot_detector.sh` / the 15-second delay in the plist should handle this. Increase `delay 15` in the plist if needed.

**Microphone permission denied**
→ System Settings → Privacy & Security → Microphone → enable Terminal or Python.
