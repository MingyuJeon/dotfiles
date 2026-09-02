#!/bin/zsh
# Claude Code statusLine command
# Line 1: dir, branch, model, context %
# Line 2: ccusage (cost, billing reset)

export PATH="$HOME/.nvm/versions/node/v22.16.0/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

input=$(cat)

# --- Extract fields ---
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model_name=$(echo "$input" | jq -r '.model.display_name // ""')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
session_name=$(echo "$input" | jq -r '.session_name // ""')

# --- Git branch ---
git_branch=""
git_dirty=""
if [[ -n "$current_dir" ]] && cd "$current_dir" 2>/dev/null; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(git branch --show-current 2>/dev/null)
    [[ -n $(git --no-optional-locks status --porcelain 2>/dev/null) ]] && git_dirty="*"
  fi
fi

# --- Format directory (last folder only) ---
display_dir="${current_dir:t}"

# --- Version update check (cached, once per day) ---
version=$(echo "$input" | jq -r '.version // ""')
update_badge=""
cache_file="/tmp/claude-version-cache.json"
cache_ttl=86400  # 24 hours

check_update() {
  local now=$(date +%s)
  local cached_time=0
  local cached_ver=""

  if [[ -f "$cache_file" ]]; then
    cached_time=$(jq -r '.checked_at // 0' "$cache_file" 2>/dev/null)
    cached_ver=$(jq -r '.latest // ""' "$cache_file" 2>/dev/null)
  fi

  if (( now - cached_time >= cache_ttl )) || [[ -z "$cached_ver" ]]; then
    # Background update: don't block statusline
    (
      latest=$(npm view @anthropic-ai/claude-code version 2>/dev/null)
      if [[ -n "$latest" ]]; then
        echo "{\"latest\":\"${latest}\",\"checked_at\":${now}}" > "$cache_file"
      fi
    ) &
    # Use stale cache if available
    [[ -n "$cached_ver" ]] && echo "$cached_ver" || echo ""
  else
    echo "$cached_ver"
  fi
}

latest_ver=$(check_update)
if [[ -n "$latest_ver" ]] && [[ -n "$version" ]] && [[ "$latest_ver" != "$version" ]]; then
  update_badge="  ⬆ ${latest_ver}"
fi

# --- Build Line 1: session name, dir, branch, model, context % ---
line1="📁 ${display_dir}"
if [[ -n "$session_name" ]]; then
  (( ${#session_name} > 30 )) && session_name="${session_name[1,29]}…"
  line1+="  🏷️ ${session_name}"
fi
if [[ -n "$git_branch" ]]; then
  line1+="  🌿 ${git_branch}${git_dirty}"
fi
if [[ -n "$model_name" ]]; then
  line1+="  🤖 ${model_name}"
fi
if [[ -n "$remaining_pct" ]]; then
  remaining_int=$(printf "%.0f" "$remaining_pct")
  line1+="  🌱 ${remaining_int}%"
fi
if [[ -n "$update_badge" ]]; then
  line1+="${update_badge}"
fi

# --- Build Line 2: ccusage only ---
line2=""
ccusage_rc=1
if command -v ccusage >/dev/null 2>&1; then
  ccusage_out=$(echo "$input" | ccusage statusline --offline 2>/dev/null)
  ccusage_rc=$?
else
  ccusage_out=$(echo "$input" | npx --yes ccusage statusline --offline 2>/dev/null)
  ccusage_rc=$?
fi

if [[ $ccusage_rc -eq 0 ]] && [[ -n "$ccusage_out" ]] && [[ "$ccusage_out" != *"❌"* ]] && [[ "$ccusage_out" != *"Invalid"* ]]; then
  # Strip model name prefix and 🧠 token count section
  line2=$(echo "$ccusage_out" | sed 's/^[^|]*| //' | sed 's/ | 🧠[^|]*//')
fi

# --- Output ---
printf "%s" "$line1"
if [[ -n "$line2" ]]; then
  printf "\n%s" "$line2"
fi
printf "\n"
