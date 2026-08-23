---
name: initing-claude
description: Generates or hardens a project's CLAUDE.md by analyzing the actual codebase and fetching current official documentation for whatever tech stack it detects — architecture, conventions, and strict, specific Do/Don't rules grounded in real fetched docs, never memorized knowledge. Use when initializing a new project's CLAUDE.md, adding a rule after Claude made a mistake, or setting up AI coding guardrails for any language or framework.
---

# Initializing CLAUDE.md

## Decide first — which mode

Check whether a `CLAUDE.md` already exists at the project root.

- **Not found** → [Init workflow](#init-workflow): full analysis, write the file from scratch.
- **Found** → [Update workflow](#update-workflow): add exactly one rule, touch nothing else.

Never regenerate an existing `CLAUDE.md` wholesale — a human may have hand-edited it since it was generated, and wholesale regeneration silently destroys that.

## The rule that governs everything below

**Every claim in the output must be traceable to something you actually did this run** — either a pattern you actually observed in this codebase (via `Read`/`Grep`/`Glob`), or content actually returned by a `WebFetch` call you actually made. Never write a rule because it "sounds right for this framework" from training data. A confidently wrong rule is worse than no rule — this is the single most important constraint in this skill. Before presenting the finished file, re-read every `Do`/`Don't` line and ask: *which specific observation or fetched page does this come from?* If you can't answer that, delete the line.

## Init workflow

### 1. Detect the stack

Look for marker files at the project root:

| Marker | Stack | Then check |
|---|---|---|
| `pubspec.yaml` | Flutter/Dart | — |
| `package.json` | Node/JS/TS | Inspect `dependencies`/`devDependencies` for `react`, `next`, `vue`, `nuxt`, `@angular/core`, `svelte`, `astro`, `express`, `@nestjs/core`, etc. |
| `requirements.txt` / `pyproject.toml` / `Pipfile` | Python | Inspect for `django`, `flask`, `fastapi` |
| `go.mod` | Go | Inspect for `gin-gonic/gin` etc. |
| `Gemfile` | Ruby | Inspect for `rails` |
| `composer.json` | PHP | Inspect for `laravel/framework`, `symfony/*` |
| `pom.xml` / `build.gradle(.kts)` | JVM | Inspect for `spring-boot` |
| `*.csproj` / `*.sln` | .NET | — |
| `Cargo.toml` | Rust | Inspect for `actix-web` |
| `mix.exs` | Elixir | Inspect for `phoenix` |

**If more than one marker is found** (a monorepo), stop and ask the user which part of the project this `CLAUDE.md` is for — do not guess, and do not attempt a combined multi-stack file.

### 2. Get current docs for that stack

Check [reference/doc-sources.md](reference/doc-sources.md) for the detected framework's docs root. If it's listed, `WebFetch` the relevant pages (getting-started/conventions/best-practices pages, not just the homepage). If it's **not** listed, `WebSearch("<framework> official documentation")` and `WebFetch` the top authoritative result instead — never fabricate a URL.

### 3. Analyze the actual codebase

Same discipline as Claude Code's own `/init`: read the real folder structure, the package manifest, and a representative sample of existing code. Only note the **big-picture** architecture that would take reading multiple files to piece together — not a listing of every file, not generic practices ("write tests," "handle errors") that apply to any project regardless of what you found here.

### 4. Write CLAUDE.md

Use exactly this template, no more sections, no fewer:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
[2-3 sentences — what the project does]

## Architecture
[Layers, patterns, folder structure — big picture only]

## Tech Stack
[Languages, frameworks, packages — with versions, read from the manifest]

## Conventions
[Naming, file structure, code patterns — actually observed in this repo]

## Do
[...]

## Don't
[...]
```

**Do/Don't rules — the part that matters most:**

- Every rule is **specific and checkable**, never vague encouragement. `Don't use setState — use BLoC only` is a good rule: binary, enforceable, unambiguous. `Follow modern best practices` is not a rule, it's filler — delete it.
- Stack-specific rules come from what step 2 actually fetched, or a pattern step 3 actually found — cite which, mentally, before writing each one (see [the governing rule](#the-rule-that-governs-everything-below)).
- Always include a baseline layer of universal engineering discipline, phrased for the detected language/stack rather than generically:
  - Single responsibility — a function/class does one thing
  - No dead code, no commented-out blocks left behind
  - Catch specific exception/error types, never a bare catch-all
  - No magic numbers/strings without a named constant
  - No new dependency without a stated reason
- Keep the whole file scannable — this is a guardrail document a human and an AI both read before every session, not a reference manual. If a `Do`/`Don't` list is getting long, that's a sign some items belong in `Conventions` instead.

## Update workflow

This implements the iterative-improvement cycle: write rules → work with the AI → notice a mistake → add a rule → repeat.

1. Read the existing `CLAUDE.md` in full.
2. Ask the user: **what mistake or pattern just happened that this should prevent next time?**
3. Decide which section the new rule belongs in — almost always `Do` or `Don't`; occasionally `Conventions` if it's about a pattern rather than a hard rule.
4. If the rule is stack-specific and you're not confident about the correct current API/pattern, fetch it first (steps 1-2 of the Init workflow) rather than guessing — the governing rule above applies here too.
5. Append **exactly one** new line to the right section. Do not touch any other line, section, or ordering. Do not "clean up" or rewrite existing content while you're in there — that's a different task the user hasn't asked for.
6. Show the user the diff (just the new line), not the whole file.

## Anti-patterns — don't do these

- Writing a rule from memory of "how this framework usually works" without an actual `WebFetch` in this run backing it up
- Regenerating a whole existing `CLAUDE.md` when only the Update workflow (one new rule) was called for
- Copying this skill's own illustrative example rules (e.g. from a Flutter project) into an unrelated project's file — every rule must come from *that* project's actual stack and code
- Adding a section beyond the fixed six, or renaming one
- Writing a rule that isn't checkable ("write good code," "be careful with state") — if you can't imagine how someone would verify a violation, it doesn't belong
