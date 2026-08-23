# elbaz-blueprints

Ahmed Elbaz's personal library of [agent skills](https://skills.sh), distributed via
[skills.sh](https://skills.sh).

## Install

```bash
# Install all skills
npx skills add ahmed-elbaz/elbaz-blueprints

# Install one specific skill
npx skills add ahmed-elbaz/elbaz-blueprints --skill bootstrapping-flutter-mvvm

# Install for a specific agent
npx skills add ahmed-elbaz/elbaz-blueprints --skill bootstrapping-flutter-mvvm --agent claude-code

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
    │   └── bootstrapping-flutter-mvvm/
    │       ├── SKILL.md
    │       ├── reference/
    │       └── scripts/
    └── odoo/
        └── (coming soon)
```

## Skills

| Skill | Domain | Description |
|---|---|---|
| [bootstrapping-flutter-mvvm](skills/flutter/bootstrapping-flutter-mvvm/SKILL.md) | Flutter | Scaffolds Flutter projects with MVVM + BLoC (Cubit) architecture — core infrastructure, feature skeletons, Android flavors, DI, routing, error handling, and theming. |

## Flutter

### bootstrapping-flutter-mvvm

Why it matters: turns a blank Flutter project into a production-ready MVVM + BLoC codebase in one command — the boring, error-prone setup that's identical on every project, done once, correctly, every time.

**Builds:**
- MVVM + BLoC (Cubit) architecture — `core/` (config, DI, router, error, theme, utils) + `features/`
- DI via `get_it`
- Routing — named routes or `go_router`
- Theming — shade-scale color palette, parameterized text styles, dark/light `ThemeData`, locale-aware fonts (`--fonts=ar:Tajawal,en:Manrope` by default)
- Assets — images/svgs/fonts registered in `pubspec.yaml`
- Localization via `easy_localization`, wired end-to-end
- Error handling (`AppError` / `ErrorHandler`)
- Android dev/prod flavors, CI workflow, `.env` config, Makefile

**Use it effectively:**
- Always run `--dry-run` first — it reports what exists and what's missing, writes nothing
- Review that report, then apply for real
- Safe on an existing project — it never overwrites a file that's already there; it only fills in what's missing
- A second script scaffolds individual feature folders on top of an already-bootstrapped project

Full usage: [skills/flutter/bootstrapping-flutter-mvvm/SKILL.md](skills/flutter/bootstrapping-flutter-mvvm/SKILL.md)

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
