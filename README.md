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
├── skill-manager/    # Meta-skill for creating & managing skills
│   └── SKILL.md
├── blog-writer/
│   └── SKILL.md
└── ...
```

## Adding Skills

See the `skill-manager` skill for the full workflow.
