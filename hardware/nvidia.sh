#!/usr/bin/env bash
set -euo pipefail

if ! command -v extrepo &>/dev/null; then
    echo "ERROR: extrepo not found. Run base/system.sh first."
    exit 1
fi

echo "==> Enabling NVIDIA CUDA repository via extrepo..."
sudo extrepo enable nvidia-cuda
sudo apt update

echo
echo "Choose NVIDIA driver variant:"
echo "  1) nvidia-open   — open kernel modules, Turing+ (RTX 20xx and newer, recommended)"
echo "  2) cuda-drivers  — proprietary, full CUDA stack"
echo
read -rp "Choice [1/2]: " choice

case "$choice" in
    1) PKG="nvidia-open"    ;;
    2) PKG="cuda-drivers"   ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "==> Installing $PKG + nvtop..."
sudo apt install -y "$PKG" nvtop

# ── Kernel parameter: nvidia-drm.modeset=1 ─────────────────────────────────
# Required for NVIDIA Wayland/GBM support (KDE Plasma 6, SDDM, etc.)
echo
echo "==> Adding nvidia-drm.modeset=1 kernel parameter..."

add_modeset_grub() {
    local cfg=/etc/default/grub
    if grep -q "nvidia-drm.modeset=1" "$cfg"; then
        echo "    Already present in $cfg, skipping."
        return
    fi
    sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia-drm.modeset=1"/' "$cfg"
    sudo update-grub
    echo "    Written to $cfg and GRUB updated."
}

add_modeset_systemd_boot() {
    local entry
    # Common ESP mount points: /efi, /boot/efi, /boot
    for mp in /efi /boot/efi /boot; do
        entry=$(sudo find "$mp/loader/entries" -maxdepth 1 -name "*.conf" 2>/dev/null | sort | head -1)
        [[ -n "$entry" ]] && break
    done
    if [[ -z "$entry" ]]; then
        echo "    WARNING: No systemd-boot entry found. Add nvidia-drm.modeset=1 manually."
        return
    fi
    if grep -q "nvidia-drm.modeset=1" "$entry"; then
        echo "    Already present in $entry, skipping."
        return
    fi
    sudo sed -i '/^options / s/$/ nvidia-drm.modeset=1/' "$entry"
    echo "    Written to $entry."
}

if sudo bootctl is-installed 2>/dev/null; then
    add_modeset_systemd_boot
elif [[ -f /etc/default/grub ]]; then
    add_modeset_grub
else
    echo "    WARNING: Could not detect bootloader. Add nvidia-drm.modeset=1 manually."
fi

# ── NOTE: __GLX_VENDOR_LIBRARY_NAME=nvidia is intentionally NOT set ─────────
# KDE Plasma 6 / KWin selects the GLX vendor automatically. Forcing this
# variable globally can crash Electron apps (e.g. GitHub Desktop) and break
# XWayland sessions. It is not needed on single-GPU NVIDIA setups.

echo
echo "==> NVIDIA driver ($PKG) installed."
echo "    A reboot is required for the driver to take effect."
