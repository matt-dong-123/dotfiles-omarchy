# dotfiles-omarchy

Personal dotfiles for an Omarchy/Hyprland desktop, laid out as [GNU Stow](https://www.gnu.org/software/stow/) packages. Each top-level directory is a package whose contents mirror the target path under `$HOME`.

## Deploy

```sh
cd ~/dotfiles-omarchy
stow -t ~ <package>       # symlink one package into place
stow -t ~ */              # symlink everything
stow -n -t ~ <package>    # dry run - check for conflicts first
```

Stow will refuse to symlink a package if a real (non-symlink) file already exists at the target path. Since these files were copied from a live `~/.config`, move/remove the originals (or back them up) before stowing, e.g. `stow -D -t ~ <package>` to remove, or delete the live file/dir once you've confirmed the copy in this repo is faithful.

## Packages

| Package | Covers |
|---|---|
| `hypr` | Hyprland config (bindings, monitors, input, look & feel, autostart) |
| `omarchy` | Omarchy shell (dock, bar layout, menu extension, custom post-update hooks) |
| `alacritty`, `foot`, `ghostty`, `kitty` | Terminal emulators |
| `tmux` | tmux config + modules (plugins excluded, see below) |
| `herdr` | herdr (tmux-like multiplexer) config |
| `sesh` | sesh session manager config |
| `zsh` | Zsh config (`.zshenv`, `.zshrc`, `.zshrc.d/*`) |
| `starship` | Starship prompt |
| `git` | Git config + global ignore |
| `gh` | GitHub CLI config |
| `lazygit` | lazygit config incl. custom conventional-commit command |
| `mise` | mise tool version pins |
| `fzf`, `ripgrep` | CLI tool defaults |
| `bin` | Personal scripts on `PATH` (`~/.config/bin`, see `zsh/.zshrc`) |
| `nvim` | Personal LazyVim overrides only (`lua/config/*`, `lua/plugins/*`) - not a full LazyVim distribution. `lua/plugins/theme.lua` is an Omarchy-managed symlink (like the btop theme) and isn't tracked here. |
| `btop` | btop config (theme is Omarchy-managed, not tracked here) |
| `imv` | Image viewer keybinds |
| `voxtype` | Voice dictation daemon config |
| `wireplumber` | Bluetooth A2DP autoconnect override |
| `fontconfig` | Monospace font substitution |
| `fcitx5` | Input method (pinyin) setup |
| `kanata` | Keyboard remapping rules |
| `xdg` | `mimeapps.list`, `xdg-terminals.list`, `chromium-flags.conf` |
| `systemd-user` | Hand-written user units (`voxtype.service`, `kanata.service`) |

### systemd-user

After stowing, these units need to be enabled manually (this package intentionally does not track the `*.target.wants/*` symlinks `systemctl enable` creates):

```sh
systemctl --user enable --now voxtype.service kanata.service
```

## Deliberately excluded from this repo

- Third-party cloned repos pulled in by plugin managers: `tmux/plugins/*` (TPM), `omarchy/plugins/*` and `omarchy/themes/rose-pine-moon` (Omarchy plugin/theme manager) - reinstall these via each tool's own mechanism (`prefix+I` for TPM, Omarchy's plugin/theme manager for the rest).
- Caches, browser profiles, `node_modules`, binary state (`dconf`, `pulse`, `ibus`, shell history), and other runtime/session data that isn't meaningful config.
