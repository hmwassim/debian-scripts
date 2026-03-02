#!/usr/bin/env bash
set -e

CONF_FILE="/etc/fonts/local.conf"

echo "Installing Fonts..."
sudo apt install -y \
  fonts-liberation \
  fonts-liberation2 \
  fonts-cantarell \
  fonts-inter* \
  fonts-noto*

sudo install -d -m 0755 /etc/fonts

sudo tee "$CONF_FILE" >/dev/null <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>

  <!-- Reject Nastaliq if you don't want stylistic switching -->
  <selectfont>
    <rejectfont>
      <glob>*NotoNastaliq*</glob>
    </rejectfont>
  </selectfont>

  <!-- If Windows fonts are requested, prepend Noto Arabic UI -->
  <match target="pattern">
    <test name="family">
      <string>Arial</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic UI</string>
    </edit>
  </match>

  <match target="pattern">
    <test name="family">
      <string>Times New Roman</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Naskh Arabic UI</string>
    </edit>
  </match>

  <!-- Generic fallback: Arabic always prefers Noto -->
  <match target="pattern">
    <test name="lang" compare="contains">
      <string>ar</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic UI</string>
    </edit>
  </match>

</fontconfig>
EOF
sudo fc-cache -f -v
