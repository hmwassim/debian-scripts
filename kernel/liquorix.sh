#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Liquorix kernel..."
curl -fsSL https://liquorix.net/install-liquorix.sh | sudo bash
echo "==> Liquorix kernel installed. Reboot to apply."

echo "==> Enabling ntsync module..."
echo ntsync | sudo tee /etc/modules-load.d/ntsync.conf
