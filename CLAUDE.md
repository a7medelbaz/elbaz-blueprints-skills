# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`elbaz-blueprints` is a personal library of [Agent Skills](https://agentskills.io), distributed via [skills.sh](https://skills.sh). It is not an application — there is no build, no server, no test suite in the conventional sense. The deliverable is the `skills/` directory itself: anyone can install it with `npx skills add ahmed-elbaz/elbaz-blueprints`, which clones this GitHub repo, reads `skills.sh.json`, and copies each listed skill folder into their own Claude Code / claude.ai setup.

Two authoring standards govern everything in this repo — **read them before creating or editing any skill**:
- `docs/CREATE_SKILL.md` — the full authoring reference (frontmatter rules, `${CLAUDE_SKILL_DIR}` path substitution, portability constraints, anti-patterns, shipping checklist). Section "Part 0" is specific to this repo's workflow and manifest rules.
- `docs/SKILL_PROMPT.md` — ready-to-paste prompts for building a new skill, auditing an existing one, and shipping it.

## Repo layout and the manifest invariant

```
skills.sh.json           ← package manifest; MUST list every skill under skills/
skills/<domain>/<skill-name>/
  SKILL.md                ← frontmatter + instructions, what Claude reads when triggered
  reference/               ← deep-dive docs, linked one level deep from SKILL.md
  scripts/                 ← executed, not read; only their stdout enters context
```

Hard invariant: a `skills.sh.json` entry and its `skills/<domain>/<name>/` folder must exist together, and the folder name, the manifest `"name"`, and the `SKILL.md` frontmatter `name:` must all match exactly. A dangling manifest entry produces a broken install for a stranger with no way to debug it — there is no CI here to catch it, so this has to be checked by hand on every change.

Skill frontmatter published from this repo is restricted to the six fields the Agent Skills spec allows (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`) — Claude Code accepts more, but claude.ai/API uploads hard-error on anything else. Only break this rule for a skill that is explicitly Claude Code–only.

## Dev sandbox vs published source

`skills/` is the published source of truth. The local dev/test location is the **global** `~/.claude/skills/<name>/` (not a project-local `.claude/skills/`, which this repo deliberately does not use). Workflow: iterate in `~/.claude/skills/<name>/`, copy the finished folder into `skills/<domain>/<name>/`, register it in `skills.sh.json`, add a row to `README.md`, commit. After any change to a published skill, re-sync the global copy (`rm -rf` + `cp -r` from `skills/...` to `~/.claude/skills/...`) so the two don't drift.

## The flagship skill: `bootstrapping-flutter-mvvm`

`skills/flutter/bootstrapping-flutter-mvvm/` scaffolds a Flutter MVVM + BLoC (Cubit) project. Its two scripts are Dart programs that **write files to a target Flutter project elsewhere on disk** — they are not themselves Flutter/Flutter-app code, so no Flutter SDK is required just to edit them.

- `scripts/scaffold_project.dart` (~1,280 lines) — run from the directory that should *contain* the new project. Every generated file's content lives as a Dart string constant inside this one script (`_appColors`, `_appTextStyles`, `_appFonts`, `_themeDataLight`/`_themeDataDark`, `_appDart`, etc.) — **to change what a scaffolded file contains, edit the matching constant here**, there is no separate template file.
- `scripts/scaffold_feature.dart` (~80 lines) — run from an already-scaffolded project's root; creates only a feature's folder skeleton, writes no file contents by design.

Both are idempotent (`_writeFile` skips anything that already exists and reports it) and `scaffold_project.dart` supports `--dry-run` (report-only, no writes, no `flutter`/network calls). Both must be invoked through `${CLAUDE_SKILL_DIR}` once installed — see `docs/CREATE_SKILL.md` Part 4 for why a bare relative path is broken.

### Verifying a change to this skill

`dart analyze` alone is not sufficient — it does not catch bugs that only surface once real files land in a real `pubspec.yaml`. Verify for real:

```bash
# 1. Static check of the generator script itself
dart analyze skills/flutter/bootstrapping-flutter-mvvm/scripts/

# 2. Dry-run against a scratch directory (outside this repo)
dart run skills/flutter/bootstrapping-flutter-mvvm/scripts/scaffold_project.dart myapp --routing=named --dry-run

# 3. Real apply, if a real Flutter SDK is available on PATH (check with `flutter --version` first —
#    on Windows this repo assumes /c/flutter; add it to PATH before running)
dart run skills/flutter/bootstrapping-flutter-mvvm/scripts/scaffold_project.dart myapp --routing=named
cd myapp && flutter analyze   # the real, decisive check

# 4. Idempotency: re-run step 3's dart run command a second time, diff pubspec.yaml
#    and any touched file against the pre-second-run copy — must be byte-identical
```

After verifying, re-sync `~/.claude/skills/bootstrapping-flutter-mvvm/` from `skills/flutter/bootstrapping-flutter-mvvm/`.

### Known gotchas already fixed — do not reintroduce

These were each found by actually running the script against a real Flutter SDK, not by reading the code:

- **Windows + `Process.run`:** Flutter ships as `flutter.bat` on Windows; `Process.run('flutter', ...)` without `runInShell: true` throws `ProcessException` even on a correct install (`Process.run` uses `CreateProcess`, which doesn't resolve `PATHEXT`). Every `flutter` invocation goes through the shared `_flutter()` helper for this reason — never call `Process.run('flutter', ...)` directly.
- **Two `flutter:` lines in a stock `pubspec.yaml`:** one indented under `dependencies:` (the SDK dependency), one unindented at the top level (the real Flutter config section). Matching on `line.trim() == 'flutter:'` finds the indented one first and corrupts the file. The fix (`_findFlutterSectionIndex`) matches `line.trimRight() == 'flutter:'` with **no leading-whitespace stripping** — `trimRight`, not `trim`, because `pubspec.yaml` has CRLF endings and `split('\n')` leaves a trailing `\r` that a bare `==` would otherwise fail to match.
- **`flutter create`'s own stock `pubspec.yaml` ships a commented-out example `fonts:` block** containing the literal line `# fonts:`. Detecting "has our content already been inserted?" by searching for that line always matches Flutter's own boilerplate — detection has to key off something unique to this skill's own inserted content instead.
- Font family map order matters: the first entry in the `lang -> family` map becomes `AppFonts.fallback` (used for any language not explicitly listed). The default is deliberately `{'en': 'Manrope', 'ar': 'Tajawal'}` (English first) so unlisted, mostly-Latin-script languages fall back to Manrope, not Tajawal.
