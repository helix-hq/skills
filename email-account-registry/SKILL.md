---
name: email-account-registry
description: Registry of primary and burner email accounts. Use when signing up for services, using a burner email, looking up which email was used for a service, finding an available burner email, or adding new email accounts. Manages a JSON registry of all email accounts with service associations and usage logs.
---

# Email Account Registry

JSON registry at `emails.json` (relative to this skill directory). All operations via shell scripts in `scripts/`.

## Schema

```json
{
  "accounts": {
    "email@example.com": {
      "role": "primary|burner",
      "services": {
        "https://service.com": {
          "log": [{ "timestamp": "ISO-8601", "notes": "why" }]
        }
      },
      "log": [{ "timestamp": "ISO-8601", "notes": "non-service usage" }]
    }
  }
}
```

## ⚠️ NEVER read `emails.json` directly — use the scripts. Ask the user for permission before reading the raw file under any circumstances.

## Scripts

All paths relative to this skill's directory. Scripts auto-resolve `emails.json` location.

| Script | Args | Description |
|---|---|---|
| `scripts/add-account.sh` | `<email> <role>` | Add a new email (role: `primary` or `burner`). Fails if already exists. |
| `scripts/list-accounts.sh` | none | List all accounts with role, service count, and unused status |
| `scripts/find-burner.sh` | none | Print first available (unused) burner email, or "none" |
| `scripts/register-service.sh` | `<email> <url> <notes>` | Log that an email was used to sign up for a service |
| `scripts/log-usage.sh` | `<email> <notes>` | Log non-service-specific usage of an email |
| `scripts/lookup-service.sh` | `<url>` | Find which email(s) were used for a given service URL |

## Workflow

1. **Signing up for a service:** Run `find-burner.sh` → use the returned email → run `register-service.sh` with the email, service URL, and notes.
2. **Non-service usage:** Run `log-usage.sh` with the email and notes.
3. **Checking history:** Run `list-accounts.sh` or `lookup-service.sh`.
