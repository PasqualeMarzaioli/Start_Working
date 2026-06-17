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
3. Name it `Let's Start Working` (or whatever word you want to say)
4. Add the action **Run Shell Script**
5. Set Shell to `/bin/bash` and paste:
   ```bash
   bash /Users/YOUR_USERNAME/Desktop/start_working/launch_start_working.sh
   ```
6. Save the shortcut
7. Say: **"Hey Siri, let's Start Working"** (or your chosen name)

### Option D — Auto-start at login (LaunchAgent)

This makes the key detector start automatically every time you log in, running completely headlessly in the background (no Terminal windows will open). The agent launches Python directly and routes standard output/errors to a dedicated log folder in your User Library to bypass macOS Sandbox restrictions on Desktop folders.

1. **Copy the template plist** (which is dynamically updated with your actual paths by `setup.sh`):

   ```bash
   cp com.startworking.keydetector.plist ~/Library/LaunchAgents/
   ```

2. **Register and start the agent**:

   ```bash
   launchctl load ~/Library/LaunchAgents/com.startworking.keydetector.plist
   ```

3. **Verify the agent is loaded and running**:
   - To check if the plist is registered with launchd:
     ```bash
     launchctl list | grep startworking
     ```
     *(If successful, you should see a line with a PID and `com.startworking.keydetector`)*
   - To check the active Python listener process:
     ```bash
     ps aux | grep key_detector.py
     ```

To disable auto-start:
```bash
launchctl unload ~/Library/LaunchAgents/com.startworking.keydetector.plist
rm ~/Library/LaunchAgents/com.startworking.keydetector.plist
```

---

## Troubleshooting & logs

### 1. Check the background logs
If something is not working or if you want to verify that the listener successfully registered your key taps, look at the log file:
```bash
cat ~/Library/Logs/StartWorking/key_detector.log
```
Or watch it in real time:
```bash
tail -f ~/Library/Logs/StartWorking/key_detector.log
```

### 2. Key detector doesn't respond to Option presses
This is almost always due to macOS **Accessibility (TCC)** permission requirements. macOS blocks global keyboard hooks unless the executing binary is explicitly whitelisted.

- **If running manually via `start_listener.sh`**:
  Ensure your terminal app (Terminal, iTerm2, or VS Code) has **Accessibility** permission enabled in **System Settings → Privacy & Security → Accessibility**.
- **If running automatically via LaunchAgent (at startup/reboot)**:
  macOS executes the python script using a background python interpreter. You must grant **Accessibility** permission to the specific python executable running it.
  
  **How to grant Accessibility to Python:**
  1. Open **System Settings → Privacy & Security → Accessibility**.
  2. Click the **`+`** button (authenticate with your password).
  3. Press **`Cmd + Shift + G`** to open the "Go to Folder" window.
  4. Paste the path to your python binary. Since `setup.sh` configures the LaunchAgent to run with your virtual environment python if it exists, use:
     `/Users/pasquale_marzaioli/Desktop/Coding/start_working/venv/bin/python3`
     *(If you are not using a venv, you can use the system Python at `/usr/bin/python3`)*
  5. Select the file, add it, and ensure the toggle is turned **ON**.
  
  *Note: macOS sometimes treats `/usr/bin/python3` as a stub redirecting to Xcode Command Line Tools. If you check your logs (`key_detector.log`) and see a warning about Accessibility, check which python process is actually running using `ps aux | grep key_detector.py` and make sure that exact binary is added.*

- **Permissions Reset Trick**:
  If python is already in the list but keyboard triggers still do not work:
  1. Select the entry in the Accessibility list.
  2. Click the **`-`** button to delete it completely.
  3. Click **`+`** and add it again, then enable the switch. This forces macOS to refresh its security database.

### 3. Spotify doesn't play
- Make sure the Spotify desktop app is installed and you are logged in.
- Verify the track/playlist URI in `launch_start_working.sh` matches the format `spotify:track:XXXX` or `spotify:playlist:XXXX`.


