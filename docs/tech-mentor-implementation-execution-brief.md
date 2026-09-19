# Execution Brief: Implement the Tech Mentor Learning-System Redesign

You are implementing the approved redesign of the `tech-mentor` skill in this repository. Work incrementally and preserve the user's approval gates.

Use this brief only in a checkout where the listed implementation phases have not already been completed.

## Authoritative plans

Read these files completely before changing any published skill file:

1. [Master design plan](tech-mentor-learning-system-plan.md)
2. [Implementation plan](tech-mentor-learning-system-implementation-plan.md)
3. Repository `AGENTS.md`

The master design plan defines the approved behavior. The implementation plan defines the order of work and acceptance criteria. If they conflict, stop and report the conflict; do not guess.

## Operating contract

1. Implement **one implementation phase only** per user approval.
2. Before editing, inspect the affected files and explain the specific changes planned for that phase.
3. Do not begin a later phase merely because an earlier phase is complete.
4. Do not change unrelated skills or documentation.
5. Preserve existing-plan review as audit-first. Do not create or rewrite a learner plan unless the approved behavior permits it.
6. Keep `SKILL.md` concise. Put detailed, branch-specific procedure in the references identified by the implementation plan.
7. Do not add empty templates, folders, or files to generated learner workspaces.
8. Research current technical or version-specific claims from direct official sources when the task requires them. Record source, review date, and status as the skill design requires.
9. Use `apply_patch` for focused edits.

## Per-phase workflow

For the approved phase:

1. Read the phase's affected files and the relevant design sections.
2. State the intended edits and the phase acceptance criteria.
3. Make only those edits.
4. Validate all referenced paths and Markdown links touched by the phase.
5. Run relevant package or scenario validation where available.
6. Review changed documentation against the actual skill behavior.
7. Report:
   - files changed;
   - acceptance criteria satisfied;
   - validation performed and results;
   - anything requiring a user decision.
8. Stop and wait for approval before the next phase.

## Implementation phases

### Phase I — Discovery and routing

Implement adaptive question sets, guided self-assessment, optional micro-diagnostics, required inputs, stop rules, and skill routing.

Files:

- `skills/general/tech-mentor/SKILL.md`
- `skills/general/tech-mentor/references/discovery-and-critique.md`

### Phase II — Scaling and workspace generation

Implement compact, standard, and large scaling rules; workspace schemas; navigation; and progressive file creation.

Files:

- `skills/general/tech-mentor/SKILL.md`
- `skills/general/tech-mentor/references/learning-path-design.md`
- `skills/general/tech-mentor/references/workspace-output-schema.md`

### Phase III — Learning units and adaptation

Implement the task-first learning-unit schema and create the adaptation-loop reference.

Files:

- `skills/general/tech-mentor/SKILL.md`
- `skills/general/tech-mentor/references/learning-path-design.md`
- `skills/general/tech-mentor/references/adaptation-loop.md` (new)

### Phase IV — Existing-plan review integration

Implement approved-revision behavior while preserving audit-first review and the original learner plan.

Files:

- `skills/general/tech-mentor/SKILL.md`
- `skills/general/tech-mentor/references/existing-plan-review.md`

### Phase V — Public documentation and scenarios

Align the human guide, repository README, package manifest, and behavioral scenarios with the implemented behavior.

Files:

- `guides/general/tech-mentor/README.md`
- `README.md`
- `skills.sh.json`
- `skills/general/tech-mentor/tests/scenarios.md`

### Phase VI — Validation and release review

Validate the final skill with compact Python, standard Python backend, large Odoo, and existing-plan-review scenarios. Verify package structure, links, documentation accuracy, and consistency across all published surfaces.

## Start condition

Ask the user which implementation phase they approve. If they approve Phase I, begin only Phase I.
