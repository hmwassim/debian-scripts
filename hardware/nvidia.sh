#!/usr/bin/env bash
set -euo pipefail

# ─── NVIDIA driver installer ──────────────────────────────────────────────────
# Uses extrepo to enable the official NVIDIA CUDA repository, then lets you
# choose between:
#
#   nvidia-open   — open kernel modules (Turing+ / RTX 20xx and later)
#                   Recommended for all Turing+ GPUs.  Actively developed by NVIDIA.
#
#   cuda-drivers  — proprietary full driver + CUDA runtime stack
#                   Use if you actively develop/run CUDA applications.
#
# Both flavours include nvtop for GPU monitoring.
# Run graphics-mesa.sh first so the Vulkan ICD layer is already in place.

# ─── Sanity: extrepo must be installed ────────────────────────────────────────
if ! command -v extrepo &>/dev/null; then
    echo "ERROR: extrepo not found. Run base/system.sh first."
    exit 1
fi

# ─── Enable NVIDIA CUDA repo ──────────────────────────────────────────────────
echo "==> Enabling NVIDIA CUDA repository via extrepo..."
sudo extrepo enable nvidia-cuda
sudo apt update

# ─── Driver selection ─────────────────────────────────────────────────────────
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

# ─── GLX vendor hint ──────────────────────────────────────────────────────────
# Forces Mesa/EGL to pick the NVIDIA ICD on hybrid (Intel iGPU + NVIDIA dGPU)
# systems.  Wayland compositors on KDE Plasma handle this correctly with this
# hint in place.
sudo mkdir -p /etc/environment.d
sudo tee /etc/environment.d/90-nvidia-gl.conf > /dev/null << 'EOF'
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF

echo
echo "==> NVIDIA driver ($PKG) installed."
echo "    A reboot is required for the driver to take effect."
