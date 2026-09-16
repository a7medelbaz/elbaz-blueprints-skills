---
name: initing-codex
description: Generates or hardens a project's AGENTS.md by analyzing the actual codebase and fetching current official documentation for its detected stack, then writes concise, specific contributor instructions grounded in observed evidence. Use when initializing, refreshing, or adding a rule to AGENTS.md for a software project.
---

# Initializing AGENTS.md

## Decide first - which mode

Check whether an `AGENTS.md` exists at the project root.

- Not found: use the Init workflow and create it from scratch.
- Found: a named mistake or requested rule uses the Rule-addition workflow; anything else uses Refresh. Refresh is the default.

Never regenerate an existing `AGENTS.md` wholesale. Preserve human edits and change only the relevant sections.

## Governing evidence rule

Every factual claim and project-specific instruction must be traceable to something observed in this run through repository inspection or returned by an official documentation fetch. Never invent a convention from memory. Before presenting the file, check every rule and remove anything without evidence.

## Write instructions Codex will follow

- Keep `AGENTS.md` under about 200 lines. Put rarely needed detail in a referenced file or skill.
- Use specific, checkable instructions such as `Run npm test before committing`, not vague advice.
- State the desired action positively; include a short reason only for non-obvious rules.
- Prefer repository commands and conventions over generic language or framework advice.
- Treat user instructions as higher priority than this file. If guidance conflicts, follow the user and mention the conflict.

## Init workflow

### 1. Detect the stack

Read the repository layout and root markers. Check for an existing `CLAUDE.md`, `AGENTS.md` in parent directories, Cursor rules, and Copilot instructions. Do not duplicate relevant guidance; identify what this root file owns.

Use these markers to identify the stack, then inspect dependencies where applicable:

| Marker | Stack |
|---|---|
| `pubspec.yaml` | Flutter/Dart |
| `package.json` | Node/JavaScript/TypeScript |
| `requirements.txt`, `pyproject.toml`, `Pipfile` | Python |
| `go.mod` | Go |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `pom.xml`, `build.gradle(.kts)` | JVM |
| `*.csproj`, `*.sln` | .NET |
| `Cargo.toml` | Rust |
| `mix.exs` | Elixir |

If multiple independent application markers indicate a monorepo, identify the scope from the user's request or ask which project the file governs before writing.

### 2. Fetch current official documentation

Read [reference/doc-sources.md](reference/doc-sources.md) for the detected stack. Fetch relevant official pages for setup, conventions, and best practices. If no source is listed, search for and fetch the authoritative documentation; never rely on an unverified URL or memory.

### 3. Analyze the actual repository

Inspect the directory structure, package manifest, configuration, representative source files, tests, and existing instructions. Record only architecture, commands, conventions, and gotchas that require this repository's evidence.

### 4. Write `AGENTS.md`

Use this fixed structure:

```markdown
# AGENTS.md

This file provides guidance to coding agents working in this repository.

## Project Overview
## Architecture
## Tech Stack
## Conventions
## Do
## Don't
```

Include commands the agent cannot infer, repository-specific architecture, observed conventions, and concrete validation steps. Do not include generic encouragement or a file-by-file inventory.

## Rule-addition workflow

1. Read the existing `AGENTS.md` in full.
2. If the user named the mistake or pattern, use it; otherwise ask what behavior the rule must prevent.
3. Decide whether the fix belongs in `AGENTS.md`, a path-scoped instruction, a hook, or a skill. Use a hook for mandatory every-time behavior and a skill for occasional multi-step procedures.
4. Append exactly one specific, checkable line to the appropriate section. Do not reorder or clean up unrelated content.
5. Show the user the one-line diff and its evidence.

## Refresh workflow

1. Read the existing `AGENTS.md` in full.
2. Re-scan the current repository, manifest, representative code, tests, and relevant documentation.
3. Update only factual sections: Project Overview, Architecture, Tech Stack, and Conventions.
4. Leave `Do` and `Don't` unchanged unless a repository change made an existing rule false.
5. If nothing changed, report that instead of rewriting the file.

## Anti-patterns

- Do not overwrite a human-maintained `AGENTS.md`.
- Do not write rules from framework memory without repository observation or an official fetched source.
- Do not duplicate instructions already owned by a more specific nested `AGENTS.md`.
- Do not use vague rules such as `write clean code` or `follow best practices`.
- Do not hide required steps behind a weak reference; make the pointer state what it contains and when to read it.
