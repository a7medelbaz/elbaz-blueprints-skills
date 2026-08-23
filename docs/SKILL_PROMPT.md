# SKILL_PROMPT.md
> Your copy-paste prompt for Claude Code. Fill in [YOUR TASK] and send.

---

## The prompt — copy this into Claude Code

```
Before building anything, read these sections of CREATE_SKILL.md:
- "Directory structure"
- "YAML frontmatter — exact rules"
- "SKILL.md body — writing rules"
- "Build evaluations FIRST"
- "Evaluation checklist"

Then follow this exact sequence:

STEP 1 — Write 3 evaluations first (before any skill content)
Run me through the task without a skill. Identify what's missing or failing.
Write 3 evaluations in the JSON format from CREATE_SKILL.md's "Build evaluations FIRST" section.
Show me the evaluations before proceeding.

STEP 2 — Build the skill
Create the skill directory in .claude/skills/ with:
- SKILL.md with YAML frontmatter + instructions
- Reference files if content would exceed 500 lines (one level deep only)
- Scripts for any fragile, repetitive, or deterministic operations

STEP 3 — Run the evaluation checklist
Go through every item in the "Evaluation checklist" section of CREATE_SKILL.md.
Show me the checklist with each item checked or flagged.

STEP 4 — Show the final structure
Print the complete directory tree of the skill you built.

---

THE TASK:

[YOUR TASK — be specific. Include:]
[- What it does]
[- What I'll say to trigger it (exact phrases if you know them)]
[- Any rules that must ALWAYS apply (filters, formats, conventions)]
[- Any fragile steps that need exact commands]
[- Any domain-specific context Claude won't already know]
```

---

## How to describe [YOUR TASK] — examples by input type

**From a repetition you keep saying (best input):**
> "I keep telling Claude: always filter test accounts, use UTC timestamps, exclude the sandbox
> workspace from all BigQuery queries. Turn this into a skill so I never say it again."

**From a workflow with exact steps:**
> "Build a skill for our git commit process: read the diff, suggest a conventional commit
> message in our format (type/scope: description), validate it's under 72 chars."

**From domain rules and conventions:**
> "Build a skill for our WooCommerce codebase: HPOS-compatible order access only,
> wc_get_order() not direct DB queries, our custom meta key names, our hook naming pattern."

**From a tool with an API:**
> "Build a skill for our internal Slack bot API: base URL, auth headers, rate limits,
> our channel ID map, and common message payload formats."

**From a document you can paste:**
> "Here are the instructions I always give Claude when working on [X]: [paste them].
> Extract the reusable parts and turn them into a skill."

---

## After the skill is built — how to test it properly

Paste this into Claude Code:

```
Test the [skill-name] skill with this real task: [describe an actual task]

While doing it, tell me:
1. Which files did you read, and in what order?
2. Did any reference link feel unclear or hard to follow?
3. Did you apply all the rules from the skill?
4. Was anything missing that you had to guess or invent?
```

Then test two more tasks. Look for:
- Files Claude reads in a surprising order → restructure for clarity
- Links Claude doesn't follow → make them more explicit
- Rules Claude forgets → move them higher or make them bolder
- Files Claude never touches → remove or better signal them

Iterate on what you observe. One real test reveals more than ten assumptions.
