#!/usr/bin/env bash
set -euo pipefail

# Liquorix is a desktop/gaming-optimised kernel based on upstream Linux
# with MuQSS/EEVDF scheduler and desktop-friendly defaults.
# See: https://liquorix.net

echo "==> Installing Liquorix kernel..."
curl -fsSL https://liquorix.net/install-liquorix.sh | sudo bash
echo "==> Liquorix kernel installed. Reboot to apply."

# ─── ntsync ───────────────────────────────────────────────────────────────────
# Liquorix tracks mainline and is always 6.14+, so ntsync is available.
# Improves Wine/Proton threading performance significantly.
echo "==> Enabling ntsync module..."
echo ntsync | sudo tee /etc/modules-load.d/ntsync.conf
