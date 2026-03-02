# ------------------------
# Homebrew
# ------------------------
export PATH="/opt/homebrew/bin:$PATH"

# ------------------------
# pyenv 설정
# ------------------------
# pyenv 설정 무조건 실행하지 말고, .venv 활성화 시엔 생략

if [[ -z "$VIRTUAL_ENV" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"

  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
  fi
fi

# ------------------------
# Android SDK
# ------------------------
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/emulator"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"

# ------------------------
# Oh My Zsh
# ------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="aussiegeek"
plugins=(git python zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ------------------------
# Git & NPM Aliases
# ------------------------
alias v="nvim"
alias z="v ~/.zshrc"
alias zz="zellij"
alias cc="claude --chrome"
alias cr="claude -r"
alias cm="claude-monitor"
alias nrt="npm run test"
alias wta="worktree_add"
alias wtr="git worktree remove"
alias wtrf="git worktree remove -f"
alias gr="git rm --cached"
alias nr="npm run"
alias gptc="git commit"
alias gstt="git stash"
alias re="omz reload"
alias grim="git rebase -i main"
alias gcma="git commit --amend"
alias grc="git rebase --continue"
alias gss="git stash save"
alias grid="git rebase -i dev"
alias gg="git log --oneline"
alias gpfo="git push -f origin"
alias gbda="git branch | grep -v 'main' | grep -v 'dev' | xargs git branch -D"
alias gbm="git branch -m"
alias gl="git pull"
alias glo="git pull origin"
alias gp="git push"
alias gpo="git push origin"
alias git-already="git rm -r --cached"
alias nrd="npm run dev"
alias nrb="npm run build"
alias nrs="npm run start"
alias ni="npm install"
alias nid="npm install -D"
alias gwta='git worktree add'
alias gwtr='git worktree remove'
alias gsw='git switch'
alias gswc='git switch -c'
alias grs='git restore --staged'
alias kp='lsof -nP -iTCP:3000-3010 -sTCP:LISTEN | tail -n +2 | awk '"'"'{print $2}'"'"' | sort -u | xargs kill -9'

# ------------------------
# Secrets (별도 파일에서 로드)
# ------------------------
[[ -f "$HOME/.secrets.zsh" ]] && source "$HOME/.secrets.zsh"

# ------------------------
# Python & Conda 설정
# ------------------------
export PATH="$PATH:$HOME/toy/Python"

__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# ------------------------
# OpenJDK
# ------------------------
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

# ------------------------
# Bun
# ------------------------
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ------------------------
# pipx 경로
# ------------------------
export PATH="$PATH:$HOME/Library/Python/3.10/bin"
export PATH="$PATH:$HOME/.local/bin"

# ------------------------
# nvm
# ------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ------------------------
# ffmpeg to GIF
# ------------------------
function makegif() {
  ffmpeg -y -i $1 -vf fps=30,scale=320:-1:flags=lanczos,palettegen palette.png
  ffmpeg -y -i $1 -i palette.png -filter_complex "fps=30,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse" $1.gif
}

# -------------------------
# create tool
# -------------------------
function create() {
  local tool_name="$1"
  local tool_path="$HOME/tools/${tool_name}.sh"

  if [[ -z "$tool_name" ]]; then
    echo "Usage: create [tool name]"
    return 1
  fi

  if [[ -e "$tool_path" ]]; then
    echo "Already exists: $tool_path"
    return 1
  fi

  cat <<EOF > "$tool_path"
#!/bin/bash
# title: ${tool_name}
# desc:

EOF

  chmod +x "$tool_path"
  echo "Created: $tool_path"
  code "$tool_path"
}

# -------------------------
# tool selector (fzf)
# -------------------------
function tool() {
  local scripts=()
  local mapfile

  while IFS= read -r -d '' file; do
    title=$(grep -m 1 "^# title:" "$file" | sed 's/^# title: //')
    desc=$(grep -m 1 "^# desc:" "$file" | sed 's/^# desc: //')
    display="${title:-$(basename "$file")}: ${desc:-No description}"
    scripts+=("$display#$file")
  done < <(find "$HOME/tools" -type f -name "*.sh" -print0)

  selected=$(printf "%s\n" "${scripts[@]}" | fzf --prompt="Select tool: " --with-nth=1 --delimiter="#" --height=40%)
  script_path="${selected#*#}"

  if [[ -n "$script_path" ]]; then
    echo "Running: $script_path"
    bash "$script_path"
  fi
}

# ------------------------
# worktree add
# ------------------------
worktree_add() {
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "Usage: worktree_add <branch-name>"
    return 1
  fi

  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -z "$git_root" ]]; then
    echo "Not inside a git repository."
    return 1
  fi

  local worktree_root="$git_root/worktree"
  local full_path="$worktree_root/$name"

  if [[ ! -d "$worktree_root" ]]; then
    echo "Creating worktree directory at: $worktree_root"
    mkdir -p "$worktree_root"
  fi

  mkdir -p "$(dirname "$full_path")"

  echo "Adding worktree: $full_path -> $name"
  git -C "$git_root" worktree add "$full_path" "$name"
}

# ------------------------
# requirements.txt 자동 동기화
# ------------------------
get_project_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

sync_requirements_if_ready() {
  if [[ -z $CONDA_DEFAULT_ENV ]]; then return; fi
  local root
  root=$(get_project_root) || return
  if [[ -f $root/environment.yml ]]; then
    echo "[sync] $root/requirements.txt updating..."
    conda env export --no-builds | sed '/^prefix:/d' | grep -E '^- ' | sed 's/^- //' > $root/requirements.txt
  fi
}

# ------------------------
# 최종 PATH 정리
# ------------------------
PATH=~/.console-ninja/.bin:$PATH
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# autocomplete tab key binding
bindkey '^I' autosuggest-accept

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# strix
export PATH="$HOME/.strix/bin:$PATH"
export PATH=$PATH:$HOME/.maestro/bin

# ------------------------
# Stitch MCP 재인증
# ------------------------
stitch() {
  local project="${1:-avocadic}"

  echo "Stitch MCP re-auth starting..."
  echo "Project: $project"

  local token
  token=$(gcloud auth print-access-token 2>/dev/null)

  if [[ -z "$token" ]]; then
    echo "Token generation failed. Run gcloud auth login first."
    return 1
  fi

  claude mcp remove stitch -s user 2>/dev/null

  claude mcp add stitch \
    --transport http https://stitch.googleapis.com/mcp \
    --header "Authorization: Bearer $token" \
    --header "X-Goog-User-Project: $project" \
    -s user

  if [[ $? -eq 0 ]]; then
    echo "Stitch MCP re-auth complete!"
  else
    echo "Stitch MCP add failed"
    return 1
  fi
}

# ------------------------
# fzf
# ------------------------
eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/fzf-git.sh/fzf-git.sh
bindkey -r "^G"

# --- fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ---- Eza (better ls) -----
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"

# thefuck alias
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh --cmd cd)"
