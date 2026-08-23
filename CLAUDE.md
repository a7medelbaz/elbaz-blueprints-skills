# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
`elbaz-blueprints` is Ahmed Elbaz's personal library of Claude Agent Skills, distributed via [skills.sh](https://skills.sh) (`npx skills add ahmed-elbaz/elbaz-blueprints`). Each skill is a `SKILL.md` package (plus optional scripts/reference files) that teaches Claude a repeatable workflow — currently `bootstrapping-flutter-mvvm` (Flutter/BLoC project scaffolding) and `initializing-claude-md` (this file's own generator).

## Architecture
- `skills/<domain>/<skill-name>/` — the published source of truth: `SKILL.md` (required), `reference/` (domain-split deep material, one level deep only), `scripts/` (executed, never read into context).
- `skills.sh.json` — package manifest; every skill folder must have a matching entry (`name`, `path`, `description`) and vice versa.
- `docs/` — internal authoring standard for this repo: `CREATE_SKILL.md` (authoritative reference, grounded in the Agent Skills spec and Claude Code docs) and `SKILL_PROMPT.md` (copy-paste prompts for build/audit/ship).
- `guides/<domain>/<skill-name>/` — human-readable explainers, not read by Claude, written for people browsing the repo on GitHub.
- `~/.claude/skills/<name>/` is the local dev sandbox for iterating on a skill before it is copied into `skills/`. The reverse sync (sandbox → repo) never happens automatically.

## Tech Stack
- Skill packages: YAML frontmatter + Markdown, following the [Agent Skills open spec](https://agentskills.io) (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`), with optional Claude Code–only extensions (`when_to_use`, `argument-hint`, `disable-model-invocation`, etc.).
- `bootstrapping-flutter-mvvm/scripts/`: Dart scaffolding scripts (`scaffold_project.dart`, `scaffold_feature.dart`), invoked via `dart run ${CLAUDE_SKILL_DIR}/scripts/<file>.dart`.
- No application build system in this repo itself — it ships instructions and scripts consumed by other projects.

## Conventions
- Skill names use gerund form (`bootstrapping-flutter-mvvm`, `initializing-claude-md`); stay consistent with this across new skills.
- The skill folder name, the `"name"` in `skills.sh.json`, and the `name:` in frontmatter must be identical.
- Bundled scripts are always referenced via `${CLAUDE_SKILL_DIR}/scripts/...` in `SKILL.md`, never a bare relative path — a skill installs to `~/.claude/skills/<name>/` while the working directory is the user's project.
- Reference files sit exactly one level below `SKILL.md` and document how to *extend* what a script generates — they never restate a script's own output (a duplicated code sample in `bootstrapping-flutter-mvvm` once drifted from the script and produced a compile error).
- Mutating/scaffolding scripts expose `--dry-run` and are documented as preflight → show the user → ask → apply, never applied blind.

## Do
- Restrict every published skill's frontmatter to the six spec fields (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`) unless a Claude Code–only field is required — and say so in its `README.md` row when it is.
- Write `description` in third person, stating both what the skill does and when to trigger it, with the key use case first (truncated at 1,536 chars in the skill listing).
- Reference bundled scripts through `${CLAUDE_SKILL_DIR}` in both the SKILL.md body and any `allowed-tools` Bash rule, so the script runs without a permission prompt.
- Keep `SKILL.md` under 500 lines; move overflow into `reference/`, and add a `## Contents` block to any reference file over 100 lines.
- Verify every documented API form/command against the actual source before writing it down — an unverified form in this repo's history did not compile.
- Register a new/changed skill in all three places together: `skills/<domain>/<name>/`, `skills.sh.json`, and the `README.md` table row.
- Actually execute a script (on the target OS) before reporting it works, and run mutating scripts twice to confirm idempotency — never report success from reading code.

## Don't
- Don't add a `skills.sh.json` entry without the matching folder under `skills/`, or vice versa — the installer trusts the manifest blindly.
- Don't write a Claude Code–only frontmatter field (`when_to_use`, `argument-hint`, `disable-model-invocation`, etc.) into a published skill without noting the tradeoff — it makes the skill fail with a hard error on claude.ai/Skills API upload.
- Don't nest reference files more than one level from `SKILL.md` (no `SKILL.md → a.md → b.md`) — Claude may partially read a nested file and act on incomplete information.
- Don't restate a script's generated code in a reference file — document how to extend it instead; the two will drift.
- Don't assume an external command resolves as a native binary on Windows (e.g. `flutter` is `flutter.bat`) — route through the shell (`runInShell: true` in Dart, or equivalent) rather than assuming `PATHEXT` is honored.
- Don't ship a scaffold/mutation script without a `--dry-run` mode, and don't apply it without showing the user the plan and getting confirmation first.
- Don't invent a rule for this repo's Do/Don't sections from memory of "how skills usually work" — trace it to `docs/CREATE_SKILL.md`, an actually-fetched doc page, or an actually-observed pattern in this repo.
