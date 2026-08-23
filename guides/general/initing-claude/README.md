# What `initing-claude` does

This is the human-readable version of what the skill at [`skills/general/initing-claude/`](../../../skills/general/initing-claude/) builds. Its own `SKILL.md` is written for an AI agent to execute against — dense, instruction-shaped. This page explains the same thing for a person reading the repo.

## Contents
- What it is, in one sentence
- Two modes, chosen automatically
- How it avoids the thing that makes AI-generated docs untrustworthy
- The template it always produces
- What it deliberately does *not* do
- Where to go for more depth

## What it is, in one sentence

A stricter, stack-agnostic replacement for Claude Code's built-in `/init`: instead of just reading your repo, it also fetches your framework's *current* official documentation before writing any rule, and it can't be customized or shared — this skill can, since it's distributed through this repo.

## Two modes, chosen automatically

The skill checks one thing first: does a `CLAUDE.md` already exist at the project root?

| Found? | Mode | What happens |
|---|---|---|
| No | **Init** | Full analysis — detect the stack, fetch its current docs, read the codebase, write the whole file |
| Yes | **Update** | Asks what mistake just happened, adds exactly **one** new rule, touches nothing else |

The Update mode exists specifically to make this loop practical instead of manual:

```
write initial rules → work with the AI → notice a mistake → add a rule → repeat
```

Every time a rule needs adding, you don't hand-edit the file or re-run a full regeneration that might clobber something you'd customized — you invoke the skill again, say what went wrong, and it appends one targeted line.

## How it avoids the thing that makes AI-generated docs untrustworthy

The entire value of this skill is specific, current, checkable rules — which is exactly the kind of output that goes wrong when an AI just writes what "sounds right" for a framework from memory. So the skill's own instructions carry one non-negotiable constraint: **every rule in the output must trace to something that actually happened in that run** — either a pattern actually found in the codebase (`Read`/`Grep`/`Glob`), or content actually returned by a real `WebFetch` call. Never something recalled from training data and presented as current fact.

Concretely, that means before it does anything stack-specific, it:
1. Detects the stack from marker files (`pubspec.yaml` → Flutter, `package.json` → inspects `dependencies` to tell React from Next.js from Vue, `requirements.txt`/`pyproject.toml` → inspects for Django/Flask/FastAPI, and similarly for Go, Ruby, PHP, JVM, .NET, Rust, and Elixir projects)
2. Looks up that framework in a small built-in map of known official-docs URLs ([`reference/doc-sources.md`](../../../skills/general/initing-claude/reference/doc-sources.md)) — or, if it's not in the map, searches the web for it live rather than guessing a URL
3. Actually fetches those pages before writing a single stack-specific rule

If a project uses more than one stack at once (a monorepo), the skill stops and asks which part the file is for, rather than guessing or trying to merge two stacks into one file.

## The template it always produces

Exactly six sections, every time — no more, no fewer:

```markdown
# CLAUDE.md

## Project Overview
## Architecture
## Tech Stack
## Conventions
## Do
## Don't
```

`Project Overview` through `Conventions` come from what it actually finds in your repo. `Do`/`Don't` is where the fetched-docs discipline matters most — every rule is meant to be **specific and checkable**, not encouragement. `Don't use setState — use BLoC only` is the shape of rule this skill aims for: binary, enforceable, impossible to accidentally violate without noticing. `Follow modern best practices` is the shape it's built to avoid — that's filler, not a rule.

Underneath whatever's stack-specific, it always adds a baseline layer of universal engineering discipline — single responsibility, no dead code, specific exception types instead of bare catches, no magic numbers, no new dependency without a reason — phrased for whatever language it's writing for rather than left generic.

## What it deliberately does *not* do

- **Doesn't regenerate an existing file.** Update mode only ever adds one line. A human may have hand-edited the file since it was generated — wholesale regeneration would silently destroy that.
- **Doesn't reference your personal installed skills.** It doesn't tell a future Claude session to "run clean-code-guard" or similar — those aren't guaranteed to exist for anyone else who installs this skill via skills.sh. The underlying principles are embedded directly in the rules it writes instead.
- **Doesn't work well without network access.** `WebFetch`/`WebSearch` are Claude Code features, not available on the Claude API surface — this skill is built for Claude Code specifically, not every environment a skill could theoretically run in.
- **Doesn't guess at a monorepo.** Multiple stacks detected → it asks which one, rather than producing something wrong for one of them.

## Where to go for more depth

- The skill's own instructions: [`SKILL.md`](../../../skills/general/initing-claude/SKILL.md)
- The known-framework doc-URL map: [`reference/doc-sources.md`](../../../skills/general/initing-claude/reference/doc-sources.md)
