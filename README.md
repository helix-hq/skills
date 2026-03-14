# helix-hq/skills

Public OpenClaw agent skills.

## Setup

1. Clone the repo:

```bash
git clone https://github.com/helix-hq/skills.git ~/skills/public
```

2. Add the directory to your OpenClaw config (`~/.openclaw/openclaw.json`):

```json5
{
  skills: {
    load: {
      extraDirs: ["~/skills/public"]
    }
  }
}
```

3. Restart the gateway for changes to take effect.

## Structure

Each skill lives in its own directory with a `SKILL.md`:

```
skills/
├── install.json      # Maps skills → agent workspace symlink targets
├── install.sh        # Creates symlinks from install.json (optional)
├── skill-manager/    # Meta-skill for creating & managing skills
│   └── SKILL.md
└── ...
```

## Symlink Install (Optional)

If you run multiple agents and want skills symlinked into specific workspace directories, you can use the included `install.json` + `install.sh`:

```bash
# Edit install.json to set your agent workspace paths under "targets"
# Then run:
./install.sh
```

This is optional — `extraDirs` is the primary discovery mechanism.

## Adding Skills

See the `skill-manager` skill for the full workflow.
