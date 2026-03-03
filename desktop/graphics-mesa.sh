#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Mesa, VA-API and Vulkan base (all GPUs)..."
sudo apt install -t trixie-backports -y \
    mesa-va-drivers \
    mesa-va-drivers:i386 \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    libva2 \
    libva2:i386 \
    libvulkan1 \
    libvulkan1:i386 \
    vulkan-tools \
    vulkan-validationlayers \
    vainfo

if lspci | grep -qi "VGA\|3D\|Display" && lspci | grep -iE "VGA|3D|Display" | grep -qi intel; then
    echo "==> Intel GPU detected — installing intel-media-va-driver-non-free..."
    sudo apt install -t trixie-backports -y \
        intel-media-va-driver-non-free \
        intel-media-va-driver-non-free:i386
fi

if lspci | grep -iE "VGA|3D|Display" | grep -iE "AMD|ATI|Radeon" | grep -q .; then
    echo "==> AMD GPU detected — installing firmware-amd-graphics..."
    sudo apt install -t trixie-backports -y firmware-amd-graphics
fi

if dpkg -s xserver-xorg-video-intel &>/dev/null; then
    echo "==> Removing legacy xserver-xorg-video-intel DDX..."
    sudo apt remove -y xserver-xorg-video-intel
fi

sudo apt autoremove -y
echo "==> Graphics stack installed."
echo "    Verify with: vainfo  |  vulkaninfo --summary"

