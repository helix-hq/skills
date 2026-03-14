---
name: skill-manager
description: "Create, organize, and deploy skills across public/private repos. Use when creating new skills, moving existing skills into repos, or managing skill organization."
metadata:
  openclaw:
    emoji: "📦"
    requires:
      bins: ["gh"]
---

# Skill Manager

Manages the lifecycle of OpenClaw skills across two Git repositories:

- **Public:** `~/skills/public` → `helix-hq/skills` (GitHub, public)
- **Private:** `~/skills/private` → `helix-hq/skills-private` (GitHub, private)

Skills are discovered by OpenClaw via `skills.load.extraDirs` in `~/.openclaw/openclaw.json`.

## Creating a New Skill

### Step 1: Ask About Visibility

**ALWAYS ask the user** whether a new skill should be **public or private** before creating it, unless they already specified. This prevents accidentally publishing something sensitive.

### Step 2: Create the Skill Directory

Place the skill in the correct repo:

```bash
# Public skill
mkdir -p ~/skills/public/<skill-name>

# Private skill
mkdir -p ~/skills/private/<skill-name>
```

### Step 3: Write the SKILL.md

Every skill needs a `SKILL.md` at minimum. Follow the standard OpenClaw skill format:

```markdown
---
name: <skill-name>
description: "<one-line description of when to use this skill>"
metadata:
  openclaw:
    emoji: "<emoji>"
    requires:
      bins: ["<required-cli-tools>"]
---

# <Skill Name>

<Instructions for the agent on how to use this skill>
```

Add any supporting scripts, templates, or assets alongside it.

### Step 4: Commit, Push, and Report

**Every change MUST be committed and pushed immediately:**

```bash
cd ~/skills/public  # or ~/skills/private
git add -A
git commit -m "<meaningful commit message describing the change>"
git push
```

After pushing, provide the user with a link to the latest commit:

```bash
COMMIT=$(git rev-parse HEAD)
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
echo "https://github.com/$REPO/commit/$COMMIT"
```

**Always share this link with the user** so they can review the change.

## Moving Existing Skills

To migrate a skill from the workspace into a repo:

1. Ask public or private
2. Move (not copy) the skill directory into the correct repo
3. Commit, push, and share the link

## Updating a Skill

When modifying an existing managed skill:

1. Edit files directly in `~/skills/public/<skill>` or `~/skills/private/<skill>`
2. Commit, push, and share the link

## Rules

- **Never create skills directly in `~/.openclaw/workspace/skills/`** — always use the repo
- **Always commit + push after every change** — no uncommitted skill work
- **Always share the commit link** — the user should be able to verify every change
- **Ask before making public** — when in doubt, default to private
- **One skill per directory** — each skill gets its own folder with a `SKILL.md`
