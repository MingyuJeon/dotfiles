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

# --- Ghostty (font/appearance; also read by cmux) ---
echo "[ghostty]"
mkdir -p "$HOME/.config/ghostty"
link_file "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# --- cmux (macOS defaults) ---
echo "[cmux]"
bash "$DOTFILES_DIR/cmux/defaults.sh"

# --- Claude Code ---
echo "[claude]"
mkdir -p "$HOME/.claude"
link_file "$DOTFILES_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
claude_settings="$HOME/.claude/settings.json"
if [ -f "$claude_settings" ] && command -v jq >/dev/null 2>&1; then
  if jq -e '.statusLine' "$claude_settings" >/dev/null 2>&1; then
    echo "  statusLine already set in ~/.claude/settings.json"
  else
    tmp=$(mktemp)
    jq --arg cmd "$HOME/.claude/statusline-command.sh" \
      '.statusLine = {type: "command", command: $cmd}' "$claude_settings" > "$tmp" && mv "$tmp" "$claude_settings"
    echo "  Added statusLine to ~/.claude/settings.json"
  fi
else
  echo "  NOTE: add to ~/.claude/settings.json -> \"statusLine\": {\"type\": \"command\", \"command\": \"~/.claude/statusline-command.sh\"}"
fi

echo ""
echo "=== Done! ==="
echo ""
echo "Next steps:"
echo "  1. Fill in secrets: vim ~/.secrets.zsh"
echo "  2. Reload shell: source ~/.zshrc"
