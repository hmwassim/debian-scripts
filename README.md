# debian-scripts

Opinionated shell scripts for turning a fresh **Debian Trixie** install into a modern desktop.  
Each script is self-contained and safe to re-run.

```bash
git clone https://github.com/habibimedwassim/debian-scripts.git
cd debian-scripts
```

---

## Scripts

### Base

| Script | What it does |
|---|---|
| `base/system.sh` | i386 multilib, backports, firmware, core tools, WineHQ repo, DNS-over-TLS |
| `base/fonts.sh` | Noto + Liberation + MS core web fonts, Arabic fontconfig rules |
| `base/nerd-fonts.sh` | JetBrainsMono, FiraCode, Hack, CascadiaCode (latest Nerd Fonts release) |

### Desktop

| Script | What it does |
|---|---|
| `desktop/graphics-mesa.sh` | Mesa VA-API + Vulkan; auto-installs Intel/AMD extras based on detected GPU |
| `desktop/audio-pipewire.sh` | PipeWire + WirePlumber + EasyEffects, stable 48 kHz clock config |
| `desktop/flatpak-kde.sh` | Flatpak + KDE Plasma backend + Flathub |
| `desktop/flatpak-gnome.sh` | Flatpak + GNOME backend + Flathub |
| `desktop/system-optimizations.sh` | ZRAM, sysctl tuning, shell tweaks (`eza`, `bat`, `starship`) in `~/.config/bashrc.d/` |

### Hardware

| Script | What it does |
|---|---|
| `hardware/nvidia.sh` | NVIDIA driver via extrepo — prompts to choose `nvidia-open` (Turing+) or `cuda-drivers` |

### Kernels — pick one

| Script | Kernel |
|---|---|
| `kernel/backported.sh` | Debian trixie-backports kernel + ntsync |
| `kernel/liquorix.sh` | [Liquorix](https://liquorix.net) gaming kernel + ntsync |

### Gaming

| Script | What it does |
|---|---|
| `profiles/gaming-meta.sh` | Runtime libs + full codec stack (64-bit + 32-bit) |
| `profiles/gaming-applications.sh` | Wine (WineHQ), Steam, MangoHud, GOverlay, Gamemode |
| `profiles/install-winetricks.sh` | Latest Winetricks from upstream |
| `profiles/install-protontricks.sh` | Protontricks via pipx |
| `profiles/install-heroic.sh` | Heroic Games Launcher — self-updating |
| `profiles/install-github-desktop.sh` | GitHub Desktop for Linux (shiftkey fork) — self-updating |

---

## Notes

- All scripts require Debian Trixie (amd64) and sudo access.
- Reboot after `base/system.sh`, `hardware/nvidia.sh`, or any kernel script.
- `ntsync` is enabled by the kernel scripts (backported / Liquorix), both of which are 6.14+.
- Run `graphics-mesa.sh` before `hardware/nvidia.sh`.
