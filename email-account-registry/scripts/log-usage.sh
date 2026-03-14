#!/usr/bin/env bash
# Log non-service usage for an email
# Usage: log-usage.sh <email> <notes>
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$DIR/emails.json"
EMAIL="$1"; NOTES="$2"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
jq --arg email "$EMAIL" --arg ts "$TS" --arg notes "$NOTES" \
  '.accounts[$email].log += [{"timestamp": $ts, "notes": $notes}]' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
echo "Logged usage for $EMAIL"
