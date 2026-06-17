# StartWorking — Smart Context Launcher for macOS

**StartWorking** is a macOS automation system that launches your entire work environment in one action.

Trigger it by:
- **Pressing the Option (Alt) key three times** (background modifier key listener)
- **Saying a voice command** via Siri Shortcut (e.g. "Start StartWorking")
- **Running the script directly** from Terminal

When triggered, StartWorking opens all your apps, plays your Spotify track, opens your websites, and announces itself with a custom voice message.

---

## What it opens (default configuration)

| Step | What |
|------|------|
| 1 | Visual StudioCode.app |
| 2 | MATLAB |
| 3 | Spotify — plays a specific track via URI |
| 4 | Safari — opens Overleaf and Gemini |
| 5 | Voice announcement: *"you can start working now"* |

Everything in `launch_start_working.sh` is clearly marked `[CUSTOMIZE]` — change it to open whatever you want.

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
git clone https://github.com/PasqualeMarzaioli/Start_Working start_working
cd start_working
```

### 2. Run the setup script

```bash
bash setup.sh
```

This installs `pynput` and makes all scripts executable.

### 3. Grant Accessibility permission

Because `key_detector.py` listens to keypresses globally (even when Terminal is in the background), macOS requires **Accessibility** permission.
Go to **System Settings → Privacy & Security → Accessibility** and check/add Terminal (or your Python binary, or VS Code/iTerm if you run it from there).

### 4. Customize `launch_start_working.sh`

Open [launch_start_working.sh](launch_start_working.sh) and edit the `[CUSTOMIZE]` sections:

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
3. Paste it in `launch_start_working.sh`:

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
bash launch_start_working.sh
```

### Option B — Option-key trigger (background listener)

```bash
bash start_listener.sh
```

Then **press the Option (Alt) key three times** rapidly (within 1.0 second). StartWorking fires.

To stop the listener:
```bash
pkill -f key_detector.py
```

### Option C — Voice command via Siri Shortcut

1. Open the **Shortcuts** app on your Mac
2. Click **+** to create a new shortcut
3. Name it `Start StartWorking` (or whatever word you want to say)
4. Add the action **Run Shell Script**
5. Set Shell to `/bin/bash` and paste:
   ```bash
   bash /Users/YOUR_USERNAME/Desktop/start_working/launch_start_working.sh
   ```
6. Save the shortcut
7. Say: **"Hey Siri, start StartWorking"** (or your chosen name)

### Option D — Auto-start at login (LaunchAgent)

This makes the key detector start automatically every time you log in.

1. Copy the template plist (which has been populated by `setup.sh`):

```bash
cp com.startworking.keydetector.plist ~/Library/LaunchAgents/
```

2. Register the agent:

```bash
launchctl load ~/Library/LaunchAgents/com.startworking.keydetector.plist
```

3. Log out and back in — the key detector will start automatically.

To disable auto-start:
```bash
launchctl unload ~/Library/LaunchAgents/com.startworking.keydetector.plist
```

---

## Troubleshooting

**Key detector doesn't respond to Option presses**
→ Ensure you have granted **Accessibility** permission to the app running the script (Terminal, iTerm, or VS Code) under **System Settings → Privacy & Security → Accessibility**.
→ If it still doesn't respond, run `bash start_listener.sh --debug` and check `key_detector.log` to see if transitions are being registered.

**Spotify doesn't play**
→ Make sure Spotify is installed and you're logged in. Re-copy the URI as described above.
