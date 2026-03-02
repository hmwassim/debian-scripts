#!/usr/bin/env bash
set -euo pipefail

REPO="ryanoasis/nerd-fonts"
API_URL="https://api.github.com/repos/$REPO/releases/latest"
FONTS_DIR="$HOME/.local/share/fonts"
TEMP_DIR="$(mktemp -d)"

fonts=(
  "JetBrainsMono"
  "FiraCode"
  "Hack"
  "CascadiaCode"
)

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

command -v curl >/dev/null || { echo "curl is required."; exit 1; }
command -v unzip >/dev/null || { echo "unzip is required."; exit 1; }

echo "Fetching latest Nerd Fonts release..."

FONT_VERSION=$(curl -fsSL "$API_URL" | grep '"tag_name"' | cut -d '"' -f4)

if [[ -z "$FONT_VERSION" ]]; then
  echo "Failed to detect latest release version."
  exit 1
fi

echo "Latest version: $FONT_VERSION"
mkdir -p "$FONTS_DIR"

for font in "${fonts[@]}"; do
  echo "Installing $font..."

  ZIP_URL="https://github.com/$REPO/releases/download/$FONT_VERSION/${font}.zip"
  ZIP_FILE="$TEMP_DIR/${font}.zip"
  TARGET_DIR="$FONTS_DIR/$font"

  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"

  curl -fL "$ZIP_URL" -o "$ZIP_FILE"
  unzip -q "$ZIP_FILE" -d "$TARGET_DIR"
done

echo "Updating font cache..."
fc-cache -fv
echo "Nerd Fonts installation complete."