#!/usr/bin/env bash
# Add a new email account to the registry
# Usage: add-account.sh <email> <role>
# role: "primary" or "burner"
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$DIR/emails.json"
EMAIL="$1"; ROLE="$2"
# Check if already exists
EXISTS="$(jq -r --arg email "$EMAIL" '.accounts | has($email)' "$FILE")"
if [ "$EXISTS" = "true" ]; then
  echo "Already exists: $EMAIL"
  exit 1
fi
jq --arg email "$EMAIL" --arg role "$ROLE" \
  '.accounts[$email] = {"role": $role, "services": {}, "log": []}' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
echo "Added $EMAIL ($ROLE)"
