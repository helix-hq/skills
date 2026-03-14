#!/usr/bin/env bash
# Look up which email was used for a service
# Usage: lookup-service.sh <service-url>
DIR="$(cd "$(dirname "$0")/.." && pwd)"
jq -r --arg url "$1" '[.accounts | to_entries[] | select(.value.services[$url]) | .key] | if length == 0 then "not found" else .[] end' "$DIR/emails.json"
