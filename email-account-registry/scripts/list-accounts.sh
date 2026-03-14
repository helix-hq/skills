#!/usr/bin/env bash
# List all email accounts with role and usage status
DIR="$(cd "$(dirname "$0")/.." && pwd)"
jq '.accounts | to_entries[] | {email: .key, role: .value.role, service_count: (.value.services | length), log_count: (.value.log | length), unused: ((.value.services | length) == 0 and (.value.log | length) == 0)}' "$DIR/emails.json"
