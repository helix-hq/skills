# helix-hq/skills

Public OpenClaw agent skills. Managed via `install.json` + `install.sh` for symlink-based deployment.

## Setup

```bash
git clone https://github.com/helix-hq/skills.git ~/skills/public
cd ~/skills/public
./install.sh
```

## Structure

Each skill lives in its own directory with a `SKILL.md`:

```
skills/
├── install.json      # Maps skills → agent targets
├── install.sh        # Creates symlinks from install.json
├── skill-manager/    # Meta-skill for creating & managing skills
│   └── SKILL.md
└── ...
```

## Adding Skills

See the `skill-manager` skill for the full workflow.
