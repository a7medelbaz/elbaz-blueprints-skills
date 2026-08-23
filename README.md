# elbaz-blueprints

Ahmed Elbaz's personal library of [agent skills](https://skills.sh), distributed via
[skills.sh](https://skills.sh).

## Install

```bash
# Install all skills
npx skills add ahmed-elbaz/elbaz-blueprints

# Install one specific skill
npx skills add ahmed-elbaz/elbaz-blueprints --skill scaffolding-flutter-mvvm

# Install for a specific agent
npx skills add ahmed-elbaz/elbaz-blueprints --skill scaffolding-flutter-mvvm --agent claude-code

# Install globally
npx skills add ahmed-elbaz/elbaz-blueprints --global
```

## Structure

```
elbaz-blueprints/
├── README.md
├── LICENSE
├── .gitignore
├── skills.sh.json          ← registers this package on skills.sh
├── docs/                   ← internal guides for building skills in this repo
│   ├── CREATE_SKILL.md
│   └── SKILL_PROMPT.md
└── skills/
    ├── flutter/
    │   └── scaffolding-flutter-mvvm/
    │       ├── SKILL.md
    │       ├── reference/
    │       └── scripts/
    └── odoo/
        └── (coming soon)
```

## Skills

| Skill | Domain | Description |
|---|---|---|
| [scaffolding-flutter-mvvm](skills/flutter/scaffolding-flutter-mvvm/SKILL.md) | Flutter | Scaffolds Flutter projects with MVVM + BLoC (Cubit) architecture — core infrastructure, feature skeletons, Android flavors, DI, routing, error handling, and theming. |

## Adding a new skill

See [docs/CREATE_SKILL.md](docs/CREATE_SKILL.md) for the authoritative reference on
building an agent skill, and [docs/SKILL_PROMPT.md](docs/SKILL_PROMPT.md) for a
ready-to-use prompt.

1. Build and test the skill locally in `.claude/skills/` (Claude Code's skill directory).
2. Once ready, copy it into the correct domain folder under `skills/`.
3. Register it in `skills.sh.json`.
4. Commit and push — skills.sh syncs automatically from GitHub.

**Rules:**
- Never modify `skills.sh.json` without also having the skill folder present.
- Always keep the skill folder name identical to the `"name"` field in `skills.sh.json`.
- `skills/` is the published source — `.claude/skills/` is the local dev sandbox.

## License

[MIT](LICENSE)
