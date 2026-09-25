#!/bin/bash
set -e

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULE_FILE="$CUR_DIR/RULES.md"

if [ ! -f "$RULE_FILE" ]; then
  echo "No rule file found: $RULE_FILE"
  exit 1
fi