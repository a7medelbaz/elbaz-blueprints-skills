# Workspace output schema

Choose the smallest truthful Markdown workspace that supports the selected scale. Create a file or folder only when it has substantive current content.

## Compact workspace

Use for one focused outcome:

```text
README.md
learning-plan.md
proof-project.md
```

- `README.md` owns the learner profile, goal, pace, and start point.
- `learning-plan.md` owns the focused units and learning loop.
- `proof-project.md` owns the real-work task, acceptance criteria, and completion proof.

Embed resources in the relevant unit unless they are substantial enough to deserve their own file.

## Standard workspace

Use for one coherent capability with connected competencies and a substantial project:

```text
README.md
00-learning-contract.md
01-skills-audit.md
02-roadmap.md
resources.md
projects/
  capstone-project.md
units/
  01-current-unit.md
```

The roadmap owns the sequence and dependencies. Create detailed content only for the current unit; create the next unit after the learner reaches the relevant checkpoint.

## Large workspace

Use for multiple independent capabilities, domains, roles, or substantial prerequisites:

```text
README.md
00-learning-contract.md
01-skills-audit-and-gap-map.md
02-master-roadmap.md
resources.md
tracks/
  <active-track>.md
projects/
  <first-project>.md
progress/
  <first-checkpoint>.md
```

Tracks own independent capability areas. Projects prove real work. Progress records checkpoint evidence and adjustments. Fully detail only the active track and first project; the roadmap describes later work.

## Navigation and claim labels

`README.md` is the navigation map. It states the learner outcome, selected scale, current phase, next action, and links only to files that exist. Units and projects link back to the roadmap. When a checkpoint changes sequence, pace, scope, or dependencies, update the roadmap before creating the next file.

Every document labels claims as `verified fact`, `recommendation`, `assumption`, or `learner decision`. Include evidence, checkpoints, review dates, and adjustment rules where relevant. Do not create empty templates or filler sections.
