#!/usr/bin/env bash
set -euo pipefail

# ─── Wine (stable, WineHQ) ─────────────────────────────────────────────────────────────
# Requires WineHQ repo to be enabled (base/system.sh uses extrepo for this)
echo "==> Installing Wine (WineHQ stable)..."
sudo apt install -y --install-recommends winehq-stable

# ─── Steam ──────────────────────────────────────────────────────────────────────
echo "==> Installing Steam..."
sudo apt install -y \
    steam-installer \
    steam-devices \
    steam-libs \
    steam-libs-i386

# ─── Gaming overlays + performance ───────────────────────────────────────────────
echo "==> Installing MangoHud, GOverlay and Gamemode..."
sudo apt install -y \
    mangohud \
    mangohud:i386 \
    goverlay \
    gamemode \
    unrar

echo "==> Gaming applications installed."