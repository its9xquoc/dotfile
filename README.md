## Content
Setup and configuration for a new macOS dev environment with dotfiles and Homebrew packages.

## Applications
- [x] Homebrew
- [x] iTerm2
- [x] Google Chrome
- [x] Alfred
- [x] OrbStack
- [x] Tmux
- [x] Zsh
- [x] VS Code
- [x] Oh My Zsh
- [x] Aerospace

## Step-by-Step Installation
1. Clone this repository:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
```

2. Go to the project folder:
```bash
cd ~/.dotfiles
```

3. Make installer executable:
```bash
chmod +x install.sh
```

4. Install everything (applications + dotfiles, default symlink mode):
```bash
./install.sh
```

5. Install everything with copy mode for dotfiles:
```bash
./install.sh --copy
```

## Install Functions (inside `install.sh`)
- `ensure_homebrew`
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

- `install_iterm2`
```bash
brew install --cask iterm2
```

- `install_google_chrome`
```bash
brew install --cask google-chrome
```

- `install_alfred`
```bash
brew install --cask alfred
```

- `install_orbstack`
```bash
brew install --cask orbstack
```

- `install_tmux`
```bash
brew install tmux
```

- `install_zsh`
```bash
brew install zsh
```

- `install_oh_my_zsh`
```bash
RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- `install_zsh_plugins`
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
```

- `install_aerospace`
```bash
brew install --cask nikitabobko/tap/aerospace
```

- `install_vscode_settings`
```bash
# ~/Library/Application Support/Code/User/settings.json
```

- `install_vscode_extensions`
```bash
code --install-extension <extension-id>
# extension list source: vscode/list-extensions.txt
```

- `install_dotfiles`
```bash
# ~/.tmux.conf
# ~/.aerospace.toml
# ~/.config/tmux
# VS Code settings + extensions
```

## What Dotfiles Installation Does
- Installs `~/.tmux.conf` from `.tmux.conf`
- Installs `~/.aerospace.toml` from `.aerospace.toml`
- Installs `~/.config/tmux` from `tmux/`
- Installs VS Code settings to `~/Library/Application Support/Code/User/settings.json`
- Installs VS Code extensions from `vscode/list-extensions.txt` (if `code` CLI exists)
- Backs up existing target files with timestamp suffix

## Verify
```bash
ls -la ~/.tmux.conf ~/.aerospace.toml ~/.config/tmux
ls -la ~/Library/Application\ Support/Code/User/settings.json
```

## Apply Changes
- Tmux: inside tmux, run `prefix + r`
- Aerospace: restart Aerospace app
- VS Code: restart VS Code

## License
This project is licensed under the MIT License. Add a `LICENSE` file if needed.
