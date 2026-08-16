# Multi Timezone Panel Clock Plasmoid for KDE Plasma (Fedora / Linux)

A KDE Plasma panel widget (Plasmoid) designed for Linux desktop environments (such as Fedora v43 / Plasma 6 & 5). It allows you to display multiple timezone clocks simultaneously on your panel (bottom bar) in place of or alongside the standard system clock.

## Features

- **Multiple Clocks Display:** Display 4 or more clocks simultaneously side-by-side directly in the KDE panel.
- **Custom Timezone Names:** Show short, customizable names (e.g. `NY`, `London`, `Tokyo`, `UTC`, `Local`) next to each clock.
- **Easy Toggle & Settings:** Turn on and off individual clocks with easy-to-use checkboxes in the settings GUI.
- **Time Formatting Options:** Support for 24-hour / 12-hour formats and optional seconds display.
- **Presets & Custom IANA Timezones:** Easily select popular timezone presets or specify any standard IANA timezone name (e.g., `America/New_York`, `Europe/London`, `Asia/Tokyo`).
- **Quick Settings Access:** Right-click the widget in the panel and select **Configure Multi Timezone Panel Clock...** or click the widget to open the popup drawer and click **Configure Timezones...**.

## Requirements

- Linux operating system (e.g., Fedora 43, Fedora 40+, Ubuntu, Arch Linux)
- KDE Plasma desktop environment (Plasma 6 or Plasma 5)

## Installation

1. Clone or download this repository into a folder.
2. Run the installation script:
   ```bash
   ./install.sh
   ```
   Or manually copy the files into your KDE user plasmoids directory:
   ```bash
   mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.multizoneclock
   cp -r metadata.json contents ~/.local/share/plasma/plasmoids/org.kde.plasma.multizoneclock/
   ```

3. Restart Plasma (if needed, or enter panel edit mode directly):
   - On Plasma 6 (Wayland/X11):
     ```bash
     kquitapp6 plasmashell && kstart plasmashell
     ```

## Adding Widget to Bottom Panel

1. Right-click on your KDE panel / bottom bar and click **Enter Edit Mode** (or **Add Widgets...**).
2. Click **Add Widgets...** and search for **Multi Timezone Panel Clock**.
3. Drag and drop the **Multi Timezone Panel Clock** widget onto your panel near the system clock position.

## Configuration

1. Right-click on the widget on the panel and select **Configure Multi Timezone Panel Clock...**.
2. In the settings window:
   - Check or uncheck individual clocks to show/hide them.
   - Edit the displayed **Clock Name** (e.g., `NY`, `UTC`, `London`).
   - Edit or select the **Timezone** string.
   - Click **Add Clock** or choose a **Quick Preset...** to add new timezones.
   - Toggle **24-hour time format**, **seconds**, and **timezone labels**.
3. Changes apply dynamically!
