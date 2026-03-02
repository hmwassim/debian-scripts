#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Flatpak for GNOME..."

sudo apt install -y \
    flatpak \
    gnome-software-plugin-flatpak \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome

flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo

echo "==> Flatpak (GNOME) configured. Re-login or reboot for portal to activate."
