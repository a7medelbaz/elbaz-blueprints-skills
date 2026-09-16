# AGENTS.md

This file provides guidance to Codex and other coding agents when working with this repository.

## Project Overview

`elbaz-blueprints` is Ahmed Elbaz's personal library of portable agent skills, distributed via [skills.sh](https://skills.sh). Each skill is a `SKILL.md` package with optional scripts and reference files. The repository contains Flutter scaffolding skills and instruction-generating skills for Claude and Codex.

## Architecture

- `skills/<domain>/<skill-name>/` is the published source of truth: `SKILL.md` is required; `reference/` contains one-level-deep supporting material; `scripts/` contains executable helpers.
- `skills.sh.json` is the package manifest, and `skills-lock.json` records installer state. Every manifest entry must match a folder under `skills/`.
- `docs/` contains internal authoring guidance. `guides/<domain>/<skill-name>/` contains human-readable explanations for repository visitors.

## Tech Stack

- Skill packages use YAML frontmatter and Markdown following the portable Agent Skills format.
- `skills/flutter/bootstrapping-flutter-mvvm/scripts/` contains Dart scaffolding scripts.
- This repository has no application build system of its own; it publishes instructions and scripts consumed by coding agents.

## Conventions

- Use lowercase, hyphenated gerund names, such as `bootstrapping-flutter-mvvm`, `initing-claude`, and `initing-codex`.
- Keep the skill folder name, manifest `name`, and frontmatter `name` identical.
- Keep references one level below `SKILL.md`; document extensions rather than duplicating generated script output.
- Use host-neutral paths in portable skills. Claude-specific path variables belong only in Claude-specific skills.
- Mutating scripts must provide `--dry-run`, avoid overwriting existing files, and be safe to run repeatedly.

## Do

- Use `rg` for repository searches and `apply_patch` for focused file edits.
- Verify documented commands and APIs against repository source before publishing them.
- Run `npx skills add . --skill initing-codex --agent codex` when validating the local Codex skill, then start a new Codex session for discovery.
- Run affected scripts on Windows before reporting success; use `--dry-run` first for mutating scripts and verify idempotency.
- Register a new or renamed skill in `skills/<domain>/<name>/`, `skills.sh.json`, and the README table together.

## Don't

- Don't add a manifest entry without its matching skill folder, or a skill folder without its manifest entry.
- Don't overwrite human-maintained instructions or regenerate `AGENTS.md` wholesale when a targeted update is enough.
- Don't use bare relative paths for bundled scripts when the host may invoke the skill from another working directory.
- Don't duplicate generated code in reference files; it will drift from the script that owns it.
- Don't ship a mutating script without `--dry-run`, and don't apply it blindly.
- Don't invent repository rules from memory; ground them in observed source, project files, or fetched official documentation.
