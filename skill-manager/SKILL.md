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

## Vendor Skills (Third-Party)

Third-party skill repos can be added as git submodules inside `vendors/`. A shared
script (`~/skills/link-vendors.sh`) copies the relevant skill directories into `_linked/`,
which OpenClaw scans via `extraDirs`.

### Why copies instead of symlinks?

OpenClaw resolves symlink realpaths and checks that they stay inside the configured
skill root. Symlinks pointing into `vendors/` resolve outside `_linked/`, so OpenClaw
rejects them. Copies live directly in `_linked/` and pass the check. Since vendor repos
are pinned to a commit via submodules, no "live edit" benefit is lost — just re-run the
script after `git submodule update` (the git hooks do this automatically).

### Directory layout

```
~/skills/public/              (or private/)
├── vendors.json              ← controls which skills get copied
├── vendors/                  ← git submodules (tracked by git)
│   └── some-repo/
│       └── skills/
│           ├── skill-a/SKILL.md
│           └── skill-b/SKILL.md
└── _linked/                  ← gitignored, auto-generated copies
    ├── skill-a/SKILL.md
    └── skill-b/SKILL.md
```

### vendors.json format

```json
{
  "some-repo": "*",
  "another-repo": ["only-this-skill", "and-this-one"]
}
```

- Key = folder name inside `vendors/`
- Value = `"*"` (all skills) or `["name", ...]` (explicit list matching folder names with SKILL.md)
- Vendors not listed in the config are **warned about** but skipped

### Adding a vendor skill

```bash
cd ~/skills/public  # or ~/skills/private
git submodule add <repo-url> vendors/<name>

# Edit vendors.json — add "<name>": "*" or a list of skill names

# Re-link (or let git hooks handle it on next commit)
~/skills/link-vendors.sh "$(pwd)"

git add vendors.json .gitmodules vendors/<name>
git commit -m "Add <name> vendor skills"
git push
```

### Updating a vendor to latest upstream

```bash
cd ~/skills/public/vendors/<name>
git pull origin main   # or the relevant branch
cd ../..
git add vendors/<name>
git commit -m "Update <name> vendor to latest"
git push
# post-commit hook auto-runs link-vendors.sh
```

### Customizing a vendor skill (forking)

If you need to modify a vendored skill:

1. Fork the upstream repo on GitHub
2. Update the submodule URL to your fork:
   ```bash
   git config --file=.gitmodules submodule.vendors/<name>.url <your-fork-url>
   git submodule sync
   cd vendors/<name>
   git remote set-url origin <your-fork-url>
   ```
3. Make changes on a branch, push to your fork
4. Commit the submodule pointer update in the parent repo

### Git hooks

Three hooks auto-run `link-vendors.sh` in both repos:
- `post-checkout` — after `git checkout` / `git switch`
- `post-merge` — after `git pull`
- `post-commit` — after every commit (catches submodule updates)

Hooks are in `.githooks/` and configured via `git config core.hooksPath .githooks`.

## Rules

- **Never create skills directly in `~/.openclaw/workspace/skills/`** — always use the repo
- **Always commit + push after every change** — no uncommitted skill work
- **Always share the commit link** — the user should be able to verify every change
- **Ask before making public** — when in doubt, default to private
- **One skill per directory** — each skill gets its own folder with a `SKILL.md`
- **Never edit files in `_linked/` directly** — they get wiped on every re-link; edit the vendor source or fork it
