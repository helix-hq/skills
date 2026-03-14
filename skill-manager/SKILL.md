---
name: skill-manager
description: "Create, organize, and deploy skills across public/private repos with proper symlink management. Use when creating new skills, moving existing skills into repos, or updating skill deployment mappings."
metadata:
  openclaw:
    emoji: "📦"
    requires:
      bins: ["jq", "gh"]
---

# Skill Manager

Manages the lifecycle of OpenClaw skills across two Git repositories:

- **Public:** `~/skills/public` → `helix-hq/skills` (GitHub, public)
- **Private:** `~/skills/private` → `helix-hq/skills-private` (GitHub, private)

Both repos use `install.json` + `install.sh` to symlink skills into agent workspaces.

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

### Step 4: Update install.json

Add the skill to the repo's `install.json` with the appropriate target(s):

```json
{
  "skills": {
    "<skill-name>": ["helix"]
  }
}
```

Available targets (defined in `install.json` → `targets`):
- `helix` → `~/.openclaw/workspace/skills` (main agent)
- `agents` → `~/.openclaw/workspace/.agents/skills` (shared agent skills)

Add additional targets as new agents are configured.

### Step 5: Run the Install Script

```bash
cd ~/skills/public   # or ~/skills/private
./install.sh
```

This creates symlinks so OpenClaw discovers the skill.

### Step 6: Commit, Push, and Report

**Every change MUST be committed and pushed immediately:**

```bash
cd ~/skills/public  # or ~/skills/private
git add -A
git commit -m "<meaningful commit message describing the change>"
git push
```

After pushing, provide the user with a link to the latest commit:

```bash
# Get the commit URL
COMMIT=$(git rev-parse HEAD)
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
echo "https://github.com/$REPO/commit/$COMMIT"
```

**Always share this link with the user** so they can review the change.

## Moving Existing Skills

To migrate a skill from the workspace into a repo:

1. Ask public or private
2. Move (not copy) the skill directory into the correct repo
3. Update `install.json` in the repo
4. Run `./install.sh` to create the symlink back
5. Verify the symlink works: `ls -la ~/.openclaw/workspace/skills/<skill-name>`
6. Commit, push, and share the link

## Updating a Skill

When modifying an existing managed skill:

1. Edit files directly in `~/skills/public/<skill>` or `~/skills/private/<skill>` (the symlinks point here)
2. If the skill's target agents changed, update `install.json` and re-run `./install.sh`
3. Commit, push, and share the link

## Rules

- **Never create skills directly in `~/.openclaw/workspace/skills/`** — always use the repo
- **Always commit + push after every change** — no uncommitted skill work
- **Always share the commit link** — the user should be able to verify every change
- **Ask before making public** — when in doubt, default to private
- **One skill per directory** — each skill gets its own folder with a `SKILL.md`
- **Keep install.json in sync** — if a skill exists in the repo, it should be in install.json
