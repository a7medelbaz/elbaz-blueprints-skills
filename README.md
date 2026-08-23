# elbaz-blueprints

Ahmed Elbaz's personal library of [agent skills](https://skills.sh), distributed via
[skills.sh](https://skills.sh).

## Install

```bash
# Install all skills
npx skills add ahmed-elbaz/elbaz-blueprints

# Install one specific skill
npx skills add ahmed-elbaz/elbaz-blueprints --skill bootstrapping-flutter-mvvm
npx skills add ahmed-elbaz/elbaz-blueprints --skill initing-claude

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
├── guides/                 ← human-readable explainers (not read by Claude, written for people browsing this repo)
│   ├── flutter/
│   │   └── bootstrapping-flutter-mvvm/
│   │       ├── README.md    ← everything the skill does, in plain language
│   │       └── flavors.md
│   ├── general/
│   │   └── initing-claude/
│   │       └── README.md    ← everything the skill does, in plain language
│   └── odoo/
│       └── (coming soon)
└── skills/
    ├── flutter/
    │   └── bootstrapping-flutter-mvvm/
    │       ├── SKILL.md
    │       ├── reference/
    │       └── scripts/
    ├── general/
    │   └── initing-claude/
    │       ├── SKILL.md
    │       └── reference/
    └── odoo/
        └── (coming soon)
```

## Skills

| Skill | Domain | Description |
|---|---|---|
| [bootstrapping-flutter-mvvm](skills/flutter/bootstrapping-flutter-mvvm/SKILL.md) | Flutter | Scaffolds Flutter projects with MVVM + BLoC (Cubit) architecture — core infrastructure, feature skeletons, Android flavors, DI, routing, assets, localization, error handling, and theming. |
| [initing-claude](skills/general/initing-claude/SKILL.md) | General | Generates or hardens a project's `CLAUDE.md` for any language/framework — detects the stack, fetches its current official docs, and writes strict, specific Do/Don't rules grounded in what was actually fetched or observed, never memorized. |

## Flutter

### bootstrapping-flutter-mvvm

Why it matters: turns a blank Flutter project into a production-ready MVVM + BLoC codebase in one command — the boring, error-prone setup that's identical on every project, done once, correctly, every time.

**Builds:**
- MVVM + BLoC (Cubit) architecture — `core/` (config, DI, router, error, theme, utils) + `features/`
- DI via `get_it`
- Routing — named routes or `go_router`
- Theming — shade-scale color palette (`AppColors`), a fixed size × weight text-style matrix (`AppTextStyles` + `AppFontWeight`), a 17-field semantic `CustomColors` (animated light/dark via `ThemeExtension`), fully themed `ThemeData` for both brightnesses
- Locale-aware fonts — `--fonts=en:Manrope,ar:Tajawal` by default, switches automatically at runtime based on the app's locale; `AppFontFamily` constants are generated from whatever mapping you actually choose, not hardcoded
- Assets — `images/`/`svgs/`/`translations/` registered folder-level in `pubspec.yaml`; fonts registered per-family with real `Regular`/`Bold` entries (the actual `.ttf` files are a manual download-and-place step — see the skill's `theming.md#fonts`)
- Localization via `easy_localization`, wired end-to-end
- Error handling (`AppError` / `ErrorHandler`)
- Android dev/prod flavors ([how they work, and the tradeoffs vs. a JSON/YAML-driven approach](guides/flutter/bootstrapping-flutter-mvvm/flavors.md)), `.env` config, Makefile

Full plain-language explanation of everything this skill does: [`guides/flutter/bootstrapping-flutter-mvvm/README.md`](guides/flutter/bootstrapping-flutter-mvvm/README.md)

**Use it effectively:**
- Always run `--dry-run` first — it reports what exists and what's missing, writes nothing
- Review that report, then apply for real
- Safe on an existing project — it never overwrites a file that's already there; it only fills in what's missing
- A second script scaffolds individual feature folders on top of an already-bootstrapped project

Full usage: [skills/flutter/bootstrapping-flutter-mvvm/SKILL.md](skills/flutter/bootstrapping-flutter-mvvm/SKILL.md)

## General

### initing-claude

Why it matters: a `CLAUDE.md` is only as good as it is specific and current — generic advice ("write clean code," "follow best practices") is worthless, and rules copied from a framework's docs six months ago are actively wrong once that framework moves on. This skill fixes both problems at generation time, for any stack, not just the ones it ships examples for.

**Does:**
- Detects the project's stack from its manifest file (`pubspec.yaml`, `package.json`, `requirements.txt`, `go.mod`, `Gemfile`, `composer.json`, `pom.xml`/`build.gradle`, `*.csproj`, `Cargo.toml`, `mix.exs`, ...) — and for JS/Python in particular, inspects dependencies to identify the actual framework (React vs. Next.js vs. Vue, Django vs. Flask vs. FastAPI, etc.); also checks for an existing `AGENTS.md`/Cursor/Copilot rules and imports rather than duplicates them
- Fetches that framework's **current** official docs — a built-in map of known doc roots for common stacks, falling back to a live search for anything not in the map
- Writes `CLAUDE.md` in a fixed six-section template (Project Overview, Architecture, Tech Stack, Conventions, Do, Don't) — every `Do`/`Don't` rule traceable to something it actually found in the codebase or actually fetched, never asserted from memory
- Writes every rule the way Claude Code's own docs say actually gets followed: under ~200 lines total, checkable rather than vague, a one-clause reason on non-obvious rules, emphasis spent sparingly
- On a project that **already has** a `CLAUDE.md`, tells apart two kinds of update from what was actually said, no clarifying question first: a named mistake triggers **Rule-addition** (picks the right mechanism — CLAUDE.md rule vs. a hook vs. a path-scoped rule vs. a skill — then adds exactly one line if CLAUDE.md fits); anything else (a plain "update it," a new feature) triggers **Refresh** (re-scans the codebase and updates only the factual sections — Project Overview/Architecture/Tech Stack/Conventions — leaving Do/Don't untouched)

Full plain-language explanation of everything this skill does: [`guides/general/initing-claude/README.md`](guides/general/initing-claude/README.md)

**Use it effectively:**
- First run on a project (no `CLAUDE.md` yet) does the full analysis — expect it to take longer than `/init`, since it's actually fetching current documentation, not just reading the repo
- Every run after that should be the update flow — one mistake, one rule, immediately, rather than batching fixes
- Requires live web access (`WebFetch`/`WebSearch`) to do its job properly — it's built for Claude Code, not environments without network access

Full usage: [skills/general/initing-claude/SKILL.md](skills/general/initing-claude/SKILL.md)

## Adding a new skill

See [docs/CREATE_SKILL.md](docs/CREATE_SKILL.md) for the authoritative reference on
building an agent skill, and [docs/SKILL_PROMPT.md](docs/SKILL_PROMPT.md) for a
ready-to-use prompt.

1. Build and test the skill locally in `~/.claude/skills/<name>/` (Claude Code's **global** skill directory — this repo does not use a project-local `.claude/skills/`).
2. Once ready, copy it into the correct domain folder under `skills/`.
3. Register it in `skills.sh.json`.
4. Commit and push — skills.sh syncs automatically from GitHub.

**Rules:**
- Never modify `skills.sh.json` without also having the skill folder present.
- Always keep the skill folder name identical to the `"name"` field in `skills.sh.json`.
- `skills/` is the published source — `~/.claude/skills/` is the local dev sandbox.

## License

[MIT](LICENSE)
