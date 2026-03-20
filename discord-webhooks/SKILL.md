---
name: discord-webhooks
description: "Send messages, embeds, polls, and files to Discord channels via webhook URLs. Use when asked to post to Discord via a webhook, build a webhook payload, send rich embeds, or interact with the Discord webhook API."
metadata:
  openclaw:
    emoji: "🪝"
    requires:
      bins: ["curl"]
---

# Discord Webhooks

Send messages to Discord channels using webhook URLs. No bot token needed — just a URL.

## Quick Start

Send a simple text message:

```bash
curl -H "Content-Type: application/json" \
  -d '{"content": "Hello from a webhook!"}' \
  "$WEBHOOK_URL"
```

The webhook URL looks like: `https://discord.com/api/webhooks/{id}/{token}`

A request body **must** contain at least one of: `content`, `embeds`, `poll`, or file attachments.

## Payload Structure

All fields are optional (but the body can't be empty):

```
username        — Override webhook display name (1–80 chars)
avatar_url      — Override webhook avatar (image URL)
content         — Text message (up to 2000 chars, supports Discord markdown)
tts             — Boolean, speaks the message aloud like /tts
embeds          — Array of embed objects (up to 10)
poll            — Poll object
allowed_mentions — Control who gets pinged
```

### allowed_mentions

```json
{
  "allowed_mentions": {
    "parse": ["roles", "users", "everyone"],
    "roles": ["role_id_1"],
    "users": ["user_id_1"]
  }
}
```

- `parse` array controls which mention types work. Empty array = no mentions.
- Use `roles`/`users` arrays for allowlisting specific IDs (remove the corresponding entry from `parse` when using these).

## Embeds

Rich embeds with color, images, fields, etc. Up to 10 per message.

```json
{
  "embeds": [{
    "color": 5814783,
    "author": {
      "name": "Author Name",
      "url": "https://example.com",
      "icon_url": "https://example.com/icon.png"
    },
    "title": "Embed Title",
    "url": "https://example.com",
    "description": "Supports **markdown**, *italic*, [links](https://example.com), `code`",
    "fields": [
      { "name": "Field 1", "value": "Value 1", "inline": true },
      { "name": "Field 2", "value": "Value 2", "inline": true },
      { "name": "Full Width", "value": "This field spans the full width" }
    ],
    "thumbnail": { "url": "https://example.com/thumb.png" },
    "image": { "url": "https://example.com/image.png" },
    "footer": {
      "text": "Footer text (no markdown)",
      "icon_url": "https://example.com/footer-icon.png"
    },
    "timestamp": "2025-01-15T12:00:00.000Z"
  }]
}
```

**Color:** Use decimal, not hex. Convert with: `echo $((16#5814FF))` → `5775615`

**Inline fields:** Up to 3 per row when `"inline": true`. The 4th wraps to the next line.

**Note:** Adding custom embeds overrides any automatic URL preview embeds.

## Polls

```json
{
  "poll": {
    "question": { "text": "Favorite language?" },
    "answers": [
      { "poll_media": { "text": "Python", "emoji": { "name": "🐍" } } },
      { "poll_media": { "text": "Rust", "emoji": { "name": "🦀" } } },
      { "poll_media": { "text": "TypeScript" } }
    ],
    "duration": 48,
    "allow_multiselect": true
  }
}
```

- Question: up to 300 chars
- Answers: 1–10 options, up to 55 chars each
- Duration: 1–768 hours (default 24)
- Emoji: use `"name"` for Unicode, `"id"` (as string) for custom server emoji
- Add `?wait=true` to the URL to get the message ID back (useful for checking results later)
- Polls **cannot** be closed via webhook — only the creator (user/bot) can close their own

## File Attachments

Switch to `multipart/form-data` and use `payload_json` for the JSON body:

```bash
curl \
  -F 'payload_json={"content": "Check these out!"}' \
  -F "file1=@photo.jpg" \
  -F "file2=@document.pdf" \
  "$WEBHOOK_URL"
```

- File field names must be unique (`file1`, `file2`, etc.)
- Up to 10 files per message

### Embed an attachment as an image

Use the `attachment://` protocol to reference uploaded files inside embeds:

```bash
curl \
  -F 'payload_json={"embeds": [{"image": {"url": "attachment://photo.jpg"}}]}' \
  -F "file1=@photo.jpg" \
  "$WEBHOOK_URL"
```

This hides the attachment from the message body and displays it inside the embed.

## Editing Messages

Edit a previously sent webhook message with `PATCH`:

```bash
curl -X PATCH \
  -H "Content-Type: application/json" \
  -d '{"content": "Updated text"}' \
  "$WEBHOOK_URL/messages/$MESSAGE_ID"
```

**Getting the message ID:** Append `?wait=true` when sending — the response JSON will include the message `id`.

**Gotchas:**
- Omitting `content`/`embeds` does NOT remove them. To clear, send `"content": ""` or `"embeds": []`.
- Attachments are **appended** on edit. To remove all, send `"attachments": []`.

## Rate Limits

**5 requests per 2 seconds** per webhook URL. Each webhook has its own independent limit.

Failed requests count toward the limit. Check response headers:

```
X-RateLimit-Remaining  — Requests left in current window
X-RateLimit-Reset-After — Seconds until the window resets
```

If `Remaining` hits 0, wait `Reset-After` seconds before the next request.

## Field Limits Reference

```
username            1–80 chars
content             2,000 chars
embeds              10 objects max
embed.title         256 chars
embed.description   4,096 chars
embed.author.name   256 chars
embed.fields        25 objects max
embed.field.name    256 chars
embed.field.value   1,024 chars
embed.footer.text   2,048 chars
files               10 max
Total embed text*   6,000 chars  (* title + description + author.name + footer.text + all field names/values)
```
