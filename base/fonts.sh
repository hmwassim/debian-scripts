#!/usr/bin/env bash
set -euo pipefail

if ! grep -rq "contrib" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    echo "==> Enabling contrib component..."
    sudo sed -i 's/main$/main contrib/' /etc/apt/sources.list
    sudo apt update
fi

echo "==> Installing system fonts..."
sudo apt install -y \
    fonts-liberation \
    fonts-liberation2 \
    fonts-cantarell \
    fonts-inter \
    fonts-inter-variable

sudo apt install -y \
    fonts-noto \
    fonts-noto-core \
    fonts-noto-hinted \
    fonts-noto-ui-core \
    fonts-noto-unhinted \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-noto-extra \
    fonts-noto-mono \
    fonts-noto-ui-extra

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | \
    sudo debconf-set-selections
sudo apt install -y ttf-mscorefonts-installer

sudo install -d -m 0755 /etc/fonts/conf.d

sudo tee /etc/fonts/local.conf > /dev/null << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>

  <selectfont>
    <rejectfont>
      <glob>*NotoNastaliq*</glob>
    </rejectfont>
  </selectfont>

  <match target="pattern">
    <test name="lang" compare="contains"><string>ar</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic</string>
    </edit>
  </match>

  <match target="pattern">
    <test name="lang" compare="contains"><string>ar</string></test>
    <test name="spacing" compare="eq"><int>100</int></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic UI</string>
    </edit>
  </match>

  <match target="pattern">
    <test name="family"><string>Arial</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>Times New Roman</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Naskh Arabic</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>Tahoma</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic UI</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>Simplified Arabic</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>Traditional Arabic</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Naskh Arabic</string>
    </edit>
  </match>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans Arabic UI</family>
    </prefer>
  </alias>

  <match target="pattern">
    <test name="family"><string>emoji</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <match target="pattern">
    <test name="lang" compare="contains"><string>zh</string></test>
    <edit name="family" mode="append" binding="weak">
      <string>Noto Sans CJK SC</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="lang" compare="contains"><string>ja</string></test>
    <edit name="family" mode="append" binding="weak">
      <string>Noto Sans CJK JP</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="lang" compare="contains"><string>ko</string></test>
    <edit name="family" mode="append" binding="weak">
      <string>Noto Sans CJK KR</string>
    </edit>
  </match>

</fontconfig>
EOF

echo "==> Rebuilding font cache..."
sudo fc-cache -f -v
echo "==> Fonts installed. Verify Arabic rendering with: fc-match -s 'Arial:lang=ar'"

