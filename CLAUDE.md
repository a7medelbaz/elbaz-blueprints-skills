# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`elbaz-blueprints` is a personal library of [Agent Skills](https://agentskills.io), distributed via [skills.sh](https://skills.sh). It is not an application — there is no server, no runtime, no test suite. The deliverable is the `skills/` directory itself: `npx skills add ahmed-elbaz/elbaz-blueprints` clones this GitHub repo, reads `skills.sh.json`, and copies each listed skill folder into the installer's own Claude Code / claude.ai setup.

## Architecture

```
skills.sh.json           ← package manifest; MUST list every skill under skills/
skills/<domain>/<skill-name>/
  SKILL.md                ← frontmatter + instructions, what Claude reads when triggered
  reference/               ← deep-dive docs, linked one level deep from SKILL.md
  scripts/                 ← executed, not read; only their stdout enters context
```

`skills/` is the published source of truth. The local dev/test location is the **global** `~/.claude/skills/<name>/` — not a project-local `.claude/skills/`, which this repo deliberately does not use. Workflow: iterate in `~/.claude/skills/<name>/`, copy the finished folder into `skills/<domain>/<name>/`, register it in `skills.sh.json`, add a row to `README.md`, commit — then re-sync the global copy so it doesn't drift from the published version.

**Flagship skill — `bootstrapping-flutter-mvvm`:** scaffolds a Flutter MVVM + BLoC (Cubit) project. Its two scripts are Dart programs that write files to a target Flutter project elsewhere on disk — they are not Flutter/Flutter-app code themselves.
- `scripts/scaffold_project.dart` (~1,280 lines) — run from the directory that should *contain* the new project. Every generated file's content lives as a Dart string constant inside this one script (`_appColors`, `_appTextStyles`, `_appFonts`, `_themeDataLight`/`_themeDataDark`, `_appDart`, etc.) — to change what a scaffolded file contains, edit the matching constant here; there is no separate template file.
- `scripts/scaffold_feature.dart` (~80 lines) — run from an already-scaffolded project's root; creates only a feature's folder skeleton, writes no file contents by design.

Both are idempotent — `_writeFile` skips anything that already exists and reports it, never overwrites. `scaffold_project.dart` supports `--dry-run` (report-only, no writes, no `flutter`/network calls).

Two authoring standards govern everything else in this repo — read them before creating or editing any skill:
- `docs/CREATE_SKILL.md` — the full authoring reference (frontmatter rules, `${CLAUDE_SKILL_DIR}` path substitution, portability constraints, anti-patterns, shipping checklist). "Part 0" is specific to this repo's workflow and manifest rules.
- `docs/SKILL_PROMPT.md` — ready-to-paste prompts for building a new skill, auditing an existing one, and shipping it.

## Tech Stack

- Skill content: Markdown (`SKILL.md`, `reference/*.md`) — no build step.
- `bootstrapping-flutter-mvvm`'s scripts: Dart (`dart analyze`, `dart run`) — no `pubspec.yaml`/package manager for the scripts themselves, they're standalone Dart files.
- Verifying scaffold output requires a real Flutter SDK (`flutter analyze` on the generated project) — on this machine that's `/c/flutter`, not on PATH by default.
- Distribution: [skills.sh](https://skills.sh) CLI (`npx skills`), reading `skills.sh.json` from this repo's GitHub default branch. No npm package, no CI.

## Conventions

- Skill folder name, the `"name"` in `skills.sh.json`, and the `SKILL.md` frontmatter `name:` must be identical, always.
- Skill frontmatter published from this repo is restricted to the six fields the Agent Skills spec allows (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`) — Claude Code accepts more, but claude.ai/API uploads hard-error on anything else. Only break this for a skill that's explicitly Claude Code–only.
- Reference files stay one level deep from `SKILL.md` (never `SKILL.md → a.md → b.md`) and get a `## Contents` block once past 100 lines.
- A reference file documents how to *extend* what a script generates — it never restates the script's own generated code (that drifted into a real compile-error bug once already).

## Do

- Read `docs/CREATE_SKILL.md` and `docs/SKILL_PROMPT.md` before creating or editing any skill.
- Verify a `bootstrapping-flutter-mvvm` change for real, not just `dart analyze`:
  ```bash
  dart analyze skills/flutter/bootstrapping-flutter-mvvm/scripts/
  dart run skills/flutter/bootstrapping-flutter-mvvm/scripts/scaffold_project.dart myapp --routing=named --dry-run
  dart run skills/flutter/bootstrapping-flutter-mvvm/scripts/scaffold_project.dart myapp --routing=named
  cd myapp && flutter analyze   # the real, decisive check
  ```
  Then re-run the apply step a second time and diff `pubspec.yaml` / touched files against the pre-second-run copy — must be byte-identical (idempotency).
- After verifying, re-sync `~/.claude/skills/bootstrapping-flutter-mvvm/` from `skills/flutter/bootstrapping-flutter-mvvm/`.
- Check, on every change, that `skills.sh.json` and the `skills/` folder tree still agree — there is no CI here to catch a dangling manifest entry.
- Invoke a skill's scripts through `${CLAUDE_SKILL_DIR}` once installed, never a bare relative path.

## Don't

- Don't add a `skills.sh.json` entry without the matching `skills/<domain>/<name>/` folder existing, or vice versa — a dangling entry produces a broken install for a stranger with no way to debug it.
- Don't call `Process.run('flutter', ...)` directly — always go through the shared `_flutter()` helper. Flutter ships as `flutter.bat` on Windows, and `Process.run` without `runInShell: true` throws `ProcessException` even on a correct install (`CreateProcess` doesn't resolve `PATHEXT`).
- Don't match a `pubspec.yaml`'s `flutter:` section with `line.trim() == 'flutter:'` — a stock file also has an *indented* `flutter:` under `dependencies:` (the SDK declaration), and matching the trimmed line finds that one first and corrupts the file. Use `_findFlutterSectionIndex` (`line.trimRight() == 'flutter:'`, no leading-whitespace stripping) — `trimRight`, not `trim`, because `pubspec.yaml` has CRLF endings and a bare `==` would otherwise miss the trailing `\r`.
- Don't detect "has our fonts content already been inserted?" by searching for the line `# fonts:` — `flutter create`'s own stock `pubspec.yaml` ships a commented-out example fonts block containing that exact line, so it always false-matches. Key off something unique to this skill's own inserted content.
- Don't reorder the default font map casually — the first entry becomes `AppFonts.fallback` (used for any language not explicitly listed). It's deliberately `{'en': 'Manrope', 'ar': 'Tajawal'}` (English first) so unlisted, mostly-Latin-script languages fall back to Manrope, not Tajawal.
