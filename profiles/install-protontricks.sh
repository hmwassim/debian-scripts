#!/usr/bin/env bash
set -euo pipefail

# Protontricks — Winetricks wrapper for Steam Play (Proton) prefixes
# Installed via pipx to avoid polluting system Python.

echo "==> Installing pipx (if not already present)..."
sudo apt install -y pipx
pipx ensurepath

# Make pipx-managed binaries available for the rest of this script
export PATH="$HOME/.local/bin:$PATH"

echo "==> Installing protontricks via pipx..."
pipx install --force protontricks

echo "==> Registering desktop integration..."
protontricks-desktop-install

echo "==> Protontricks installed. Open a new shell or run: source ~/.bashrc"
