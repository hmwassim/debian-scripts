#!/usr/bin/env bash
set -euo pipefail

REMOTE_URL="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
INSTALL_PATH="/usr/local/bin/winetricks"

echo "==> Downloading latest Winetricks..."
sudo curl -fsSL "$REMOTE_URL" -o "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Desktop entry (for GUI launchers)
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/winetricks.desktop" << 'EOF'
[Desktop Entry]
Name=Winetricks
Comment=Work around problems in Wine
Exec=/usr/local/bin/winetricks --gui
Icon=winetricks
Type=Application
Terminal=false
Categories=Utility;Emulator;
StartupNotify=true
EOF

echo "==> Winetricks installed to $INSTALL_PATH"
