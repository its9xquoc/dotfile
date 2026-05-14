#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="symlink"

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: ./install.sh [--copy]"
      exit 1
      ;;
  esac
done

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    echo "Backed up existing $(basename "$target") -> $backup"
  fi
}

link_or_copy() {
  local source="$1"
  local target="$2"

  backup_if_exists "$target"

  if [[ "$MODE" == "copy" ]]; then
    cp -R "$source" "$target"
    echo "Copied $(basename "$source") -> $target"
  else
    ln -s "$source" "$target"
    echo "Symlinked $(basename "$source") -> $target"
  fi
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed"
    return
  fi

  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_iterm2() { brew install --cask iterm2; }
install_google_chrome() { brew install --cask google-chrome; }
install_alfred() { brew install --cask alfred; }
install_orbstack() { brew install --cask orbstack; }
install_tmux() { brew install tmux; }
install_zsh() { brew install zsh; }

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh already installed"
    return
  fi
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$custom_dir/plugins"

  [[ -d "$custom_dir/plugins/zsh-autosuggestions" ]] || git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions"
  [[ -d "$custom_dir/plugins/zsh-syntax-highlighting" ]] || git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom_dir/plugins/zsh-syntax-highlighting"
  [[ -d "$custom_dir/plugins/zsh-completions" ]] || git clone https://github.com/zsh-users/zsh-completions "$custom_dir/plugins/zsh-completions"
}

configure_zshrc() {
  local zshrc="$HOME/.zshrc"
  touch "$zshrc"

  if grep -q '^plugins=' "$zshrc"; then
    sed -i.bak 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' "$zshrc"
  else
    printf '\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)\n' >> "$zshrc"
  fi

  grep -q '^alias docker-compose="docker compose"' "$zshrc" || echo 'alias docker-compose="docker compose"' >> "$zshrc"
  grep -q '^alias dc="docker compose"' "$zshrc" || echo 'alias dc="docker compose"' >> "$zshrc"
}

install_aerospace() { brew install --cask nikitabobko/tap/aerospace; }

install_applications() {
  ensure_homebrew
  install_iterm2
  install_google_chrome
  install_alfred
  install_orbstack
  install_tmux
  install_zsh
  install_oh_my_zsh
  install_zsh_plugins
  configure_zshrc
  install_aerospace
}

install_vscode_settings() {
  mkdir -p "$HOME/Library/Application Support/Code/User"
  link_or_copy "$DOTFILES_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
}

install_vscode_extensions() {
  if ! command -v code >/dev/null 2>&1; then
    echo "VS Code CLI 'code' not found, skipping extension install"
    return
  fi
  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" ]] && continue
    code --install-extension "$extension" || true
  done < "$DOTFILES_DIR/vscode/list-extensions.txt"
}

install_dotfiles() {
  mkdir -p "$HOME/.config"
  link_or_copy "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
  link_or_copy "$DOTFILES_DIR/.aerospace.toml" "$HOME/.aerospace.toml"
  link_or_copy "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"
  install_vscode_settings
  install_vscode_extensions
}

install_fonts() {
  local fonts_dir="$DOTFILES_DIR/fonts"
  local target_dir="$HOME/Library/Fonts"

  if [[ ! -d "$fonts_dir" ]]; then
    echo "No fonts directory found at $fonts_dir, skipping"
    return
  fi

  mkdir -p "$target_dir"

  find "$fonts_dir" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0 | while IFS= read -r -d '' font_file; do
    local font_name
    font_name="$(basename "$font_file")"

    if [[ -f "$target_dir/$font_name" ]]; then
      echo "Font exists, skipping: $font_name"
      continue
    fi

    cp "$font_file" "$target_dir/$font_name"
    echo "Installed font: $font_name"
  done
}

main() {
  install_applications
  install_dotfiles
  install_fonts
  echo "Done. Restart tmux, Aerospace, VS Code, terminal, and apps using new fonts."
}

main
