#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Wine (WineHQ stable)..."
sudo apt install -y --install-recommends winehq-stable

echo "==> Installing Steam..."
sudo apt install -y \
    steam-installer \
    steam-devices \
    steam-libs \
    steam-libs-i386

echo "==> Installing MangoHud, GOverlay and Gamemode..."
sudo apt install -y \
    mangohud \
    mangohud:i386 \
    goverlay \
    gamemode \
    unrar

echo "==> Gaming applications installed."