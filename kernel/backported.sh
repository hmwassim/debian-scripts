#!/usr/bin/env bash
set -euo pipefail

if ! grep -q "VERSION_CODENAME=trixie" /etc/os-release; then
    echo "ERROR: This script targets Debian Trixie. Exiting."
    exit 1
fi

if ! grep -rq "trixie-backports" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    echo "==> Adding trixie-backports..."
    echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" | \
        sudo tee /etc/apt/sources.list.d/backports.list
    sudo apt update
else
    echo "Backports already enabled."
fi

echo "==> Installing backported kernel (amd64)..."
sudo apt install -t trixie-backports -y \
    linux-headers-amd64 \
    linux-image-amd64

echo "==> Backported kernel installed. Reboot to apply."

echo "==> Enabling ntsync module..."
echo ntsync | sudo tee /etc/modules-load.d/ntsync.conf
