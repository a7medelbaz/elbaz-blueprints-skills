# Learning-path design

Work backward from capability:

```text
target capability → real work tasks → competencies → prerequisite graph
→ learner gap map → resources/practice → observable evidence
```

Classify each competency as `demonstrated`, `learner-reported`, `verify or refresh`, `required now`, `required later`, `optional`, or `out of scope`.

## Scale the workspace

Choose scale from the learner's target work, dependency graph, demonstrated baseline, required evidence, and number of independent competency areas. Do not infer scale from a technology name alone: Python can support a compact automation task or a large backend path; Odoo can be a narrow functional workflow or a broad developer roadmap.

| Scale | Choose when | Detail timing |
| --- | --- | --- |
| Compact | One concrete outcome, limited prerequisites, and one proof task | Detail all units initially. |
| Standard | One coherent capability, connected competencies, and one substantial project | Detail the current unit; roadmap the remaining work. |
| Large | Multiple independent competency areas, business domains, target roles, or substantial prerequisite chains | Detail only the current phase; disclose later units at checkpoints. |

For a large request, first narrow the target role, business domain, version/environment, and real workflows. Treat “learn all Odoo” as a scope-discovery request, not permission to create an encyclopedic course.

Escalate a plan when discovery reveals another independent competency area, proof project, work domain, or prerequisite chain. Reduce it when the required outcome is narrower than the named technology or the learner already demonstrates major dependencies. At checkpoints, reclassify when evidence changes the baseline or scope; preserve completed evidence and adjust only unfinished work. State the selected scale, supporting evidence, and the condition that would change it.

## Learning units

Use this schema for every lesson or project unit:

```md
# Unit: <capability>

## Why this matters
## Prerequisites
## Scope and exclusions
## Learn
## Practice
## Real-work task
## AI support
## Self-check
## Ready to continue when
## Review later
## If blocked or weak
```

- **Why this matters** connects the capability to the learner's intended work.
- **Prerequisites** and **Scope and exclusions** prevent misplaced or premature study.
- **Learn** names only the concepts and selected current sources needed for the task. Prefer official documentation for technical facts; do not reproduce an upstream manual.
- **Practice** builds toward a **Real-work task** that resembles the target environment.
- **AI support** provides prompts for level-appropriate explanation, hints without a solution, review against requirements, targeted extra practice, and scenario or interview simulation.
- **Self-check** asks the learner to explain decisions and handle a variation.
- **Ready to continue when** defines the required artifact, explanation, test result, or other evidence.
- **Review later** schedules retrieval work. **If blocked or weak** directs the learner to refresh, simplify, or seek a diagnostic.

Use this cycle:

```text
understand → build → explain → self-test → revisit later → apply in a larger task
```

Design weekly sprints around a realistic outcome, learning activities, build task, verification, review schedule, and decision gate. Avoid precise hours or dates when inputs do not justify them. Use [adaptation-loop](adaptation-loop.md) for checkpoint decisions and plan updates.
