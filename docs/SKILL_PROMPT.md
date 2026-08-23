# SKILL_PROMPT.md

> Copy-paste prompts for Claude Code, for the three things you actually do with skills in this repo:
> **build one**, **audit one**, and **ship one**.
> All three assume [CREATE_SKILL.md](CREATE_SKILL.md) is the standard.

## Contents

- [Prompt 1 — Build a new skill](#prompt-1--build-a-new-skill)
- [How to describe your task](#how-to-describe-your-task)
- [Prompt 2 — Audit an existing skill (harsh)](#prompt-2--audit-an-existing-skill-harsh)
- [Prompt 3 — Ship it](#prompt-3--ship-it)
- [Prompt 4 — Test a skill for real](#prompt-4--test-a-skill-for-real)
- [The rules Claude keeps breaking](#the-rules-claude-keeps-breaking)

---

## Prompt 1 — Build a new skill

```
Read these sections of docs/CREATE_SKILL.md before writing anything:
- Part 0 (this repo's rules, especially the portability rule)
- Part 3 (frontmatter)
- Part 4 (paths and ${CLAUDE_SKILL_DIR})
- Part 8 (scripts)
- Part 11 (shipping checklist)

Then follow this sequence. Do not skip step 1.

STEP 1 — Evaluations FIRST, before any skill content.
Run me through the task WITHOUT a skill. Document exactly where you
guessed, lacked context, or got it wrong.
Write 3 evaluations in the JSON format from CREATE_SKILL.md Part 10,
targeting those specific gaps. Show them to me before continuing.

STEP 2 — Build the minimum skill that passes those evaluations.
- SKILL.md with spec-compliant frontmatter (six fields only, unless you
  tell me why a Claude Code-only field is required)
- reference/ files ONLY for content that would push SKILL.md past 500
  lines, linked one level deep, each with a Contents block if >100 lines
- scripts/ for anything deterministic, fragile, or repetitive

STEP 3 — Prove the scripts work. Do not report success from reading code.
- Execute every script, on this OS
- Run any mutating script twice and diff the result to prove idempotency
- Verify every command written in SKILL.md actually runs as written

STEP 4 — Run the Part 11 checklist and show it to me with each item
checked or explicitly flagged as failing.

STEP 5 — Print the final directory tree.

---

THE TASK:

[YOUR TASK — include:]
[- What it does]
[- The exact phrases I'll say to trigger it]
[- Rules that must ALWAYS apply (filters, conventions, formats)]
[- Fragile steps needing exact commands]
[- Domain context you won't already know]
```

---

## How to describe your task

**From a repetition you keep saying (best input):**
> "I keep telling you: always filter test accounts, use UTC timestamps, exclude the sandbox workspace from BigQuery queries. Turn this into a skill so I never say it again."

**From a workflow with exact steps:**
> "Build a skill for our commit process: read the diff, write a conventional commit message in `type(scope): description` format, validate under 72 chars."

**From domain rules:**
> "Build a skill for our WooCommerce codebase: HPOS-compatible order access only, `wc_get_order()` not direct DB queries, our meta key names, our hook naming pattern."

**From a document you can paste:**
> "Here's what I always tell you when working on [X]: [paste]. Extract the reusable parts into a skill."

---

## Prompt 2 — Audit an existing skill (harsh)

This is the prompt that found six real bugs in `bootstrapping-flutter-mvvm`, including one that made it fail on Windows entirely. Run it on any skill before publishing, and again whenever one has drifted.

```
Audit the skill at <path> against docs/CREATE_SKILL.md. Be harsh. I want
bugs, not reassurance.

Read EVERY file in the skill first — SKILL.md, every reference file,
every script, start to finish. Do not skim.

Then verify each of these by ACTUALLY DOING IT, not by reading:

1. INVOCABILITY — Run every command exactly as SKILL.md writes it, from
   the working directory a real user would be in with the skill installed
   at ~/.claude/skills/. Bare relative script paths are broken by
   definition. Report anything that would fail on first use.

2. CROSS-PLATFORM — Execute the scripts on this OS. Check every external
   command invocation for Windows .bat/.cmd resolution. Check every path
   separator.

3. IDEMPOTENCY — Run each mutating script twice. Diff the result. The
   second run must change nothing.

4. DRIFT — Find every place a reference file restates code that a script
   generates. Those WILL have diverged. Report each divergence.

5. COMPILABILITY — Every API form, call signature, and code sample in the
   docs: verify it against the actual scaffolded source. Report any that
   would not compile, and any concept documented more than one way.

6. PORTABILITY — Check frontmatter against the six-field Agent Skills
   spec. Flag any field that would hard-error on claude.ai/API upload.

7. DEAD WEIGHT — Find dependencies installed but never used, files never
   referenced, and instructions for things the script already does.

8. CHECKLIST — Run the full Part 11 checklist.

Report findings ranked by severity, each with the specific file:line and
a concrete failure scenario. Then ask me how aggressively to fix before
changing anything.
```

---

## Prompt 3 — Ship it

```
Publish the skill at ~/.claude/skills/<name>/ to this repo, following
docs/CREATE_SKILL.md Part 0.

1. Copy it to skills/<domain>/<name>/ — pick the right existing domain
   folder, or tell me why a new one is needed
2. Register it in skills.sh.json (name, path, description) — verify the
   folder name, the manifest name, and the frontmatter name are identical
3. Add a row to the README.md table
4. Re-verify: does anything in skills.sh.json point at a path that
   doesn't exist, or vice versa?
5. Show me the diff. Do not commit until I say so.

Remember: there's no version pinning. Whatever lands on main is what
every new installer gets immediately.
```

---

## Prompt 4 — Test a skill for real

Run this in a **fresh session** (a clean Claude with the skill loaded — "Claude B" in CREATE_SKILL.md Part 10), not in the session that built it. A skill that only works when its author is in context isn't done.

```
Use the <skill-name> skill for this real task: [describe an actual task]

Afterward, tell me:
1. Which files did you read, in what order?
2. Did any reference link feel unclear or hard to follow?
3. Did you apply every rule in the skill, or forget any?
4. Was anything missing that you had to guess or invent?
5. Did any command in the skill fail as written?
```

Then run two more tasks. Look for:

| What you see | What it means |
|---|---|
| Files read in a surprising order | Structure isn't intuitive — restructure |
| A link never followed | Make it more explicit or prominent |
| A rule forgotten | Move it higher, or strengthen to "MUST" |
| Same file read repeatedly | That content belongs in SKILL.md |
| A file never touched | Unnecessary, or poorly signaled |
| A command that failed | Path/working-directory bug — see Part 4 |

One real test reveals more than ten assumptions.

---

## The rules Claude keeps breaking

Paste these into any of the prompts above if you see them slipping:

- **Don't report success from reading code.** Execute it.
- **Don't create a second script to check the first one.** Add `--dry-run` to the real one.
- **Don't restate scaffolded code in a reference file.** Document how to extend it.
- **Don't use a bare relative path** to a bundled script. Ever.
- **Don't add a Claude Code–only frontmatter field** to a published skill without saying why.
- **Don't overwrite my files.** Scaffolds skip and report; mutations ask first.
- **Don't explain what you already know.** Delete it and save the tokens.
