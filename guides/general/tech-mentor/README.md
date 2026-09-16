# What `tech-mentor` does

This guide explains [`skills/general/tech-mentor/`](../../../skills/general/tech-mentor/), a portable Agent Skills package for designing or auditing technology learning and career paths.

## What it is

`tech-mentor` acts as a critical technical mentor. It turns a learner's target role or real-world task into a focused path with prerequisite mapping, current research, deliberate practice, portfolio evidence, and checkpoints.

It supports two modes:

| Mode | Result |
|---|---|
| **Create from zero** | Discovers the learner's outcome, baseline, constraints, and proof requirements, then designs a proportionate learning path. |
| **Review an existing plan** | Audits the plan first, reports prioritized findings, and revises it only after the learner requests or approves revision. |

## How it works

The skill asks at most one question at a time, and only when the answer could change the scope, sequence, time estimate, technology version, resource choice, role recommendation, or evidence requirement.

It works backward from:

```text
target capability → real work tasks → competencies → prerequisites
→ learner gaps → resources and practice → observable evidence
```

Learner claims are treated as hypotheses. Existing experience is reused only when evidence supports the transfer; unrealistic deadlines and “learn everything” goals are narrowed into testable milestones.

## Output

The workspace is sized to the goal. A narrow API or language milestone stays compact. A broad career path may include a learning contract, skills audit, roadmap, resource evaluation, tracks, projects, progress records, and career-readiness evidence.

Courses are selected as curriculum components, not link collections. Each resource must close a specific gap and lead to an observable task or proof artifact.

Technical quality is introduced proportionately: testing, debugging, security, documentation, architecture, and deployment appear when the target role or project needs them. Framework-specific conventions take priority over generic rules.

## Evidence and currency

Current technical claims use direct authoritative sources where available. The output separates verified facts, recommendations, assumptions, and learner decisions. Version choices record compatibility and rationale rather than automatically selecting the newest release.

Before delivery, the skill runs its DocsGuard adaptation to check technical claims, links, version-dependent details, examples, navigation, and unsupported certainty.

## What it does not do

- It does not replace a learner's plan without an audit and approval.
- It does not promise employment, salary, certification, or production readiness without evidence.
- It does not install software, buy or enroll in courses, apply for jobs, or implement the learner's final project unless separately requested.
- It does not rewrite upstream manuals into long copied lessons; it links authoritative documentation and teaches only what the learner needs.

## More detail

- [`SKILL.md`](../../../skills/general/tech-mentor/SKILL.md)
- [`tests/scenarios.md`](../../../skills/general/tech-mentor/tests/scenarios.md)
