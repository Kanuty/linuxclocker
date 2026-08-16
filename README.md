# Multi Timezone Panel Clock (KDE Plasma Addon for Fedora Linux)

A custom KDE Plasma panel widget (Plasmoid) designed specifically for Linux (Fedora Workstation / Fedora KDE Spin v43 and compatible versions). It allows you to display and manage multiple timezone clocks (4 or more at the same time) on your lowest system bar (panel), directly where the regular clock is usually located.

---

## Features

- **Multi-Clock Panel Display:** Display 4+ clocks side-by-side simultaneously on your KDE bottom bar.
- **Timezone Names:** Display custom labels/names next to each clock (e.g., `NY: 08:30`, `UTC: 12:30`, `Tokyo: 21:30`).
- **Easy Toggle & Configuration:** Turn individual clocks on or off easily using switches in the configuration UI.
- **Presets & Custom IANA Timezones:** Quick-select presets (New York, London, Tokyo, Paris, Sydney, etc.) or enter any standard IANA timezone string.
- **Time Format Controls:** Choose between 24-hour and 12-hour (AM/PM) time formats and toggle seconds display.
- **Easy Access to Settings:** Right-click the widget in your bottom bar or click on the widget popup drawer to access settings anytime.

---

## Detailed Step-by-Step Installation Guide for Fedora (v43 / KDE Plasma)

Follow these instructions to install and activate the widget on your Fedora system.

### Step 1: Open a Terminal and Navigate to the Repository

Open your terminal app (**Konsole** or **Terminal**) on Fedora and navigate to the directory where this repository is located:

```bash
cd /path/to/org.kde.plasma.multizoneclock
```

### Step 2: Run the Installation Script

Run the included installation script:

```bash
chmod +x install.sh
./install.sh
```

*(Alternatively, if you prefer manual installation without running the script:)*
```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.multizoneclock
cp -r metadata.json contents ~/.local/share/plasma/plasmoids/org.kde.plasma.multizoneclock/
```

### Step 3: Refresh KDE Plasma (Optional but Recommended)

If KDE Plasma is currently running and does not immediately index the new widget in the widget list, restart `plasmashell` from your terminal:

```bash
kquitapp6 plasmashell && kstart plasmashell
```
*(On Fedora KDE Plasma 5, use `kquitapp5 plasmashell && kstart5 plasmashell`)*

---

## Step 4: Adding the Multi-Clock Widget to Your Bottom Panel Bar

1. **Enter Edit Mode:** Right-click anywhere on an empty space on your lowest panel bar (the bar at the bottom of your screen) and select **Enter Edit Mode** (or **Show Panel Configuration**).
2. **Add Widget:** Click **Add Widgets...** at the top or side of the panel settings bar.
3. **Locate Widget:** In the widget search bar, type:
   ```
   Multi Timezone Panel Clock
   ```
4. **Place Widget:** Drag and drop **Multi Timezone Panel Clock** directly onto your bottom bar in the exact position where you want your clocks to appear (e.g., right next to or in place of your standard system clock).
5. **Exit Edit Mode:** Click the **X** button or press **Escape** to exit panel edit mode.

---

## Step 5: Configuring Timezones & Toggling Clocks On/Off

1. **Open Settings:** Right-click on the newly added clock widget in your bottom bar and select **Configure Multi Timezone Panel Clock...**.
2. **Configure Clocks:**
   - **Enable / Disable Clocks:** Check or uncheck the box next to any clock to turn it on or off immediately.
   - **Custom Clock Name:** Edit the text box (e.g. change `America/New_York` name to `NY` or `New York`).
   - **Timezone Selection:** Type a standard IANA timezone name (e.g. `UTC`, `America/New_York`, `Europe/London`, `Asia/Tokyo`) or use the **Quick Preset...** dropdown to add popular timezones.
   - **Reorder Clocks:** Use the up and down arrow buttons to reorder how clocks appear from left to right on your panel.
   - **Time Options:** Toggle 24-hour clock format, seconds display, or hiding/showing timezone label names.
3. **Apply & Close:** Settings update dynamically on your bottom bar!

---

## Troubleshooting on Fedora

- **Widget not appearing in "Add Widgets":** Make sure the directory `~/.local/share/plasma/plasmoids/org.kde.plasma.multizoneclock` exists and contains `metadata.json` and the `contents/` folder. Then restart `plasmashell`.
- **Invalid Timezone String:** Ensure timezone strings match official IANA format (e.g., `America/Chicago`, `Europe/Paris`, `Asia/Singapore`).
