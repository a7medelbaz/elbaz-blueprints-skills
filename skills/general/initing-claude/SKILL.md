---
name: initing-claude
description: Generates or hardens a project's CLAUDE.md by analyzing the actual codebase and fetching current official documentation for whatever tech stack it detects — architecture, conventions, and strict, specific Do/Don't rules grounded in real fetched docs, never memorized knowledge. Use when initializing a new project's CLAUDE.md, adding a rule after Claude made a mistake, or setting up AI coding guardrails for any language or framework.
---

# Initializing CLAUDE.md

## Decide first — which mode

Check whether a `CLAUDE.md` already exists at the project root.

- **Not found** → [Init workflow](#init-workflow): full analysis, write the file from scratch.
- **Found** → figure out which kind of update this is from what was actually said, without asking first:
  - A mistake, correction, or "add a rule for X" was named → [Rule-addition workflow](#rule-addition-workflow).
  - Anything else — "update this", "refresh it", "I added feature Y", or no reason given at all → [Refresh workflow](#refresh-workflow). **This is the default.** Don't stop to ask which kind of update is wanted; a bare "update CLAUDE.md" means refresh it from the current codebase, not report a mistake.

Never regenerate an existing `CLAUDE.md` wholesale — a human may have hand-edited it since it was generated, and wholesale regeneration silently destroys that. Both update flows below touch only what changed.

## The rule that governs everything below

**Every claim in the output must be traceable to something you actually did this run** — either a pattern you actually observed in this codebase (via `Read`/`Grep`/`Glob`), or content actually returned by a `WebFetch` call you actually made. Never write a rule because it "sounds right for this framework" from training data. A confidently wrong rule is worse than no rule — this is the single most important constraint in this skill. Before presenting the finished file, re-read every `Do`/`Don't` line and ask: *which specific observation or fetched page does this come from?* If you can't answer that, delete the line.

## Write instructions Claude will actually follow

CLAUDE.md content is delivered as a user message after the system prompt, not enforced configuration — Claude reads it and tries to comply, but nothing forces it the way a hook does. How each line is written changes how reliably it's followed:

- **Size.** Keep the whole file under ~200 lines. Longer files consume more context and measurably reduce adherence — Claude starts missing rules once the file is bloated. If content keeps growing, don't keep appending: move file-type-specific rules into `.claude/rules/<topic>.md` (scoped with `paths:` frontmatter so they only load for matching files), and move multi-step procedures into a skill (loaded on demand, not every session).
- **Specificity.** "Use 2-space indentation" survives; "format code properly" doesn't — a rule Claude can't check against, it can't reliably follow. Every `Do`/`Don't` line should describe something a reviewer could point at in a diff and call pass or fail. Where a rule can be tied to a concrete check — a test command, a lint command, a build step — prefer that over a bare style preference: "Run `npm test` before committing" over "test your changes."
- **A reason, briefly.** Claude generalizes better from a rule that states *why* than from a bare prohibition — one clause is enough ("...because it breaks hot reload", "...to match the existing repository pattern"), not a paragraph. Skip the reason only when the rule is already self-evidently checkable on its own.
- **State the action, not just the ban.** Where both are equally clear, prefer "Use BLoC for state" over "Don't use setState" — Claude follows positive instructions more reliably than pure prohibitions.
- **Spend emphasis carefully.** Reserve "IMPORTANT" or similar for the one or two lines that truly need it. Emphasizing everything means nothing stands out.
- **Reference instead of duplicating.** If the project already has a README, `AGENTS.md`, or package manifest documenting something, pull it in with `@path/to/file` syntax rather than retyping its content. Imports still load into context at launch — this isn't a token-savings trick — but it keeps one source of truth instead of a copy that drifts the moment the original changes.

## Init workflow

### 1. Detect the stack

Also check for an existing `AGENTS.md`, `.cursor/rules/`/`.cursorrules`, or `.github/copilot-instructions.md` — Claude Code doesn't read any of these directly. If `AGENTS.md` exists, don't duplicate it: write `CLAUDE.md` as `@AGENTS.md` followed by a `## Claude Code` section for anything Claude-specific, the pattern Claude Code's own docs recommend. If only Cursor/Copilot rule files exist, fold their relevant parts into the sections below instead, the same way the built-in `/init` does.

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

**What belongs in each section** — Claude Code's own docs draw this line explicitly; apply it to every section, not just `Do`/`Don't`:

| ✅ Include | ❌ Exclude |
|---|---|
| Commands Claude can't guess (build, test, lint, single-test invocation) | Anything Claude can figure out by reading the code |
| Conventions that differ from the language/framework's own defaults | Standard conventions Claude already knows |
| Architectural decisions specific to this project | File-by-file descriptions of the codebase |
| Repository etiquette (branch naming, PR/commit conventions) | Information that changes frequently |
| Environment quirks (required env vars, non-obvious setup steps) | Self-evident practices ("write clean code", "handle errors") |
| Non-obvious gotchas a new contributor would hit | Long explanations or tutorials — link out instead |

**Do/Don't rules — the part that matters most:**

- Every rule is **specific and checkable**, never vague encouragement. `Don't use setState — use BLoC only` is a good rule: binary, enforceable, unambiguous. `Follow modern best practices` is not a rule, it's filler — delete it.
- Apply the instruction-writing discipline from [Write instructions Claude will actually follow](#write-instructions-claude-will-actually-follow): a brief reason on non-obvious rules, positive framing where it's equally clear, sparing emphasis.
- Stack-specific rules come from what step 2 actually fetched, or a pattern step 3 actually found — cite which, mentally, before writing each one (see [the governing rule](#the-rule-that-governs-everything-below)).
- Always include a baseline layer of universal engineering discipline, phrased for the detected language/stack rather than generically:
  - Single responsibility — a function/class does one thing
  - No dead code, no commented-out blocks left behind
  - Catch specific exception/error types, never a bare catch-all
  - No magic numbers/strings without a named constant
  - No new dependency without a stated reason
- Keep the whole file scannable — this is a guardrail document a human and an AI both read before every session, not a reference manual. If a `Do`/`Don't` list is getting long, that's a sign some items belong in `Conventions`, a path-scoped rule, or a skill instead (see the size guidance above).

Before presenting the file, count its lines. Over ~200? Trim per the size guidance above rather than shipping a file Claude will only partially read.

## Rule-addition workflow

Use this when a mistake, correction, or specific rule request was actually named. This implements the iterative-improvement cycle: write rules → work with the AI → notice a mistake → add a rule → repeat.

1. Read the existing `CLAUDE.md` in full.
2. If the mistake itself wasn't stated yet — only the fact that something should be added — ask: **what mistake or pattern just happened that this should prevent next time?** If it was already stated in the request that triggered this workflow, don't ask again.
3. Decide whether CLAUDE.md is even the right mechanism for this fix — it's advisory, not enforced:

   | The fix needs to... | Use instead |
   |---|---|
   | Happen every time, with zero exceptions (e.g. a command that must run before every commit) | A hook — CLAUDE.md is advisory, hooks are enforced regardless of what Claude decides |
   | Apply only to certain file types or directories | A path-scoped rule in `.claude/rules/` (`paths:` frontmatter) |
   | Cover a multi-step procedure that's only relevant sometimes | A skill, loaded on demand |
   | Be a standing behavioral rule relevant to every session | CLAUDE.md — continue to step 4 |

4. Decide which section the new rule belongs in — almost always `Do` or `Don't`; occasionally `Conventions` if it's about a pattern rather than a hard rule.
5. If the rule is stack-specific and you're not confident about the correct current API/pattern, fetch it first (steps 1-2 of the Init workflow) rather than guessing — the governing rule above applies here too.
6. Append **exactly one** new line to the right section, written per [Write instructions Claude will actually follow](#write-instructions-claude-will-actually-follow) — specific, checkable, with a brief reason if it's not self-evident. Do not touch any other line, section, or ordering. Do not "clean up" or rewrite existing content while you're in there — that's a different task the user hasn't asked for.
7. Show the user the diff (just the new line), not the whole file.

## Refresh workflow

Use this — the default — when the codebase changed (a new feature, a new dependency, a moved folder, a changed pattern) and the file should catch up. No clarifying question first: re-scan and update.

1. Read the existing `CLAUDE.md` in full.
2. Re-analyze the actual codebase the same way as [Init workflow step 3](#3-analyze-the-actual-codebase) — folder structure, package manifest, a representative sample of current code. Look specifically for what's changed since this file was last written.
3. Update only `Project Overview`, `Architecture`, `Tech Stack`, and `Conventions` — the factual sections — to match what you actually found. Add what's new, correct what's now wrong, remove what no longer applies. The governing rule still applies: every change traces to something read this run.
4. Leave `Do`/`Don't` alone unless the codebase change makes an *existing* rule factually wrong (e.g. a documented convention was replaced). Don't invent new `Do`/`Don't` rules here — a new rule with no mistake behind it belongs in the Rule-addition workflow, not this one.
5. Show the user the diff, not the whole file. If nothing in the codebase actually changed since the file was last written, say so instead of rewriting sections for the sake of it.

## Anti-patterns — don't do these

- Writing a rule from memory of "how this framework usually works" without an actual `WebFetch` in this run backing it up
- Regenerating a whole existing `CLAUDE.md` when only a targeted update (one new rule, or a refresh of the factual sections) was called for
- Asking "what mistake happened?" when the user just asked for an update with no mistake implied — that's the Refresh workflow, not Rule-addition
- Copying this skill's own illustrative example rules (e.g. from a Flutter project) into an unrelated project's file — every rule must come from *that* project's actual stack and code
- Adding a section beyond the fixed six, or renaming one
- Writing a rule that isn't checkable ("write good code," "be careful with state") — if you can't imagine how someone would verify a violation, it doesn't belong
- Appending a rule to CLAUDE.md for something that should be a hook (must-happen-every-time, no exceptions) or a skill (multi-step, only occasionally relevant) instead
- Inventing new Do/Don't rules during a Refresh — that's Rule-addition's job, not a side effect of catching the file up
- Letting the file grow past ~200 lines instead of splitting into `.claude/rules/` or a skill
