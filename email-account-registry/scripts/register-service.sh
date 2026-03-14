#!/usr/bin/env bash
# Register service usage for an email
# Usage: register-service.sh <email> <service-url> <notes>
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$DIR/emails.json"
EMAIL="$1"; URL="$2"; NOTES="$3"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
jq --arg email "$EMAIL" --arg url "$URL" --arg ts "$TS" --arg notes "$NOTES" \
  '.accounts[$email].services[$url].log += [{"timestamp": $ts, "notes": $notes}]' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
echo "Logged $EMAIL → $URL"
