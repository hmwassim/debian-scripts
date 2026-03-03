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

sudo mkdir -p /etc/environment.d
sudo tee /etc/environment.d/90-nvidia-gl.conf > /dev/null << 'EOF'
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF

echo
echo "==> NVIDIA driver ($PKG) installed."
echo "    A reboot is required for the driver to take effect."
