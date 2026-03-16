---
name: blog-writer
description: Write, draft, and publish blog posts for blog.noahcardoza.com (Eleventy). Use when asked to write a blog post, create a draft, publish a draft, or brainstorm post ideas. Handles anonymization, code examples, frontmatter, and the draft→review→publish workflow.
---

# Blog Writer

## Blog Location

- **Source:** `~/services/blog/src/posts/`
- **Config:** `~/services/blog/eleventy.config.js`
- **URL:** `https://blog.noahcardoza.com`
- **Engine:** Eleventy 3 (ESM, Nunjucks templates)

## Post File Format

Filename: `YYYY-MM-DD-slug.md` in `~/services/blog/src/posts/`

Frontmatter:

```yaml
---
title: "Post Title"
date: YYYY-MM-DD
author: noah       # or "helix" for Helix-authored posts
excerpt: "One-line summary for index/meta"
tags:
  - tag1
  - tag2
draft: true        # omit or set false when publishing
---
```

## Draft Workflow

1. **Create draft:** Write the post with `draft: true` in frontmatter
2. **Commit & deploy:** Delegate to Ops — commit, push, let the blog rebuild
3. **Share preview link:** Send `https://blog.noahcardoza.com/posts/YYYY-MM-DD-slug/` — drafts render but don't appear in collections/index/RSS
4. **Revise:** Edit based on feedback, re-commit via Ops
5. **Publish:** Remove `draft: true` (or set `draft: false`), commit via Ops

Drafts double as idea stubs — create a minimal draft with a title and rough outline to capture context for later.

## Anonymization Rules

**Always apply these before committing any post:**

- **Paths:** Replace absolute paths with `~` or `$HOME` prefix. Keep directory/file names intact (readers should see the real hierarchy, just not the full root path). Example: `/Users/noah/services/blog/` → `~/services/blog/`
- **Hostnames & IPs:** Replace real hostnames/Tailscale node names with generic labels (`my-laptop`, `home-server`, `192.168.x.x`)
- **Emails:** Use placeholder emails unless the email is already public (e.g., a GitHub profile email is fine)
- **API keys / tokens / secrets:** Never include. Use `YOUR_API_KEY` or `<token>` placeholders
- **Usernames:** Keep public-facing usernames (GitHub handle, etc.). Redact internal/private ones
- **Personal info:** No home addresses, phone numbers, or private account IDs
- **Domain names:** Public domains the author owns (e.g., `noahcardoza.com`) are fine to include

**Do NOT rename directories or tools** — the structure and tool names are part of the story. Only strip identifying root paths and credentials.

## Writing Style

- **Noah-authored posts (`author: noah`):** Write in Noah's voice. All prose must match his natural style (see Prohibited Punctuation below)
- **Helix-authored posts (`author: helix`):** Write in Helix's natural voice. Technical but personable, observational, with dry humor
- **Voice:** First person. Noah = "I", Helix = "I" (from Helix's perspective). Joint posts can use "we"
- **Tone:** Technical but conversational. Like explaining to a sharp friend, not writing a textbook

### Prohibited Punctuation (ALL posts, ALL authors)

**Never use em dashes (`—`) or en dashes (`–`) in any blog post.** This is a hard rule, no exceptions.

Use these alternatives instead:
- Comma, colon, semicolon, or period to break clauses
- Parentheses for asides
- "which", "and", or other conjunctions to connect ideas
- Restructure the sentence if needed

Before handing any post to Ops, **grep the content for `—` and `–`** and fix every occurrence.
- **Length:** 800-2000 words typical. Go longer if the content demands it
- **Structure:** Natural flow. No formulaic "Problem → Solution → Results" arcs. Write like you're walking someone through what happened and why. Let sections emerge from the content, not a template
- **Headers:** Use `##` for main sections, `###` for subsections. Keep hierarchy flat. Headers should be descriptive and plain — not dramatic or clever. "Adding Draft Mode" not "The Draft Problem." Avoid single-word dramatic headers
- **Code examples:** Include real, working snippets. Anonymize per rules above. Use fenced code blocks with language tags

## Tags

Use existing tags when they fit. Check what's already in use:

```bash
grep -rh "^  - " ~/services/blog/src/posts/*.md | sort -u
```

Common tags: `meta`, `infrastructure`, `automation`, `ai`, `docker`, `email`, `security`, `tooling`

Create new tags sparingly — prefer broader categories.

## Authors

Two authors configured in `~/services/blog/src/_data/authors.json`:

- `noah` — default author
- `helix` — for posts primarily written by Helix

Set `author` in frontmatter accordingly. Most posts will be `noah` with Helix as a mentioned collaborator.

## Delegation

- **File writes in `~/services/blog/`** → delegate to Ops agent (services directory rule)
- **Git commit & push** → Ops
- **Reviewing/reading files** → can do directly
- **Generating post content** → do directly, then hand the content to Ops for writing to disk
- **ALWAYS rebuild the Docker container after any change.** The blog is static (no hot reload). After committing and pushing, Ops must run `cd ~/services/blog && docker compose up -d --build` or the changes will not be visible on the live site

## TLDR Toggle

Every post should include a TLDR toggle block between the frontmatter and the first paragraph. It uses paired Nunjucks shortcodes to render two views:

```nunjucks
{% tldrSlot "simple" %}
One paragraph, plain English. Written for family, friends, and non-technical readers who want to know what cool thing was built and why it matters. No jargon, no bullet points, no structure. Just a friendly summary of the problem and what changed. Keep it to a single paragraph.
{% endtldrSlot %}

{% tldrSlot "tech" %}
Structured summary for technical readers. Roughly **a tenth the length of the full article**. Use bolded keywords, bullet points, and clear sections. The Problem/Solution/Result pattern works well for infrastructure and ops posts, but use discretion based on the article type. The key principles:

- Break into labeled sections (bolded headers like **Problem:**, **Solution:**, **Result:** or whatever fits)
- One bullet per major topic/section of the article
- Bold key terms and tool names
- Skip the "lessons learned" / reflective sections
- Keep it scannable: a reader should be able to visually grep the key points in seconds
{% endtldrSlot %}

{% tldrToggle %}{% endtldrToggle %}
```

The shortcodes render Markdown content via markdown-it, so bold, links, code, and lists all work inside the slots.

## Checklist (before handing to Ops)

1. ☐ Frontmatter complete (title, date, author, excerpt, tags, draft)
2. ☐ Anonymization rules applied to all paths, hosts, credentials
3. ☐ Code examples tested/validated where possible
4. ☐ No PII leaks (grep for real paths, emails, IPs)
5. ☐ Slug matches filename date and title
6. ☐ No em dashes (`—`) or en dashes (`–`) anywhere in the post
7. ☐ TLDR toggle block present (simple + technical) between frontmatter and first paragraph
8. ☐ **Image/asset permissions:** Any files copied from `/tmp/`, inbound media, or other restrictive locations must be `chmod 644` (files) and `chmod 755` (directories) before committing. The blog builds into an nginx container, and files that are `600` (owner-only) will serve 403 Forbidden.
