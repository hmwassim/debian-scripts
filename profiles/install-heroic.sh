#!/usr/bin/env bash
set -euo pipefail

REPO="Heroic-Games-Launcher/HeroicGamesLauncher"
PKG_NAME="heroic"

# ─── Dependency check ─────────────────────────────────────────────────────────────────
MISSING_DEPS=()
for cmd in curl jq dpkg; do
    command -v "$cmd" &>/dev/null || MISSING_DEPS+=("$cmd")
done
if (( ${#MISSING_DEPS[@]} > 0 )); then
    echo "==> Installing missing deps: ${MISSING_DEPS[*]}"
    sudo apt install -y "${MISSING_DEPS[@]}"
fi

# ─── Fetch release data ───────────────────────────────────────────────────────────────
echo "==> Fetching latest Heroic release info..."
RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
LATEST_VERSION=$(echo "$RELEASE_JSON" | jq -r '.tag_name | sub("^v"; "")')

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
    echo "ERROR: Failed to determine latest version."
    exit 1
fi

# ─── Version comparison ──────────────────────────────────────────────────────────────
INSTALLED_VERSION=""
if dpkg -s "$PKG_NAME" &>/dev/null; then
    INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' "$PKG_NAME" | cut -d- -f1)
fi

if [[ "$INSTALLED_VERSION" == "$LATEST_VERSION" ]]; then
    echo "Heroic $INSTALLED_VERSION is already the latest version."
    exit 0
fi

echo "Installed: ${INSTALLED_VERSION:-none}  Latest: $LATEST_VERSION"

# ─── Download + install ───────────────────────────────────────────────────────────────
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '
    .assets[]
    | select(.name | test("\\.deb$"))
    | select(.name | test("amd64"))
    | .browser_download_url
')

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "ERROR: No amd64 .deb found in the latest release."
    exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")
TMP_FILE="$(mktemp -d)/$FILENAME"

echo "==> Downloading $FILENAME..."
curl -fL -o "$TMP_FILE" "$DOWNLOAD_URL"

echo "==> Installing..."
sudo dpkg -i "$TMP_FILE" || sudo apt-get install -f -y
rm -f "$TMP_FILE"

echo "==> Heroic Games Launcher updated to $LATEST_VERSION"
