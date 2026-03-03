#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing PipeWire audio stack..."
sudo apt install -t trixie-backports -y \
    pipewire \
    pipewire:i386 \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    pipewire-audio-client-libraries \
    wireplumber \
    libspa-0.2-bluetooth \
    libspa-0.2-jack \
    libasound2-plugins \
    libasound2-plugins:i386 \
    rtkit \
    udev

echo "==> Installing EasyEffects and LV2 plugins..."
sudo apt install -y \
    easyeffects \
    lsp-plugins-lv2 \
    calf-plugins \
    x42-plugins \
    zam-plugins

echo "==> Disabling HDA power saving to prevent audio pops..."
sudo mkdir -p /etc/modprobe.d
echo "options snd_hda_intel power_save=0 power_save_controller=N" | \
    sudo tee /etc/modprobe.d/99-audio-disable-powersave.conf

mkdir -p \
    ~/.config/wireplumber/wireplumber.conf.d \
    ~/.config/pipewire/pipewire.conf.d \
    ~/.config/pipewire/pipewire-pulse.conf.d

cat > ~/.config/wireplumber/wireplumber.conf.d/51-disable-suspend.conf << 'EOF'
monitor.alsa.rules = [
  {
    matches = [{ node.name = "~alsa_output.*" }]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]
EOF

cat > ~/.config/pipewire/pipewire.conf.d/10-clock.conf << 'EOF'
context.properties = {
    default.clock.rate           = 48000
    default.clock.allowed-rates  = [ 44100 48000 ]
    default.clock.quantum        = 1024
    default.clock.min-quantum    = 512
    default.clock.max-quantum    = 2048
}
EOF

cat > ~/.config/pipewire/pipewire-pulse.conf.d/10-pulse.conf << 'EOF'
pulse.properties = {
    pulse.min.req     = 1024/48000
    pulse.default.req = 1024/48000
    pulse.max.req     = 2048/48000
}
EOF

systemctl --user enable --now pipewire pipewire-pulse wireplumber
systemctl --user restart pipewire pipewire-pulse wireplumber

echo "==> PipeWire audio stack configured."
