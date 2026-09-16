# What `initing-codex` does

This is the human-readable guide for [`skills/general/initing-codex/`](../../../skills/general/initing-codex/). The skill follows the same architecture as `initing-claude`, but produces `AGENTS.md` and uses instructions appropriate for Codex-compatible coding agents.

## Contents

- What it is
- The three operating modes
- Evidence and documentation discipline
- The generated file structure
- Codex and cloud portability
- What it does not do

## What it is

`initing-codex` analyzes a project's real structure, configuration, source, tests, and current official framework documentation, then creates or updates a concise `AGENTS.md`. Its goal is to capture repository-specific architecture, commands, conventions, and verification rules that an AI coding agent cannot safely infer from generic knowledge.

## Three modes, chosen automatically

The skill first checks whether `AGENTS.md` exists at the project root:

| Situation | Mode | Result |
|---|---|---|
| No `AGENTS.md` | **Init** | Detects the stack, fetches official docs, analyzes the repository, and writes the file. |
| A named mistake or requested rule | **Rule-addition** | Adds exactly one targeted, checkable rule and preserves the rest. |
| Any other update request | **Refresh** | Re-scans the repository and updates only factual sections. |

Refresh is the default for an existing file. The skill never replaces a human-maintained `AGENTS.md` wholesale.

## Evidence-first instructions

Every project-specific claim must come from repository evidence or an official documentation page actually fetched during the run. The skill avoids rules such as “follow best practices” and prefers commands and constraints that can be checked in a diff or by running a project command.

It detects common stacks from marker files such as `package.json`, `pubspec.yaml`, `pyproject.toml`, `go.mod`, and `Cargo.toml`. For monorepos with multiple independent stacks, it requires a clear scope instead of guessing.

## Generated file structure

The output uses a stable six-section shape:

```markdown
# AGENTS.md
## Project Overview
## Architecture
## Tech Stack
## Conventions
## Do
## Don't
```

The file stays under roughly 200 lines. Rarely needed detail belongs in a referenced file or a separate skill.

## Codex and cloud portability

Install for Codex with:

```bash
npx skills add ahmed-elbaz/elbaz-blueprints --skill initing-codex --agent codex
```

For the unpublished local copy, run this from the repository root instead:

```bash
npx skills add . --skill initing-codex --agent codex
```

Start a new Codex session after installation so it can rediscover the skill. Invoke it by asking Codex to initialize or refresh `AGENTS.md`; the skill is not auto-discovered merely because its folder exists under this repository's `skills/` directory.

The package uses the portable Agent Skills `SKILL.md` format. OpenAI-hosted agent environments can consume a skill directory or zip through the Skills API. Other cloud hosts may consume the same directory when they support the standard, but their installation and invocation syntax is host-specific.

## What it does not do

- It does not run against or publish to a GitHub repository as part of normal use; it works in the local repository supplied to the agent.
- It does not invent rules when evidence is missing.
- It does not overwrite existing human edits.
- It does not replace hooks for behavior that must happen on every commit.

## Where to go for more depth

- [`SKILL.md`](../../../skills/general/initing-codex/SKILL.md)
- [`reference/doc-sources.md`](../../../skills/general/initing-codex/reference/doc-sources.md)
- [`initing-claude` guide](../initing-claude/README.md) for the parallel Claude-oriented workflow
