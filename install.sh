#!/bin/bash
set -e

PLASMOID_ID="org.kde.plasma.multizoneclock"
PLASMOID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Multi Timezone Clock Plasmoid ($PLASMOID_ID)..."

# Target installation path for user plasmoids in KDE Plasma 6 / 5
USER_PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"

mkdir -p "$USER_PLASMOID_DIR"

# Copy package contents
cp -r "$PLASMOID_DIR/metadata.json" "$USER_PLASMOID_DIR/" 2>/dev/null || cp -r "$PLASMOID_DIR/metadata.desktop" "$USER_PLASMOID_DIR/" 2>/dev/null || true
cp -r "$PLASMOID_DIR/contents" "$USER_PLASMOID_DIR/"

# Try kpackagetool6 or kpackagetool5 if available
if command -v kpackagetool6 &> /dev/null; then
    echo "Registering plasmoid with kpackagetool6..."
    kpackagetool6 --type Plasma/Applet --install "$PLASMOID_DIR" 2>/dev/null || kpackagetool6 --type Plasma/Applet --upgrade "$PLASMOID_DIR" 2>/dev/null || true
elif command -v kpackagetool5 &> /dev/null; then
    echo "Registering plasmoid with kpackagetool5..."
    kpackagetool5 --type Plasma/Applet --install "$PLASMOID_DIR" 2>/dev/null || kpackagetool5 --type Plasma/Applet --upgrade "$PLASMOID_DIR" 2>/dev/null || true
fi

echo "Installation complete!"
echo "To add the widget to your bottom panel in KDE Plasma:"
echo "1. Right-click on your bottom panel and choose 'Add Widgets...' (or 'Enter Edit Mode')."
echo "2. Search for 'Multi Timezone Panel Clock'."
echo "3. Drag and drop it onto your bottom panel next to your regular clock."
echo "4. Right-click the widget and select 'Configure Multi Timezone Panel Clock...' to add/toggle your timezones."
