#!/usr/bin/env bash
# Find the first available (unused) burner email
DIR="$(cd "$(dirname "$0")/.." && pwd)"
jq -r '[.accounts | to_entries[] | select(.value.role == "burner" and (.value.services | length) == 0 and (.value.log | length) == 0) | .key] | first // "none"' "$DIR/emails.json"
