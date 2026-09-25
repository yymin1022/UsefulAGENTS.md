#!/bin/bash
set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULE_FILE="$CUR_DIR/RULES.md"

if [ ! -f "$RULE_FILE" ]; then
  echo "No rule file found: $RULE_FILE"
  exit 1
fi

echo "Installing global rules from: $RULE_FILE..."

# Function for linking rule file
# - ex) link_safely RULES.md ~/.codex/AGENTS.md codex
link_safely() {
  local src="$1"
  local dst="$2"
  local tool_name="$3"

  echo "[$tool_name] Installing..."

  # Check if already linked file exists
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "[$tool_name] Already linked: $dst"
    return 0
  fi

  # Check if other file exists
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "[$tool_name] File already exists, skipping: $dst"
    return 0
  fi

  # Generate updated symlink from src file
  ln -sf "$src" "$dst"
  echo "[$tool_name] Successfully linked: $dst"
}

### Generate for each tool
# 1. Claude Code (~/.claude/CLAUDE.md)
CLAUDE_NAME="Claude Code"
CLAUDE_DIR="$HOME/.claude"
if [ ! -d "$CLAUDE_DIR" ]; then
  mkdir -p "$CLAUDE_DIR"
fi
link_safely "$RULE_FILE" "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_NAME"

# 2. Codex (~/.codex/AGENTS.md & config.toml)
CODEX_NAME="Codex"
CODEX_DIR="$HOME/.codex"
if [ ! -d "$CODEX_DIR" ]; then
  mkdir -p "$CODEX_DIR"
fi
link_safely "$RULE_FILE" "$CODEX_DIR/AGENTS.md" "$CODEX_NAME"

CODEX_CONF="$CODEX_DIR/config.toml"
if [ -f "$CODEX_CONF" ]; then
  if grep -q "instructions_file" "$CODEX_CONF"; then
    echo "[Codex] instructions_file already configured in $CODEX_CONF"
  else
    echo "instructions_file = \"$CODEX_DIR/AGENTS.md\"" >> "$CODEX_CONF"
    echo "[Codex] Appended instructions_file to existing config: $CODEX_CONF"
  fi
else
  cat <<EOF > "$CODEX_CONF"
instructions_file = "$CODEX_DIR/AGENTS.md"

[tools]
auto_approve_readonly = true
disallowed_commands = ["git commit", "git push", "git rebase"]
EOF
  echo "[Codex] Created default config: $CODEX_CONF"
fi

# 3. Antigravity (~/.agent/AGENTS.md)
AGENT_NAME="Antigravity"
AGENT_DIR="$HOME/.agent"
if [ ! -d "$AGENT_DIR" ]; then
  mkdir -p "$AGENT_DIR"
fi
link_safely "$RULE_FILE" "$AGENT_DIR/AGENTS.md" "$AGENT_NAME"

echo "All global rules have been successfully installed."