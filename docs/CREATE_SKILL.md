# CREATE_SKILL.md

> **Authoritative reference for building Agent Skills in this repo.**
> Grounded in the official Anthropic docs (platform.claude.com Agent Skills overview + best-practices, code.claude.com skills reference) and in bugs actually found shipping skills here.
> Claude Code reads this when building or auditing any skill in `elbaz-blueprints`.

## Contents

- [Part 0 — This repo: elbaz-blueprints](#part-0--this-repo-elbaz-blueprints)
- [Part 1 — How skills load (and why it matters)](#part-1--how-skills-load-and-why-it-matters)
- [Part 2 — Directory structure](#part-2--directory-structure)
- [Part 3 — Frontmatter: complete reference](#part-3--frontmatter-complete-reference)
- [Part 4 — Paths, arguments, and `${CLAUDE_SKILL_DIR}`](#part-4--paths-arguments-and-claude_skill_dir)
- [Part 5 — Writing the SKILL.md body](#part-5--writing-the-skillmd-body)
- [Part 6 — Progressive disclosure](#part-6--progressive-disclosure)
- [Part 7 — Workflows and feedback loops](#part-7--workflows-and-feedback-loops)
- [Part 8 — Scripts](#part-8--scripts)
- [Part 9 — Anti-patterns](#part-9--anti-patterns)
- [Part 10 — Evaluations](#part-10--evaluations)
- [Part 11 — Shipping checklist](#part-11--shipping-checklist)

---

## Part 0 — This repo: elbaz-blueprints

Everything else in this file is general skill-authoring standard. **This section is what's specific to shipping a skill from this repo**, and it overrides generic advice where they conflict.

### Published layout

```
elbaz-blueprints/
├── skills.sh.json           ← package manifest; must list every skill
├── docs/                    ← this file + SKILL_PROMPT.md (not shipped as skills)
└── skills/
    ├── flutter/
    │   └── bootstrapping-flutter-mvvm/   ← real, audited skill; use as the template
    └── <domain>/
        └── <skill-name>/
```

### Workflow for adding or changing a skill

1. Build and iterate in `~/.claude/skills/<name>/` (global dev sandbox — available to all projects on this machine).
2. Once it passes [Part 11](#part-11--shipping-checklist), copy it into `skills/<domain>/<skill-name>/`.
3. Register it in `skills.sh.json` under `"skills"` with `name`, `path`, `description`.
4. Add a row to the table in `README.md`.
5. Commit and push — skills.sh syncs from the GitHub default branch automatically.

### Hard rules for this repo

- **Never** add a `skills.sh.json` entry without the matching folder under `skills/`, or vice versa. The installer trusts the manifest blindly; a dangling `path` produces a broken install for a stranger who cannot debug it.
- The skill folder name, the `"name"` in `skills.sh.json`, and the `name:` in frontmatter must be **identical**.
- `skills/` is the published source of truth. `~/.claude/skills/` is a dev sandbox — never the reverse.
- Prefer nesting under an existing domain folder before creating a new one.
- **There is no version pinning.** Whatever is on the default branch is what `npx skills add` installs. A breaking push reaches every new installer immediately. Treat `main` as production.

### Portability rule — this one bites hard

This repo is **publicly distributed**, so skills may be installed into Claude Code *or* uploaded to claude.ai / the Skills API. Those paths accept **different frontmatter**.

The Agent Skills open spec ([agentskills.io](https://agentskills.io)) allows exactly six fields:

```
name, description, license, compatibility, metadata, allowed-tools
```

Claude Code accepts many more (see [Part 3](#part-3--frontmatter-complete-reference)). But claude.ai uploads, the Skills API, and `package_skill.py` **fail with a hard error** — not a warning — on anything else:

```
Unexpected key(s) in SKILL.md frontmatter: argument-hint.
Allowed properties are: allowed-tools, compatibility, description, license, metadata, name
```

> **Default for every skill published from this repo: restrict frontmatter to the six spec fields.** All six load in Claude Code unchanged, so spec-compliant frontmatter costs nothing and keeps the skill installable everywhere. Only reach for a Claude Code–only field when the skill is explicitly Claude Code–only, and say so in its README row.

Claude Code–only *body* features (dynamic context injection via `` !`command` ``) also silently do nothing on claude.ai and the API. Same rule applies.

---

## Part 1 — How skills load (and why it matters)

A skill is a directory containing `SKILL.md` plus optional scripts and reference files. Claude Code discovers them from:

- `.claude/skills/` — project only
- `~/.claude/skills/` — all projects for this user
- plugin skills — bundled with an installed plugin

Skills are triggered automatically when the `description` matches the request, or invoked directly as `/skill-name`.

**Three loading levels:**

| Level | Loaded when | Token cost | Content |
|---|---|---|---|
| 1 — Metadata | Always, at startup | ~100 tokens/skill | `name` + `description` only |
| 2 — Instructions | When triggered | Under 5k tokens | SKILL.md body |
| 3 — Resources | Only when read | Zero until accessed | Reference files, scripts |

**What this buys you:** 50 installed skills cost ~5k tokens at startup. Bundled reference files cost *nothing* until read — so there is no penalty for shipping comprehensive references, only for bloating SKILL.md itself.

**Scripts are the cheapest layer.** Claude runs them through bash; only their *output* enters context, never their source. A 700-line script costs the same as a 10-line one. This is why fragile or repetitive logic belongs in a script, not in prose the model must re-derive.

---

## Part 2 — Directory structure

```
my-skill/
├── SKILL.md          ← REQUIRED. Frontmatter + instructions.
├── reference/        ← Optional. Domain-split deep material.
│   ├── routing.md
│   └── theming.md
└── scripts/          ← Optional. Executed, not read.
    ├── scaffold.dart
    └── validate.py
```

**Hard rules:**
- Reference files must be **one level deep** from `SKILL.md`. Never `SKILL.md → advanced.md → details.md` — Claude may `head -100` a nested file and act on partial information.
- **Forward slashes only**, even on Windows. Backslashes break on Unix.
- Name files by content: `error-handling.md`, never `doc2.md`.
- Organize `reference/` by domain so an unrelated task never loads it.

---

## Part 3 — Frontmatter: complete reference

### The six portable fields (Agent Skills spec)

| Field | Rules |
|---|---|
| `name` | Max 64 chars. Lowercase letters, numbers, hyphens only. No XML tags. No reserved words (`anthropic`, `claude`). In Claude Code it's optional and defaults to the directory name — but **required** by the spec/API, so always set it here. |
| `description` | Non-empty, max 1,024 chars, no XML tags. Third person. Must state **what it does AND when to trigger it**. |
| `license` | License covering the skill. Claude Code accepts but ignores it. |
| `compatibility` | Environment requirements, max 500 chars. Accepted but not acted on by Claude Code. |
| `metadata` | Free-form YAML **map** for your own tooling. A non-map value is dropped. Don't reuse real field names as keys. |
| `allowed-tools` | Tools usable without a permission prompt during the invoking turn. Space/comma-separated string or YAML list. Grant clears on your next message. |

### `description` — the single highest-leverage field

This is the only thing Claude sees at startup, and how it picks your skill out of 100+. Get it wrong and a perfect skill never fires.

- **Third person, always.** It's injected into the system prompt; first/second person causes discovery problems.
- State **what** and **when**, with concrete trigger keywords.
- **Put the key use case first** — the listing truncates.

```yaml
# Good — specific, third person, real triggers
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.

# Bad
description: Helps with documents          # no triggers, vague
description: I can help you process Excel  # first person
description: Processes data                # no trigger context
```

### Naming

Prefer **gerund form**: `bootstrapping-flutter-mvvm`, `processing-pdfs`, `analyzing-spreadsheets`. Acceptable alternatives are noun phrases (`pdf-processing`) or action form (`process-pdfs`) — but **stay consistent across this repo**. Avoid `helper`, `utils`, `tools`, `data`, `files`.

### Claude Code–only fields

> Using any of these makes the skill **non-uploadable** to claude.ai / the Skills API. See the [portability rule](#portability-rule--this-one-bites-hard). Use deliberately.

| Field | Purpose |
|---|---|
| `when_to_use` | Extra trigger phrases, appended to `description` in the listing. Combined text caps at 1,536 chars. |
| `argument-hint` | Autocomplete hint, e.g. `[issue-number]`. |
| `arguments` | Named positional args for `$name` substitution. |
| `disable-model-invocation` | `true` = Claude never auto-loads it; manual `/name` only. |
| `user-invocable` | `false` = hidden from the `/` menu; Claude-only background knowledge. |
| `disallowed-tools` | Tools removed from the pool while active. |
| `model` | Model override for the turn. Accepts `inherit`. |
| `effort` | `low`/`medium`/`high`/`xhigh`/`max` while active. |
| `context: fork` | Run the skill in a forked subagent. |
| `agent` | Subagent type when `context: fork`. |
| `background` | With `context: fork`, `false` waits for the result inline. |
| `hooks` | Hooks registered on invocation, persisting for the session. |
| `paths` | Glob patterns limiting auto-activation to matching files. |
| `shell` | `bash` (default) or `powershell` for inline command blocks. |

Booleans accept `true/false/yes/no/on/off/1/0`, any case.

---

## Part 4 — Paths, arguments, and `${CLAUDE_SKILL_DIR}`

### The bug this section exists to prevent

A skill that says:

```markdown
Run: `dart run scripts/scaffold.dart`
```

**is broken.** Once installed, the skill lives at `~/.claude/skills/<name>/`, while the working directory is the user's project. `scripts/scaffold.dart` resolves against the project and does not exist. This shipped in this repo and failed on first use for any installer.

### The fix

Claude Code substitutes `${CLAUDE_SKILL_DIR}` — the directory containing `SKILL.md` — in **two places**: the skill's markdown body, and Bash rules in `allowed-tools`. Using it in both lets a bundled script run with no permission prompt:

```yaml
---
name: render-chart
description: Renders a chart from a CSV file. Use when the user asks to plot or chart a CSV.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/render.sh *)
---

Run `${CLAUDE_SKILL_DIR}/scripts/render.sh <csv-file>` to render the chart.
```

**Rules:**
- Never reference a bundled script by a bare relative path.
- `${CLAUDE_PROJECT_DIR}` is the project root — use it for project-local files.
- These substitutions are **Claude Code–only**. A spec-portable skill must instead state plainly which directory the script lives in and that it must be invoked by absolute path.

### Working directory is not a given

A script's own `Directory.current` is wherever Claude happened to be, **not** the skill directory and **not** necessarily the project root. Every script must either not care, or **assert** its expectation:

```dart
// Fail loudly instead of scattering files into the wrong tree.
if (!await File('pubspec.yaml').exists()) {
  stderr.writeln('Error: no pubspec.yaml in ${Directory.current.path}. Run from the project root.');
  exit(1);
}
```

If two scripts in one skill expect different working directories, **say so in a table in SKILL.md.** Silent divergence is a guaranteed bug.

### Argument substitution (Claude Code–only)

| Placeholder | Meaning |
|---|---|
| `$ARGUMENTS` | Everything passed. If absent from the body, appended as `ARGUMENTS: <value>`. |
| `$0`, `$1` | Positional, 0-based. Shell-style quoting, so `"hello world"` is one arg. |
| `$name` | Named arg declared in `arguments`. Unmatched → empty string. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_EFFORT}` | Active effort level. |

Escape a literal with a backslash: `\$1.00`.

---

## Part 5 — Writing the SKILL.md body

### Be concise — Claude is already smart

The context window is a shared public good. Only add what Claude doesn't already know. Challenge every sentence: *"Does this justify its token cost?"*

**Good (~50 tokens):**
```markdown
## Extract PDF text
Use pdfplumber:
    import pdfplumber
    with pdfplumber.open("file.pdf") as pdf:
        text = pdf.pages[0].extract_text()
```

**Bad (~150 tokens):** a paragraph explaining what a PDF is, that libraries exist, and that you install them with pip. Claude knows.

### Under 500 lines

Past that, split into `reference/` files and link them one level deep.

### Reference files must not restate what a script already writes

**This is the failure that produced a real compile-error bug in this repo.** A reference file duplicated code that a scaffold script also generated. The two drifted, and the reference began instructing Claude to write a duplicate extension member — an ambiguous-extension-member compile error.

> A reference file documents how to **extend** what the script produces. It never re-prints the script's own output. One fact, one home.

### Consistent terminology

One term per concept, everywhere. Mixing `endpoint / URL / route / path` makes the model guess. In this repo a single API was documented three incompatible ways (`ErrorHandler.instance.handle()`, `sl<ErrorHandler>().handle()`, `ErrorHandler.handle()`) — two of which did not compile.

**Every API form you write in a doc must be one that actually compiles.** Verify against the source before writing it down.

### No time-sensitive information

Never "before August 2025 use X." Instead:

```markdown
## Current method
Use the v2 API: `api.example.com/v2/messages`

## Old patterns
<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
The v1 API used `api.example.com/v1/messages` — no longer supported.
</details>
```

### Degrees of freedom — match specificity to fragility

Think: narrow bridge with cliffs vs. open field.

- **High freedom** — many valid approaches. Give direction, trust the model.
  ```markdown
  ## Code review process
  1. Analyze structure   2. Check edge cases   3. Suggest readability fixes
  ```
- **Medium freedom** — a preferred pattern with room to vary. Give a template with parameters.
- **Low freedom** — fragile, consistency-critical. Give the exact command and forbid variation.
  ```markdown
  Run exactly: `python scripts/migrate.py --verify --backup`
  Do not modify the command or add flags.
  ```

### Test across models

A skill is an addition to a model, so it inherits that model's behavior. Haiku needs more explicit guidance; Opus needs less over-explaining. If the skill ships publicly, it must work on all three.

---

## Part 6 — Progressive disclosure

**Pattern 1 — guide pointing to references:**
```markdown
## Available datasets
**Finance** — Revenue, ARR → [reference/finance.md](reference/finance.md)
**Sales** — Pipeline, accounts → [reference/sales.md](reference/sales.md)
```
Claude loads only the file the task needs.

**Pattern 2 — domain-split directories.** One file per domain under `reference/`, so a sales question never loads finance schemas.

**Pattern 3 — conditional branching:**
```markdown
## Creating documents
Use docx-js. See [DOCX-JS.md](DOCX-JS.md).
## Editing documents
For simple edits, modify XML directly.
**For tracked changes only**: See [REDLINING.md](REDLINING.md)
```

**Reference files over 100 lines need a `## Contents` block at the top** — so a partial read still reveals the full scope.

---

## Part 7 — Workflows and feedback loops

### Checklist pattern — complex multi-step tasks

```markdown
Copy this checklist and check off as you go:
- [ ] Step 1: Analyze form → `python scripts/analyze_form.py input.pdf`
- [ ] Step 2: Create mapping → edit `fields.json`
- [ ] Step 3: Validate → `python scripts/validate_fields.py fields.json`
- [ ] Step 4: Fill → `python scripts/fill_form.py input.pdf fields.json out.pdf`
- [ ] Step 5: Verify → `python scripts/verify_output.py out.pdf`
```

### Feedback loop — anything that can break silently

**run → validate → fix → repeat.** State explicitly that Claude must not proceed until validation passes.

### Plan-validate-execute — batch or destructive work

Have Claude emit a structured plan file, validate it with a script, *then* execute. Catches errors before anything is written, keeps planning reversible, and makes failures machine-checkable. Use for batch operations, destructive changes, and high-stakes edits.

### Preflight/dry-run — anything that writes to a user's project

> A skill that scaffolds or mutates files **must** offer a no-write mode that reports what it would create, what already exists, and what's missing — and SKILL.md must instruct Claude to run it, show the user, and **ask before applying**.

Implement it as a `--dry-run` flag on the existing script, **not** a second "audit" script. A separate script re-derives the file list and will drift out of sync with the real one — the same duplication failure as [Part 5](#reference-files-must-not-restate-what-a-script-already-writes).

---

## Part 8 — Scripts

Scripts are executed, not read: only output enters context. Prefer them for anything deterministic.

### Solve, don't defer

Handle every error inside the script. Never let it crash and force Claude to improvise.

```python
# Good
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        with open(path, "w") as f:
            f.write("")
        return ""

# Bad — crashes, Claude has to guess
def process_file(path):
    return open(path).read()
```

### No voodoo constants

Every value gets a comment justifying it. *If you don't know the right value, how will Claude?*

```python
REQUEST_TIMEOUT = 30  # Most HTTP requests finish well under 30s; headroom for slow links
MAX_RETRIES = 3       # Most intermittent failures clear by the second retry
```

### Cross-platform correctness is not optional

**A real bug from this repo:** `Process.run('flutter', [...])` in Dart failed with "Flutter SDK not found" on Windows *even with Flutter correctly installed*. Flutter ships as `flutter.bat`; Dart's `Process.run` uses `CreateProcess`, which does **not** resolve `PATHEXT`. The fix is `runInShell: true`.

Generalized rules:
- Forward slashes in every path, always.
- Invoking an external command on Windows? It may be a `.bat`/`.cmd` — go through the shell.
- Don't assume a POSIX tool exists.
- **Actually execute the script on the target OS.** Reading it would never have caught this.

### Idempotency

A scaffold script must be safe to re-run: skip what exists, report it, never silently overwrite. Verify by running twice and diffing — the second run must change nothing.

### Document each script: command + expected output + execute-vs-read

```markdown
**analyze_form.py** — Extract all form fields:
  python scripts/analyze_form.py input.pdf > fields.json
  Output: {"field_name": {"type": "text", "x": 100, "y": 200}}
```

Be explicit about intent:
- "Run `analyze_form.py` to extract fields" → **executes** (output only)
- "See `analyze_form.py` for the algorithm" → **reads** (full source into context)

Default to execute.

### Dependencies by surface

| Surface | Network | Install at runtime |
|---|---|---|
| Claude Code | Full | Yes — locally, never globally |
| Claude API | None | No — pre-installed packages only |
| claude.ai | Varies | Varies |

Always list required packages explicitly in SKILL.md, and never assume one is present.

### MCP tools

Fully qualified names only — `ServerName:tool_name`, e.g. `BigQuery:bigquery_schema`. Without the prefix the tool may not resolve.

### Security

Treat installing a skill like installing software. When auditing one from outside this repo: read **every** bundled file, and look for network calls, credential access, or operations that don't match the stated purpose. Skills that fetch external URLs are especially risky — fetched content can carry injected instructions.

---

## Part 9 — Anti-patterns

| ❌ Anti-pattern | ✅ Fix |
|---|---|
| Bare relative script path (`scripts/x.py`) | `${CLAUDE_SKILL_DIR}/scripts/x.py`, or state the absolute-path requirement |
| Windows paths `scripts\helper.py` | Forward slashes only |
| Reference file restating a script's generated code | Document how to *extend* it; one fact, one home |
| Documenting an API form that doesn't compile | Verify against source before writing |
| Same concept named three ways | One term per concept |
| Claude Code–only frontmatter on a published skill | Restrict to the six spec fields |
| Separate "audit" script beside the real one | `--dry-run` flag on the real one |
| Script that mutates without a preflight | Dry-run, show user, ask, then apply |
| External command assumed to be a native binary | Route through the shell on Windows |
| Script tested by reading, not running | Execute it, on the target OS |
| Scaffold that overwrites on re-run | Idempotent: skip + report |
| Magic numbers | Comment the reason for every constant |
| Time-sensitive text | `<details>` old-patterns block |
| Nested refs (SKILL → a.md → b.md) | One level deep |
| First-person description | Third person |
| Vague description | Specific + explicit triggers |
| Too many options ("pypdf or pdfplumber or…") | One default, escape hatch only if needed |
| Explaining what Claude already knows | Delete it |

---

## Part 10 — Evaluations

**Build evaluations BEFORE writing extensive content.** This is the most-skipped practice in the official guidance. Without evals you write for imagined problems; with them you fix real ones.

1. Run Claude on 3 representative tasks **without** the skill. Document every failure and gap.
2. Write evaluations targeting those gaps.
3. Write the **minimum** content that makes them pass.
4. Iterate: run → observe gap → fix → repeat.

```json
{
  "skills": ["your-skill-name"],
  "query": "Extract all text from this PDF and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Reads the PDF using an appropriate library",
    "Extracts text from all pages without skipping any",
    "Saves extracted text to output.txt in readable format"
  ]
}
```

There is no built-in runner — these are a rubric you check against.

### The two-Claude loop

Use **Claude A** (helps author the skill) and **Claude B** (a fresh instance that *uses* it on real tasks). Watch B, bring findings back to A. Refine on observed behavior, never assumptions.

### Watch how Claude navigates

- **Unexpected read order** → structure isn't intuitive
- **Missed reference** → link isn't explicit enough
- **Same file read repeatedly** → that content belongs in SKILL.md
- **File never touched** → unnecessary, or poorly signaled

---

## Part 11 — Shipping checklist

### Discovery
- [ ] `name`: lowercase/hyphens, ≤64 chars, no reserved words, matches folder + `skills.sh.json`
- [ ] `description`: third person, ≤1,024 chars, states what **and** when, key use case first
- [ ] Frontmatter restricted to the six spec fields (or the Claude Code–only dependency is documented)

### Content
- [ ] SKILL.md body under 500 lines
- [ ] Overflow in `reference/`, linked one level deep
- [ ] Reference files >100 lines open with `## Contents`
- [ ] No reference file restates code a script generates
- [ ] Every documented API form verified to compile
- [ ] Consistent terminology throughout
- [ ] No time-sensitive info outside a `<details>` block
- [ ] Complex workflows have a checklist and a feedback loop

### Scripts
- [ ] Referenced via `${CLAUDE_SKILL_DIR}` or an explicit absolute-path instruction — never a bare relative path
- [ ] Working-directory expectations asserted in-script and documented in SKILL.md
- [ ] All errors handled in-script; nothing deferred to Claude
- [ ] No magic numbers
- [ ] Idempotent — verified by running twice and diffing
- [ ] Mutating scripts expose `--dry-run`, and SKILL.md mandates preflight → show → ask → apply
- [ ] External commands work on Windows (shell resolution for `.bat`/`.cmd`)
- [ ] Forward slashes everywhere
- [ ] Required packages listed explicitly
- [ ] Execute-vs-read intent explicit for every script

### Testing
- [ ] **Scripts actually executed**, not just read — on the target OS
- [ ] ≥3 evaluations written and passing
- [ ] Tested with Haiku, Sonnet, and Opus
- [ ] Navigation observed with a fresh Claude, and gaps fixed

### Repo
- [ ] Folder under `skills/<domain>/<name>/`
- [ ] Registered in `skills.sh.json`
- [ ] Row added to `README.md`
- [ ] Dev sandbox copy re-synced from the published source

---

*Primary sources: platform.claude.com Agent Skills overview and best-practices; code.claude.com skills reference; agentskills.io spec. Repo-specific rules derived from audited bugs in `bootstrapping-flutter-mvvm`.*
