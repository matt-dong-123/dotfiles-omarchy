#!/usr/bin/env bash
# Installs the packages these dotfiles depend on and symlinks every
# package directory here into $HOME using GNU Stow. Safe to re-run:
# already-correct symlinks are left alone, and anything real that would
# be overwritten gets moved into a timestamped backup dir first.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=false
SKIP_PACKAGES=false
ONLY_PACKAGES=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

  --dry-run           Show what would change without installing packages
                       or touching any files
  --skip-packages      Skip the pacman/AUR install step, only symlink
  --package NAME       Only symlink this package (repeatable)
  -h, --help           Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --skip-packages) SKIP_PACKAGES=true; shift ;;
        --package) ONLY_PACKAGES+=("$2"); shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
done

# Packages available straight from pacman - official repos plus the
# "omarchy" repo that base Omarchy adds (covers herdr, voxtype-bin).
PACMAN_PACKAGES=(
    stow
    foot ghostty kitty tmux neovim
    herdr voxtype-bin
    github-cli lazygit mise fzf ripgrep
    btop imv wireplumber starship
    fcitx5 fcitx5-gtk fcitx5-qt fcitx5-chinese-addons
)

# Only on the AUR - need yay or paru.
AUR_PACKAGES=(
    kanata-bin
    sesh-bin
)

log()  { echo "==> $*"; }
warn() { echo "!! $*" >&2; }

install_packages() {
    $SKIP_PACKAGES && { log "Skipping package install (--skip-packages)"; return; }

    if ! command -v pacman >/dev/null; then
        warn "pacman not found - skipping package install (not an Arch-based system?)"
        return
    fi

    log "Installing packages via pacman: ${PACMAN_PACKAGES[*]}"
    if $DRY_RUN; then
        echo "  [dry-run] sudo pacman -S --needed ${PACMAN_PACKAGES[*]}"
    else
        sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"
    fi

    local aur_helper=""
    if command -v yay >/dev/null; then
        aur_helper=yay
    elif command -v paru >/dev/null; then
        aur_helper=paru
    fi

    if [[ -n "$aur_helper" ]]; then
        log "Installing AUR packages via $aur_helper: ${AUR_PACKAGES[*]}"
        if $DRY_RUN; then
            echo "  [dry-run] $aur_helper -S --needed ${AUR_PACKAGES[*]}"
        else
            "$aur_helper" -S --needed "${AUR_PACKAGES[@]}"
        fi
    else
        warn "No AUR helper (yay/paru) found - install these manually: ${AUR_PACKAGES[*]}"
    fi
}

# Move anything already sitting at $dest out of the way so stow can take
# over, unless it's already a symlink pointing at this repo.
backup_conflicts() {
    local pkg_dir="$1"
    while IFS= read -r -d '' src; do
        local rel="${src#"$pkg_dir"/}"
        local dest="$HOME/$rel"

        if [[ -L "$dest" ]]; then
            [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]] && continue
        elif [[ ! -e "$dest" ]]; then
            continue
        fi

        log "Backing up existing $dest"
        if ! $DRY_RUN; then
            mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
            mv "$dest" "$BACKUP_DIR/$rel"
        fi
    done < <(find "$pkg_dir" -type f -print0)
}

stow_package() {
    local pkg="$1"
    local pkg_dir="$REPO_DIR/$pkg"
    [[ -d "$pkg_dir" ]] || { warn "No such package: $pkg"; return 1; }

    log "Stowing package: $pkg"
    backup_conflicts "$pkg_dir"

    if $DRY_RUN; then
        stow -n -v -d "$REPO_DIR" -t "$HOME" "$pkg"
    else
        stow -v -d "$REPO_DIR" -t "$HOME" "$pkg"
    fi
}

main() {
    install_packages

    local packages=("${ONLY_PACKAGES[@]}")
    if [[ ${#packages[@]} -eq 0 ]]; then
        while IFS= read -r -d '' d; do
            packages+=("$(basename "$d")")
        done < <(find "$REPO_DIR" -mindepth 1 -maxdepth 1 -type d -not -name ".git" -print0 | sort -z)
    fi

    if ! command -v stow >/dev/null; then
        warn "stow is not installed - re-run without --skip-packages, or install it yourself, then re-run this script"
        exit 1
    fi

    for pkg in "${packages[@]}"; do
        stow_package "$pkg"
    done

    echo
    if [[ -d "$BACKUP_DIR" ]]; then
        log "Done. Pre-existing files were backed up to: $BACKUP_DIR"
    else
        log "Done. Nothing needed backing up."
    fi
    log "Reminder: enable the tracked user services with:"
    echo "    systemctl --user enable --now voxtype.service kanata.service"
}

main
