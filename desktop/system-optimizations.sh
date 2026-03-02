#!/usr/bin/env bash
set -euo pipefail

# ─── Shell utilities ──────────────────────────────────────────────────────────
echo "==> Installing shell utilities..."
sudo apt install -y \
    eza \
    starship \
    papirus-icon-theme \
    fastfetch \
    bat \
    ripgrep

# ─── bashrc.d drop-in ─────────────────────────────────────────────────────────
# Shell customisations live in their own file, not inlined into ~/.bashrc.
# ~/.bashrc just sources the directory — easy to extend, easy to remove.

BASHRC_D="$HOME/.config/bashrc.d"
CUSTOM_FILE="$BASHRC_D/00-custom.sh"
BASHRC="$HOME/.bashrc"
LOADER_MARKER="# source ~/.config/bashrc.d"

mkdir -p "$BASHRC_D"

# Append loader to ~/.bashrc (once)
if ! grep -qF "$LOADER_MARKER" "$BASHRC"; then
    cat << 'BASHRC_LOADER' >> "$BASHRC"

# source ~/.config/bashrc.d
if [ -d "$HOME/.config/bashrc.d" ]; then
    for _f in "$HOME/.config/bashrc.d"/*.sh; do
        [ -r "$_f" ] && . "$_f"
    done
    unset _f
fi
BASHRC_LOADER
    echo "Loader added to ~/.bashrc."
fi

# Write (or overwrite) the custom file — idempotent
cat > "$CUSTOM_FILE" << 'CUSTOM'
# ── Custom shell tweaks (managed by system-optimizations.sh) ──────────────────

# Case-insensitive tab completion
bind "set completion-ignore-case on"

# eza replaces ls
alias ls='eza -al --icons --color=always --group-directories-first'
alias la='eza -a  --icons --color=always --group-directories-first'
alias ll='eza -l  --icons --color=always --group-directories-first'
alias lt='eza -aT --icons --color=always --group-directories-first'

# bat replaces cat (syntax highlighting, no pager)
alias cat='batcat --style=plain --pager=never'

# Starship prompt — must be last
eval "$(starship init bash)"
CUSTOM

echo "Shell tweaks written to $CUSTOM_FILE"

# ─── ZRAM ─────────────────────────────────────────────────────────────────────
echo "==> Configuring ZRAM..."
sudo apt install -y systemd-zram-generator

sudo tee /etc/systemd/zram-generator.conf > /dev/null << 'EOF'
[zram0]
# Compresses well with zstd; max size capped so it stays reasonable on any RAM.
# Uses ram / 2 up to 8 GB, matching the default of most mainstream distros.
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

# ─── Electron Wayland hint ────────────────────────────────────────────────────
# "auto" lets apps that support Wayland use it natively; others fall back to XWayland.
sudo mkdir -p /etc/environment.d
sudo tee /etc/environment.d/90-electron.conf > /dev/null << 'EOF'
ELECTRON_OZONE_PLATFORM_HINT=auto
EOF

# ─── sysctl tweaks ────────────────────────────────────────────────────────────
echo "==> Applying sysctl desktop tuning..."

MEM_TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_TOTAL_BYTES=$(( MEM_TOTAL_KB * 1024 ))

# Background writeback at 0.5%, hard limit at 2% (clamped)
DIRTY_BG=$(( MEM_TOTAL_BYTES / 200 ))
DIRTY_MAX=$(( MEM_TOTAL_BYTES / 50 ))
(( DIRTY_BG  > 1073741824 )) && DIRTY_BG=1073741824   # 1 GB cap
(( DIRTY_MAX > 4294967296 )) && DIRTY_MAX=4294967296   # 4 GB cap

sudo tee /etc/sysctl.d/99-desktop.conf > /dev/null << EOF
# ── Memory ────────────────────────────────────────────────────────────────────
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_background_bytes = ${DIRTY_BG}
vm.dirty_bytes = ${DIRTY_MAX}

# ── Scheduler ─────────────────────────────────────────────────────────────────
kernel.sched_autogroup_enabled = 1

# ── Network ───────────────────────────────────────────────────────────────────
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_fastopen = 3
EOF

sudo sysctl --system
echo "==> System optimizations applied."
