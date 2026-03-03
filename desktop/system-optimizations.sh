#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing shell utilities..."
sudo apt install -y \
    eza \
    starship \
    papirus-icon-theme \
    fastfetch \
    bat \
    ripgrep

BASHRC_D="$HOME/.config/bashrc.d"
CUSTOM_FILE="$BASHRC_D/00-custom.sh"
BASHRC="$HOME/.bashrc"
LOADER_MARKER="# source ~/.config/bashrc.d"

mkdir -p "$BASHRC_D"

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

cat > "$CUSTOM_FILE" << 'CUSTOM'
bind "set completion-ignore-case on"

alias ls='eza -al --icons --color=always --group-directories-first'
alias la='eza -a  --icons --color=always --group-directories-first'
alias ll='eza -l  --icons --color=always --group-directories-first'
alias lt='eza -aT --icons --color=always --group-directories-first'

alias cat='batcat --style=plain --pager=never'

# Starship prompt — must be last
eval "$(starship init bash)"
CUSTOM

echo "Shell tweaks written to $CUSTOM_FILE"

echo "==> Configuring ZRAM..."
sudo apt install -y systemd-zram-generator

sudo tee /etc/systemd/zram-generator.conf > /dev/null << 'EOF'
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

echo "==> Applying sysctl desktop tuning..."

MEM_TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_TOTAL_BYTES=$(( MEM_TOTAL_KB * 1024 ))

DIRTY_BG=$(( MEM_TOTAL_BYTES / 200 ))
DIRTY_MAX=$(( MEM_TOTAL_BYTES / 50 ))
(( DIRTY_BG  > 1073741824 )) && DIRTY_BG=1073741824
(( DIRTY_MAX > 4294967296 )) && DIRTY_MAX=4294967296

sudo tee /etc/sysctl.d/99-desktop.conf > /dev/null << EOF
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_background_bytes = ${DIRTY_BG}
vm.dirty_bytes = ${DIRTY_MAX}

kernel.sched_autogroup_enabled = 1

net.ipv4.icmp_ignore_bogus_error_responses = 1
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_fastopen = 3
EOF

sudo sysctl --system
echo "==> System optimizations applied."
