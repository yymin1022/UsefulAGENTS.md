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