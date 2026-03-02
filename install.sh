#!/bin/bash
# Dotfiles installer - creates symlinks from home directory to dotfiles repo

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Dotfiles Installer ==="
echo "Source: $DOTFILES_DIR"
echo ""

# Helper: create symlink with backup
link_file() {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Backing up existing $dst -> ${dst}.backup"
    mv "$dst" "${dst}.backup"
  elif [ -L "$dst" ]; then
    rm "$dst"
  fi

  ln -s "$src" "$dst"
  echo "  Linked: $dst -> $src"
}

# --- Zsh ---
echo "[zsh]"
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

# Create secrets file if not exists
if [ ! -f "$HOME/.secrets.zsh" ]; then
  cp "$DOTFILES_DIR/zsh/.secrets.zsh.example" "$HOME/.secrets.zsh"
  echo "  Created ~/.secrets.zsh from example - please fill in your secrets!"
fi

# --- Git ---
echo "[git]"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# --- Neovim ---
echo "[nvim]"
mkdir -p "$HOME/.config"
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  echo "  Backing up existing nvim config -> ~/.config/nvim.backup"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup"
elif [ -L "$HOME/.config/nvim" ]; then
  rm "$HOME/.config/nvim"
fi
ln -s "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
echo "  Linked: ~/.config/nvim -> $DOTFILES_DIR/nvim"

# --- Starship ---
echo "[starship]"
mkdir -p "$HOME/.config"
link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# --- Zellij ---
echo "[zellij]"
mkdir -p "$HOME/.config/zellij"
link_file "$DOTFILES_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"

echo ""
echo "=== Done! ==="
echo ""
echo "Next steps:"
echo "  1. Fill in secrets: vim ~/.secrets.zsh"
echo "  2. Reload shell: source ~/.zshrc"
