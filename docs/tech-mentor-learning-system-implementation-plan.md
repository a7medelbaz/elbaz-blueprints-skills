# Tech Mentor Learning-System Implementation Plan

## Purpose

Implement the approved design in [the master plan](tech-mentor-learning-system-plan.md) through small, reviewable phases. Do not begin a phase until the preceding phase is validated and approved.

Status: all phases completed and release-reviewed.

## Constraints

- Preserve the current audit-first behavior for existing-plan review.
- Keep the skill entrypoint concise; place substantial branch-specific rules in references.
- Do not create empty generated workspace files or folders.
- Keep the skill, guide, root README, manifest, and behavioral scenarios consistent.
- Validate behavior, not exact generated phrasing.

## Phase I — Discovery and routing

### Files

- `skills/general/tech-mentor/SKILL.md`
- `skills/general/tech-mentor/references/discovery-and-critique.md`

### Changes

1. Replace the one-question-per-turn instruction with adaptive sets of three to five related high-impact questions.
2. Add the universal discovery areas: outcome, baseline, evidence, time/context, and target proof.
3. Add subject-specific follow-up routing.
4. Add the guided self-assessment scale and provisional learner-reported placement.
5. Add optional, targeted micro-diagnostic rules.
6. Add required inputs and stop rules.

### Acceptance criteria

- A learner can receive a plan without submitting code or passing a test.
- The skill seeks enough information to change the plan, but no irrelevant background.
- Diagnostics are optional and resolve a consequential uncertainty.

## Phase II — Scaling and workspace generation

### Files

- `skills/general/tech-mentor/SKILL.md`
- `skills/general/tech-mentor/references/learning-path-design.md`
- `skills/general/tech-mentor/references/workspace-output-schema.md`

### Changes

1. Add compact, standard, and large classification rules based on target work and dependencies.
2. Add scale adjustment rules.
3. Define the approved compact, standard, and large workspace schemas.
4. Add progressive file-creation and navigation rules.

### Acceptance criteria

- A narrow Python task remains compact.
- A broad Odoo request is narrowed by role/domain before becoming a large roadmap.
- Every generated file has real content and the README links only to existing files.

## Phase III — Learning units and adaptation

### Files

- `skills/general/tech-mentor/references/learning-path-design.md`
- `skills/general/tech-mentor/references/adaptation-loop.md` (new)
- `skills/general/tech-mentor/SKILL.md`

### Changes

1. Add the approved task-first learning-unit schema.
2. Add official-source and AI-support rules for units.
3. Create the adaptation-loop reference with checkpoint triggers, decisions, progress records, and scale-specific cadence.
4. Link the new reference from the skill entrypoint.

### Acceptance criteria

- Every learning unit contains purpose, practice, real-work task, AI support, and ready-to-continue evidence.
- Checkpoints use evidence rather than calendar time to determine advancement.
- A changed plan preserves completed work.

## Phase IV — Existing-plan review integration

### Files

- `skills/general/tech-mentor/SKILL.md`
- `skills/general/tech-mentor/references/existing-plan-review.md`

### Changes

1. Keep the audit-first report format.
2. Add approved-revision behavior: derive a new learning workspace while preserving the original plan.
3. Add partial-approval and explicit in-place-edit rules.

### Acceptance criteria

- Review-only requests do not create or modify a plan.
- An approved revision creates a correctly scaled learning workspace.
- In-place edits require an explicit request and confirmed target.

## Phase V — Public documentation and scenarios

### Files

- `guides/general/tech-mentor/README.md`
- `README.md`
- `skills.sh.json`
- `skills/general/tech-mentor/tests/scenarios.md`

### Changes

1. Describe the skill as a learning-system builder, not only a path recommender.
2. Explain compact, standard, and large workspace outputs.
3. Update published short descriptions.
4. Add or revise behavioral scenarios for compact Python, standard Python backend, large Odoo, and review-to-workspace.

### Acceptance criteria

- Public descriptions match the implemented behavior.
- Scenarios test decisions, output scale, and safeguards without asserting exact prose.

## Phase VI — Validation and release review

### Checks

1. Run the skill package validator if available in the active environment.
2. Verify all Markdown links and referenced files.
3. Run the four approved behavioral scenarios.
4. Review the documentation against source behavior and remove stale or duplicated claims.
5. Inspect the final change set for consistency across all published surfaces.

### Completion criteria

- The skill loads only references relevant to its mode and scope.
- All four scenarios satisfy the approved design.
- Documentation and manifest descriptions accurately describe the final behavior.
- No generated workspace schema requires empty placeholders or a mandatory diagnostic.
