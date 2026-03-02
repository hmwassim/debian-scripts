#!/usr/bin/env bash
set -euo pipefail

# ─── Trixie guard ─────────────────────────────────────────────────────────────
if ! grep -q "VERSION_CODENAME=trixie" /etc/os-release; then
    echo "ERROR: This script targets Debian Trixie. Exiting."
    exit 1
fi

echo "==> Updating system..."
sudo apt update
sudo apt full-upgrade -y

# ─── i386 multilib ────────────────────────────────────────────────────────────
echo "==> Enabling i386 architecture..."
sudo dpkg --add-architecture i386
sudo apt update

# ─── Trixie backports ─────────────────────────────────────────────────────────
if ! grep -rq "trixie-backports" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    echo "==> Adding trixie-backports..."
    echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" | \
        sudo tee /etc/apt/sources.list.d/backports.list
    sudo apt update
fi

# ─── Firmware ─────────────────────────────────────────────────────────────────
echo "==> Installing firmware..."
sudo apt install -t trixie-backports -y \
    firmware-linux \
    firmware-linux-nonfree \
    firmware-misc-nonfree \
    firmware-iwlwifi \
    firmware-realtek \
    firmware-sof-signed \
    intel-microcode

# ─── Core tools ───────────────────────────────────────────────────────────────
echo "==> Installing core tools..."
sudo apt install -t trixie-backports -y \
    git \
    curl \
    wget \
    unzip \
    p7zip-full \
    gzip \
    build-essential \
    pkg-config \
    cmake \
    nvme-cli \
    smartmontools \
    pciutils \
    usbutils \
    cabextract \
    zenity \
    extrepo \
    jq \
    lm-sensors \
    hunspell-en-us \
    hunspell-fr \
    ddcutil

# ─── User groups ──────────────────────────────────────────────────────────────
echo "==> Adding $USER to hardware groups..."
sudo usermod -aG audio,video,render,i2c "$USER"

# ─── WineHQ repo ──────────────────────────────────────────────────────────────
echo "==> Enabling WineHQ via extrepo..."
sudo extrepo enable winehq
sudo apt update

# ─── DNS-over-TLS ─────────────────────────────────────────────────────────────
# Primary:  Cloudflare for Families (blocks malware + adult content)
# Fallback: Quad9 (blocks malware, DNSSEC-validating)
echo "==> Configuring systemd-resolved with DNS-over-TLS..."
sudo apt install -y systemd-resolved

sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo mkdir -p /etc/systemd/resolved.conf.d

sudo tee /etc/systemd/resolved.conf.d/99-dot.conf > /dev/null << 'EOF'
[Resolve]
DNS=1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com 2606:4700:4700::1112#security.cloudflare-dns.com 2606:4700:4700::1002#security.cloudflare-dns.com
FallbackDNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net
DNSOverTLS=yes
DNSSEC=yes
DNSStubListener=yes
MulticastDNS=no
Cache=yes
Domains=~.
EOF

sudo systemctl enable --now systemd-resolved
sudo systemctl restart systemd-resolved

# Verify resolution works before continuing
if ! resolvectl query debian.org &>/dev/null; then
    echo "WARNING: DNS resolution check failed — verify /etc/systemd/resolved.conf.d/99-dot.conf"
fi

sudo apt autoremove -y
echo "==> Base system setup complete. A reboot is recommended."
