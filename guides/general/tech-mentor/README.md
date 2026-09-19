# What `tech-mentor` does

This guide explains [`skills/general/tech-mentor/`](../../../skills/general/tech-mentor/), a portable Agent Skills package for designing or auditing technology learning and career paths.

## What it is

`tech-mentor` acts as a critical technical mentor and learning-system builder. It turns a learner's target role or real-world task into a proportionate Markdown workspace with prerequisite mapping, current research, deliberate practice, portfolio evidence, and evidence-based checkpoints.

It supports two modes:

| Mode | Result |
|---|---|
| **Create from zero** | Uses adaptive discovery, then creates a compact, standard, or large learning workspace. |
| **Review an existing plan** | Audits first, reports prioritized findings, and creates a separate revised workspace only after approval. |

## How it works

The skill asks three to five related, high-impact questions at a time, then follows up only when an answer could change the scope, sequence, depth, pace, technology choice, resources, role, or evidence requirement. Guided self-assessment is enough to receive a plan; an optional short diagnostic is used only when a consequential placement decision is unclear.

It works backward from:

```text
target capability → real work tasks → competencies → prerequisites
→ learner gaps → resources and practice → observable evidence
```

Learner claims are treated as hypotheses. Existing experience is reused only when evidence supports the transfer; unrealistic deadlines and “learn everything” goals are narrowed into testable milestones.

## Output

The workspace scales to the required work, dependencies, learner baseline, and proof—not the technology name alone.

| Scale | Use | Initial output |
| --- | --- | --- |
| **Compact** | One focused outcome, such as Python file automation | `README.md`, focused learning plan, proof project |
| **Standard** | One connected capability, such as a small Python backend | Learning contract, skills audit, roadmap, resources, current unit, capstone project |
| **Large** | Multiple capability areas, such as Odoo development for a defined domain | Master roadmap, capability tracks, first project, and progress checkpoint |

Large workspaces detail only the current track or phase at first. Later lesson files are created after learner evidence supports advancing.

Every learning unit explains why it matters, prerequisites, scope, concepts, practice, a real-work task, AI support, self-checks, readiness evidence, review timing, and the adjustment route if the learner is blocked.

Courses are selected as curriculum components, not link collections. Each resource must close a specific gap and lead to an observable task or proof artifact.

Technical quality is introduced proportionately: testing, debugging, security, documentation, architecture, and deployment appear when the target role or project needs them. Framework-specific conventions take priority over generic rules.

At each checkpoint, the learner supplies evidence such as an artifact, explanation, test result, outcome, or blocker. The next step is explicit: continue, refresh, simplify, extend, re-plan, or investigate with an optional diagnostic.

## Evidence and currency

Current technical claims use direct authoritative sources where available. The output separates verified facts, recommendations, assumptions, and learner decisions. Version choices record compatibility and rationale rather than automatically selecting the newest release.

Before delivery, the skill runs its DocsGuard adaptation to check technical claims, links, version-dependent details, examples, navigation, and unsupported certainty.

## What it does not do

- It does not replace a learner's plan without an audit and approval; approved revisions create a separate workspace and preserve the source plan.
- It does not promise employment, salary, certification, or production readiness without evidence.
- It does not install software, buy or enroll in courses, apply for jobs, or implement the learner's final project unless separately requested.
- It does not rewrite upstream manuals into long copied lessons; it links authoritative documentation and teaches only what the learner needs.

## More detail

- [`SKILL.md`](../../../skills/general/tech-mentor/SKILL.md)
- [`tests/scenarios.md`](../../../skills/general/tech-mentor/tests/scenarios.md)
