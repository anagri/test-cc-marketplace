#!/usr/bin/env bash
# Auto-format TypeScript/TSX files with npm run format

set -e

FILE_PATH="$1"
LOG_FILE="${CLAUDE_PROJECT_DIR}/agent-logs/plugin-hook-events.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Log script invocation
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script invoked: format-code.sh \"$FILE_PATH\"" >> "$LOG_FILE"

if [[ -z "$FILE_PATH" ]]; then
  echo "action: skip (no file path provided)" | tee -a "$LOG_FILE"
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  echo "action: skip (file not found: $FILE_PATH)" | tee -a "$LOG_FILE"
  exit 0
fi

# Check file extension: only .ts or .tsx
if [[ ! "$FILE_PATH" =~ \.(ts|tsx)$ ]]; then
  echo "action: skip (not TypeScript/TSX file: $FILE_PATH)" | tee -a "$LOG_FILE"
  exit 0
fi

# Format file with npm run format
echo "Formatting: $FILE_PATH" | tee -a "$LOG_FILE"
cd "${CLAUDE_PROJECT_DIR}" && npm run format "$FILE_PATH" 2>&1 | tee -a "$LOG_FILE"

echo "action: formatted ($FILE_PATH)" | tee -a "$LOG_FILE"
exit 0
