# CREATE_SKILL.md
> **Authoritative reference for building Claude Agent Skills**
> Based on official Anthropic docs — verified August 2026
> Place in project root. Claude Code reads this when building any skill.

---

## This repo: elbaz-blueprints

This repo is a personal skills package (`elbaz-blueprints`) distributed via
[skills.sh](https://skills.sh). Everything below in this file is the general
Anthropic skill-authoring standard — this section is what's specific to
building a skill **in this repo**.

**Published layout:**
```
elbaz-blueprints/
├── skills.sh.json           ← package manifest, must list every skill
└── skills/
    ├── flutter/
    │   └── bootstrapping-flutter-mvvm/   ← one real skill, use as your template
    └── <domain>/
        └── <skill-name>/
```

**Workflow for adding or changing a skill:**
1. Build and iterate locally in `.claude/skills/` (this project) or `~/.claude/skills/` (global, all projects) — this is the dev sandbox.
2. Once it passes the evaluation checklist below, copy it into `skills/<domain>/<skill-name>/` — pick the existing domain folder it belongs to, or create a new one.
3. Register it in `skills.sh.json` under `"skills"`: `name`, `path`, `description`.
4. Add a row for it to the table in `README.md`.
5. Commit and push — skills.sh syncs from GitHub automatically.

**Hard rules for this repo:**
- Never add an entry to `skills.sh.json` without the matching skill folder existing under `skills/`, and vice versa.
- The skill folder name must exactly match the `"name"` field in both `skills.sh.json` and the `SKILL.md` frontmatter.
- `skills/` is the published source of truth. `.claude/skills/` and `~/.claude/skills/` are dev sandboxes only — never the other way around.
- Prefer nesting a new skill under an existing domain folder (`flutter/`, `odoo/`, …) before creating a new domain.

---

## Quick orientation

**What is a skill?** A directory with a `SKILL.md` file (+ optional scripts and reference files).
Claude Code auto-discovers skills from:
- `.claude/skills/` — this project only
- `~/.claude/skills/` — all projects on this machine

In this repo, skills also live published under `skills/<domain>/<skill-name>/` — see
"This repo: elbaz-blueprints" above for how that maps to the sandbox locations.

**The 3-level loading model (progressive disclosure):**

| Level | Loaded when | Token cost | Content |
|---|---|---|---|
| 1 — Metadata | Always, at startup | ~100 tokens per skill | `name` + `description` only |
| 2 — Instructions | When skill is triggered | Under 5k tokens | Full `SKILL.md` body |
| 3 — Resources | Only when accessed | Zero until read | Reference files + scripts |

This means 50 installed skills costs only ~5k tokens at startup (50 × 100 token descriptions).
The body and resources load only when the skill is actually used.

---

## Directory structure

```
my-skill/
├── SKILL.md          ← REQUIRED. YAML frontmatter + instructions.
├── REFERENCE.md      ← Optional. Deep API / domain reference.
├── EXAMPLES.md       ← Optional. Concrete input/output examples.
├── FORMS.md          ← Optional. Subtopic or workflow guide.
└── scripts/
    ├── analyze.py    ← Optional. Executed by Claude, output only enters context.
    └── validate.py
```

**Hard rules:**
- All reference files must be **one level deep** from `SKILL.md` — never nest deeper
- Never: `SKILL.md → advanced.md → details.md` (Claude may only partially read nested files)
- Always **forward slashes** in paths — never backslashes

---

## Full worked example (read this first)

```
bigquery-analysis/
├── SKILL.md
└── reference/
    ├── finance.md
    ├── sales.md
    └── product.md
```

**`SKILL.md`:**
```
---
name: analyzing-bigquery-data
description: Queries and analyzes BigQuery datasets for finance, sales, and product metrics. Use when the user asks for SQL queries, revenue metrics, pipeline reports, or BigQuery analysis.
---

# BigQuery Data Analysis

## Available datasets

**Finance** — Revenue, ARR, billing → [reference/finance.md](reference/finance.md)
**Sales** — Opportunities, pipeline, accounts → [reference/sales.md](reference/sales.md)
**Product** — API usage, features, adoption → [reference/product.md](reference/product.md)

## Quick search

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
```

## Rules — always apply these

- ALWAYS filter test accounts: `WHERE account_type != 'test'`
- Use UTC timestamps for all date comparisons
- Q4 reporting: filter `date >= '2025-10-01'`
```

---

## YAML frontmatter — exact rules

### `name` field
- Max **64 characters**
- Lowercase letters, numbers, hyphens **only** — no spaces
- No XML tags
- No reserved words: `anthropic`, `claude`
- **Preferred style:** gerund form — `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`

### `description` field
- **Non-empty**, max **1,024 characters**
- No XML tags
- **Third person only** — this string is injected directly into the system prompt
- Must say BOTH: **what it does** AND **when to trigger it**
- Include specific trigger keywords

**Good descriptions:**
```yaml
# Specific, third person, has trigger keywords
description: Analyzes Excel spreadsheets, creates pivot tables, generates charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.

# Action + trigger context
description: Generates descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

**Bad descriptions — never write these:**
```yaml
description: Helps with documents          # Too vague, no triggers
description: I can help you process Excel  # Wrong — first person
description: Processes data                # No trigger context
```

---

## SKILL.md body — writing rules

### Be concise — Claude is already smart

Only add what Claude doesn't already know. Challenge every sentence: *"Does Claude need this?"*

**Good (~50 tokens):**
```
## Extract PDF text
Use pdfplumber:
  import pdfplumber
  with pdfplumber.open("file.pdf") as pdf:
      text = pdf.pages[0].extract_text()
```

**Bad (~150 tokens — avoid):**
```
## Extract PDF text
PDF (Portable Document Format) files are a common format that contains text and images.
To extract text, you need a library. There are many available, but pdfplumber is
recommended because it is easy to use. First install it with pip. Then use the code below...
```

The bad version explains things Claude already knows.

### Keep SKILL.md under 500 lines
Move anything beyond ~500 lines to a reference file and link to it.

### Use consistent terminology
Pick one term per concept. Use it everywhere.
- ✅ Always "API endpoint"
- ❌ Mix of "endpoint / URL / route / path"

### No time-sensitive information
Never write "Before August 2025 use X, after use Y." Instead:

```
## Current method
Use the v2 API: `api.example.com/v2/messages`

## Old patterns
<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
The v1 API used: `api.example.com/v1/messages` — no longer supported.
</details>
```

---

## Degrees of freedom — how specific to be

Match specificity to the task's fragility. Think: narrow bridge vs. open field.

### High freedom — flexible guidance (multiple valid approaches)
```
## Code review process
1. Analyze structure and organization
2. Check for bugs and edge cases
3. Suggest readability improvements
4. Verify project conventions
```

### Medium freedom — template with parameters
```
## Generate report
Use this template and adapt as needed:
  def generate_report(data, format="markdown", include_charts=True):
      # Process data, generate output in specified format
```

### Low freedom — exact commands (fragile, consistency-critical)
```
## Database migration
Run exactly:
  python scripts/migrate.py --verify --backup
Do not modify the command or add flags.
```

---

## Progressive disclosure patterns

### Pattern 1: High-level guide pointing to reference files
```
# BigQuery Analysis

## Available datasets
**Finance**: Revenue, ARR → See [reference/finance.md](reference/finance.md)
**Sales**: Pipeline, accounts → See [reference/sales.md](reference/sales.md)

## Quick search
  grep -i "revenue" reference/finance.md
```
Claude loads only the file the task needs. Others stay on disk.

### Pattern 2: Conditional branching
```
# DOCX Processing

## Creating documents
Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents
For simple edits, modify XML directly.
**For tracked changes only**: See [REDLINING.md](REDLINING.md)
```

### Pattern 3: Reference files over 100 lines → add table of contents
```
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Error handling
- Examples

## Authentication and setup
...
```
This ensures Claude sees the full scope even when previewing partially.

---

## Workflows and feedback loops

### Checklist pattern — for complex multi-step tasks
```
## Form filling workflow

Copy this checklist and check off as you go:
- [ ] Step 1: Analyze form → `python scripts/analyze_form.py input.pdf`
- [ ] Step 2: Create field mapping → edit `fields.json`
- [ ] Step 3: Validate mapping → `python scripts/validate_fields.py fields.json`
- [ ] Step 4: Fill form → `python scripts/fill_form.py input.pdf fields.json output.pdf`
- [ ] Step 5: Verify output → `python scripts/verify_output.py output.pdf`
```

### Feedback loop pattern — for quality-critical operations
```
## Document editing process
1. Make your edits to `word/document.xml`
2. Validate immediately: `python scripts/validate.py output_dir/`
3. If validation fails: fix issues → validate again
4. Only proceed when validation passes
5. Rebuild: `python scripts/pack.py unpacked_dir/ output.docx`
```
Always include **run → validate → fix → repeat** for anything that can break silently.

---

## Content patterns

### Template pattern (strict output format)
```
## Report structure

ALWAYS use this exact template:

# [Analysis Title]

## Executive summary
[One paragraph]

## Key findings
- Finding with supporting data

## Recommendations
1. Specific action
```

### Examples pattern (input/output pairs)
```
## Commit message format

Example 1:
  Input: Added JWT authentication
  Output:
    feat(auth): implement JWT-based authentication
    Add login endpoint and token validation middleware

Example 2:
  Input: Fixed date display bug in reports
  Output:
    fix(reports): correct date formatting in timezone conversion
```
Examples show desired style far better than descriptions alone.

### Conditional workflow pattern
```
## Document modification

1. Determine type:
   - Creating new? → Follow "Creation workflow" below
   - Editing existing? → Follow "Editing workflow" below

2. Creation workflow: use docx-js, build from scratch, export .docx
3. Editing workflow: unpack → modify XML → validate → repack
```
If workflows grow large, push them to separate files and point to them.

---

## Scripts — best practices

Scripts are **executed**, not read. Only their output enters the context window.
This makes scripts far more efficient than asking Claude to generate equivalent code.

### Solve, don't defer — handle all errors in the script

```python
# Good: explicit error handling
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        with open(path, "w") as f:
            f.write("")
        return ""

# Bad: crashes and forces Claude to improvise
def process_file(path):
    return open(path).read()
```

### No magic numbers — justify all values in comments

```python
# Good
REQUEST_TIMEOUT = 30  # Most HTTP requests complete within 30s; extended for slow connections
MAX_RETRIES = 3       # Most intermittent failures resolve by the second retry

# Bad — why 47? why 5?
TIMEOUT = 47
RETRIES = 5
```

### Document each script with command and expected output

```
## Utility scripts

**analyze_form.py** — Extract all form fields:
  python scripts/analyze_form.py input.pdf > fields.json
  Output: {"field_name": {"type": "text", "x": 100, "y": 200}}

**validate.py** — Run after every edit:
  python scripts/validate.py output_dir/
  Returns: "OK" or a list of specific errors with line numbers
```

### Be explicit: execute vs. read

- "Run `analyze_form.py` to extract fields" → Claude **executes** it (output only in context)
- "See `analyze_form.py` for the algorithm" → Claude **reads** it (full source in context)

Default to **execute** — it's more efficient.

### Package dependencies by surface

| Surface | Network | pip install |
|---|---|---|
| Claude Code | Full | Yes (install locally, not globally) |
| Claude API | None | No — pre-installed packages only |
| claude.ai | Varies | Yes |

Always list required packages explicitly in SKILL.md.

---

## MCP tool references

Always use fully qualified names — without the server prefix, Claude may not find the tool:

```
Use BigQuery:bigquery_schema to retrieve table schemas.
Use GitHub:create_issue to file issues.
```
Format: `ServerName:tool_name`

---

## Anti-patterns — never do these

| ❌ Anti-pattern | ✅ Fix |
|---|---|
| Windows paths: `scripts\helper.py` | Forward slashes only: `scripts/helper.py` |
| Too many options: "use pypdf, or pdfplumber, or PyMuPDF..." | Pick one default; mention fallback only if needed |
| Time-sensitive: "Before Aug 2025 use X, after use Y" | Use `<details>` old-patterns block |
| Deeply nested refs: SKILL → advanced → details | One level deep only: SKILL → file |
| Magic numbers with no explanation | Comment every constant with the reason |
| Scripts that crash on bad input | Handle all errors explicitly in the script |
| First-person description: "I can help you..." | Third person: "Processes and analyzes..." |
| Vague description: "Helps with documents" | Specific + triggers: "Extracts text from PDFs. Use when..." |
| Assuming packages are installed | List required packages explicitly |
| Explaining what Claude already knows | Only add context Claude doesn't have |

---

## Build evaluations FIRST — before writing content

This is the most important practice from the official docs and the most commonly skipped.

**Why:** Without evaluations, you write for imagined problems. With them, you fix real gaps.

### Step-by-step
1. Run Claude on 3 representative tasks **without** the skill. Document every failure or gap.
2. Write evaluations that test those specific gaps (see format below).
3. Write the minimum SKILL.md content that makes those evaluations pass.
4. Iterate: run eval → observe gap → fix → repeat.

### Evaluation format
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
Create at least 3 evaluations before writing extensive skill content.

### Observe how Claude navigates the skill
As you test, watch for:
- **Unexpected read order:** Claude reads files in a surprising sequence → your structure isn't intuitive
- **Missed references:** Claude doesn't follow a link to a reference file → make the link more explicit
- **Repeated reads:** Claude reads the same file multiple times → move that content to SKILL.md
- **Ignored files:** Claude never touches a bundled file → it's either unnecessary or poorly signaled

Iterate based on what you observe, not on what you assume.

---

## Evaluation checklist — run before finishing any skill

### Core quality
- [ ] `name`: lowercase, hyphens only, max 64 chars, no reserved words (`anthropic`, `claude`)
- [ ] `description`: third person, specific, includes trigger keywords, max 1024 chars
- [ ] `description`: says BOTH what it does AND when to trigger it
- [ ] `SKILL.md` body is under 500 lines
- [ ] All overflow content is in separate files, linked one level deep from SKILL.md
- [ ] No time-sensitive information (or isolated in `<details>` old-patterns block)
- [ ] Consistent terminology throughout — one term per concept
- [ ] Examples are concrete input/output pairs, not abstract descriptions
- [ ] Complex workflows have a checklist and a feedback loop

### Code and scripts
- [ ] Scripts handle all errors — never defer to Claude
- [ ] No magic numbers — every constant has a comment explaining the value
- [ ] Required packages listed explicitly in SKILL.md
- [ ] All paths use forward slashes
- [ ] Each script documented with example command + expected output format
- [ ] Execute vs. read intent is explicit for every script mentioned

### Testing
- [ ] At least 3 evaluations written and passed
- [ ] Tested with target model(s) — Haiku needs more detail than Opus
- [ ] Observed Claude's actual navigation paths (not assumed)
- [ ] Iterated based on observed gaps

---

*Sources: platform.claude.com/docs/en/agents-and-tools/agent-skills/overview and /best-practices — August 2026*
