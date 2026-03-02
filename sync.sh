#!/bin/bash
# Dotfiles auto-sync: commit and push changes
# Triggered by launchd when files in ~/dotfiles change

DOTFILES_DIR="$HOME/dotfiles"
LOG_FILE="$DOTFILES_DIR/.sync.log"

cd "$DOTFILES_DIR" || exit 1

# Skip if no changes
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  exit 0
fi

# Check if remote is configured
if ! git remote get-url origin &>/dev/null; then
  echo "$(date): No remote configured, skipping push" >> "$LOG_FILE"
  git add -A
  git commit -m "dotfiles: auto-sync $(date '+%Y-%m-%d %H:%M')" --quiet
  exit 0
fi

git add -A
git commit -m "dotfiles: auto-sync $(date '+%Y-%m-%d %H:%M')" --quiet
git push --quiet 2>> "$LOG_FILE"

echo "$(date): synced" >> "$LOG_FILE"
