#!/usr/bin/env bash
set -euo pipefail

echo "==> Updating package lists..."
sudo apt update

sudo apt install -t trixie-backports -y \
    ffmpeg \
    libavcodec-extra \
    libavcodec-extra:i386 \
    gstreamer1.0-libav \
    gstreamer1.0-libav:i386 \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-good:i386 \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-bad:i386 \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-plugins-ugly:i386 \
    gstreamer1.0-vaapi \
    gstreamer1.0-alsa \
    gstreamer1.0-tools \
    mpv \
    vlc \
    mpg123 \
    lame \
    x264 \
    x265 \
    opus-tools \
    flvmeta

sudo apt install -t trixie-backports -y \
    libgif7           libgif7:i386 \
    libglfw3          libglfw3:i386 \
    libosmesa6        libosmesa6:i386 \
    libvulkan-dev     libvulkan-dev:i386

sudo apt install -t trixie-backports -y \
    timidity \
    fluidsynth \
    dosbox

echo "==> Gaming meta-packages installed."
