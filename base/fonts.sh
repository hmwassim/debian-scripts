#!/usr/bin/env bash
set -euo pipefail

# ─── Ensure contrib is available (needed for ttf-mscorefonts-installer) ──────
if ! grep -rq "contrib" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    echo "==> Enabling contrib component..."
    sudo sed -i 's/main$/main contrib/' /etc/apt/sources.list
    sudo apt update
fi

# ─── System fonts ─────────────────────────────────────────────────────────────
echo "==> Installing system fonts..."
sudo apt install -y \
    fonts-liberation \
    fonts-liberation2 \
    fonts-cantarell \
    fonts-inter \
    fonts-inter-variable

# Full Noto family — covers virtually every script on earth
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

# Microsoft core web fonts (Arial, Times New Roman, Courier New, Verdana, etc.)
# These are what most websites specify; without them browsers chain-fallback to
# random system fonts.  We install them and then configure fontconfig to keep
# Noto ABOVE them for Arabic, CJK and emoji so they are never degraded.
# ttf-mscorefonts-installer downloads from SourceForge — accepts EULA silently.
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | \
    sudo debconf-set-selections
sudo apt install -y ttf-mscorefonts-installer

# ─── fontconfig — Noto first, MS fonts never win for non-Latin scripts ────────
sudo install -d -m 0755 /etc/fonts/conf.d

sudo tee /etc/fonts/local.conf > /dev/null << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>

  <!-- ── Drop stylistic Nastaliq from auto-selection ─────────────────────── -->
  <selectfont>
    <rejectfont>
      <glob>*NotoNastaliq*</glob>
    </rejectfont>
  </selectfont>

  <!-- ── Arabic: always prefer Noto, regardless of requested family ────────── -->
  <!-- This fires whenever text is tagged as Arabic (lang=ar) -->
  <match target="pattern">
    <test name="lang" compare="contains"><string>ar</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic</string>
    </edit>
  </match>

  <!-- UI contexts (menus, tooltips) use the UI variant for tighter metrics -->
  <match target="pattern">
    <test name="lang" compare="contains"><string>ar</string></test>
    <test name="spacing" compare="eq"><int>100</int></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic UI</string>
    </edit>
  </match>

  <!-- Map web-standard Arabic font names to their Noto equivalents -->
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

  <!-- ── sans-serif alias: inject Arabic UI font so browser tabs render correctly ──
       Browser tab titles have no lang=ar hint; this catches Arabic codepoints
       rendered via the generic sans-serif family (used by most browser UIs).  -->
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans Arabic UI</family>
    </prefer>
  </alias>

  <!-- ── Emoji: always use Noto Color Emoji ────────────────────────────────── -->
  <match target="pattern">
    <test name="family"><string>emoji</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Color Emoji</string>
    </edit>
  </match>

  <!-- ── CJK fallback ──────────────────────────────────────────────────────── -->
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

