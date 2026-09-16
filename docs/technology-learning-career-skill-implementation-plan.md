# Technology Learning & Career Path Architect — Implementation Plan

## Status

Planning specification only. Do not create, install, publish, or modify the
skill until this plan is reviewed and approved.

## Purpose

Create one Codex skill that helps a person build or improve an evidence-based,
personalized learning path for a technology or technology career. The intended
result is demonstrated real-world capability and career readiness, not merely a
list of courses or a generic technology review.

Examples include learning Python, Node.js, Odoo functional implementation,
Odoo development, Flutter backend skills, SQL for a specific role, or a
technology stack required by a career target.

## Decisions Already Made

- Deliver **one skill** with two clear modes:
  1. Create a personalized learning path from zero.
  2. Audit and improve an existing learning path.
- Technology research is an internal capability that supports the learning
  decision; it is not the primary outcome by itself.
- The skill must act as a critical technical mentor. It must challenge
  assumptions, choices, unrealistic scope, and weak evidence before generating
  a plan.
- It asks one concise clarification at a time, and only where the answer can
  materially change the recommendation or plan.
- It uses current sources, prioritizing official documentation, release notes,
  specifications, and maintainers' material.
- "Newest" is not automatically selected. The skill chooses a maintained,
  compatible, context-appropriate version and explains the choice.
- Deliverables are Markdown workspaces whose size and directory structure are
  determined by the learner's actual scope. Do not force a fixed folder tree.
- The plan must include professional software practice where relevant:
  maintainability, testing, debugging, security, documentation, source control,
  architecture, and deployment/operations only when they serve the target role.
- SOLID, clean-code, and architecture principles are taught progressively and
  applied to real code. Do not introduce them as premature beginner checklists
  or use them to justify unnecessary abstraction.
- The attached `docs-guard.skill` is applied as a final accuracy and substance
  guard pass for generated technical Markdown. It does not decide the learning
  information architecture by itself.
- The core package must conform to the current Agent Skills open standard so it
  can be used by any AI product that supports that standard. The core contains
  no OpenAI-, Codex-, or Claude-specific instructions.
- Platform-specific metadata is optional and must live outside the portable
  core, in an adapter added only for a platform that requires it.

## Scope and Boundaries

### In scope

- Career-oriented or task-oriented learning paths for technical subjects.
- Small, medium, and large technology ecosystems.
- Current research on technology versions, official documentation, courses, and
  role-relevant skills.
- Skills audits, dependency maps, course selection, hands-on practice,
  portfolio evidence, checkpoints, and plan revisions.
- Review of an existing learning plan, including clear findings and a revised
  plan when requested.

### Out of scope

- Generic project architecture or technology-adoption consulting when the user
  has no learning objective. A technology-fit comparison may occur only when it
  materially affects the learner's chosen path.
- Automatically implementing the learner's final project, installing software,
  enrolling in courses, buying services, or applying for jobs.
- Rewriting entire upstream manuals or courses into long AI-generated lessons.
  The plan links to authoritative sources and provides targeted explanations,
  exercises, and mentoring on demand.
- Claiming employment, salary, certification, or production readiness without
  evidence.

## Target Skill Structure

Create an Agent Skills-standard folder named:

```text
technology-learning-career-path/
├── SKILL.md
├── references/
│   ├── discovery-and-critique.md
│   ├── research-and-version-policy.md
│   ├── learning-path-design.md
│   ├── technical-quality-framework.md
│   ├── course-selection.md
│   ├── workspace-output-schema.md
│   ├── existing-plan-review.md
│   └── docs-guard-adaptation.md
├── tests/
│   └── scenarios.md
└── adapters/                       # optional; omit when none is needed
    └── <platform-name>/             # e.g. openai-codex/
        └── <platform-metadata-file>
```

`SKILL.md`, `references/`, and `tests/` are the portable core. No adapter may
change the core learning policy or become required for the package to work.

Do not add scripts, assets, a README, or placeholders at initial creation.
The skill's work is judgment and research-heavy; no repeated deterministic
operation currently justifies a script. Add one later only if real use shows a
repeated, verifiable transformation that benefits from automation.

## Portability and Interoperability

### Required compatibility target

Package the skill according to the current Agent Skills open standard. This is
the portability contract for AI products that adopt the standard, including the
skill format centered on `SKILL.md` and its bundled references.

Do not promise automatic support for an AI that has no Agent Skills support.
For such a product, the same core may still be supplied manually as
instructions, but that is a manual integration rather than standards-based
installation.

### Core constraints

- Keep all behavioral requirements in platform-neutral Markdown.
- Do not refer to Codex-only tools, Claude-only commands, a vendor UI, or a
  private directory location in `SKILL.md` or the core references.
- Express capability needs generically: current web research, file reading and
  writing, and Markdown output. A host platform maps those needs to its own
  tools.
- Do not assume one model's context window, planning mode, file system, or
  installation path.
- Keep test scenarios as human-readable behavioral cases so any supporting AI
  platform can run them.

### Optional adapters

Only add an adapter when a platform needs metadata or a wrapper to discover the
same core skill. An adapter may add display metadata, installation hints, or
tool mapping. It must not duplicate or contradict the core instructions.

For example, `adapters/openai-codex/agents/openai.yaml` may be added only when
deploying to OpenAI/Codex. It is not included in the portable base package.

## `SKILL.md` Requirements

Keep the entrypoint concise. It must contain only shared instructions and
routing; detailed procedures belong in the relevant reference files.

### Frontmatter

- `name`: `technology-learning-career-path`
- A discriminating description that triggers for creating or auditing
  personalized technology learning/career paths.
- Use only frontmatter fields supported by the Agent Skills standard. Do not
  add platform-specific invocation policy to the core.

### Shared operating rules

1. Start by determining the mode: create from zero or review an existing plan.
2. Treat learner claims as hypotheses to validate, not facts to repeat.
3. Explain material critiques clearly: learner choice, assumption/risk,
   evidence, alternative, recommendation, and decision needed.
4. Ask at most one concise question per turn. Do not ask a question when a
   reasonable assumption can be declared and will not materially alter the
   path.
5. Before finalizing, require sufficient clarity on target capability, current
   baseline, realistic time capacity, constraints, and proof of competence.
6. Research current official/primary sources before making time-sensitive or
   technical claims. Cite direct source pages in generated Markdown.
7. Separate sourced facts from analysis. Mark assumptions and evidence gaps.
8. Scale the output to the actual learning goal, dependency graph, and learner
   profile. Never equate a technology name with a fixed curriculum size.
9. Produce no code, installations, purchases, applications, or external
   changes unless the user later explicitly requests them.
10. Run the DocsGuard adaptation before delivery.

### Routing

- **Create from zero**: read `discovery-and-critique.md`, then
  `research-and-version-policy.md`, `learning-path-design.md`,
  `technical-quality-framework.md`, `course-selection.md`,
  `workspace-output-schema.md`, and `docs-guard-adaptation.md` as applicable.
- **Review existing plan**: read `existing-plan-review.md`, then the relevant
  research, technical-quality, output-schema, and DocsGuard references.
- Do not load all references unless the task calls for them. For example, a
  short Python refresher may not need the ecosystem-scale guidance needed for
  an Odoo developer career path.

## Reference Specifications

### `discovery-and-critique.md`

Define the staged learner interview.

1. **Outcome**: what the learner needs to do in the real world; target role,
   task, industry, or portfolio result.
2. **Context**: deadline, weekly capacity, location/language needs, budget,
   available device/environment, current work/study constraints.
3. **Baseline**: prior knowledge, existing projects, transferable skills,
   evidence, comfort level, and unknowns.
4. **Choice critique**: target technology, specialization, version, scope,
   course preferences, and proposed deadline.
5. **Decision checkpoint**: summarize assumptions, unresolved decisions, and
   the recommended scope before research-intensive plan creation.

The reference must include a decision-impact rule: only ask a question if the
answer would change scope, sequencing, time estimate, version/tool choice,
course choice, role recommendation, or required evidence.

It must also include examples of useful challenges:

- Existing Flutter experience does not automatically prove Python or backend
  competence; identify what transfers and test what does not.
- "Learn all Odoo modules" must be narrowed by role, business domain, and
  target tasks.
- "Finish in three months" requires weekly hours, current baseline, and a
  realistic capability target before accepting the schedule.

### `research-and-version-policy.md`

Define a source hierarchy:

1. Official documentation, release notes, support/version policy, official
   repositories, specifications, and standards.
2. Maintainer or vendor technical material.
3. Primary research or authoritative role/occupation data when career evidence
   is needed.
4. Credible independent sources only for gaps such as production trade-offs or
   course experience.

Require direct links, access/review date, and a clear status label for each
time-sensitive claim. Do not cite search-result pages.

For a version choice, record:

- Candidate versions and lifecycle/status.
- Compatibility with the learner's target ecosystem, employer/project, and
  hosting/deployment environment.
- The selected version and rationale.
- What changes if a different version is required.

### `learning-path-design.md`

Define capability-first backward design:

```text
Target capability → real work tasks → competencies → prerequisite graph
→ learner gap map → resources/practice → observable evidence
```

Require the plan to classify every competency:

- Already demonstrated / reuse.
- Verify or refresh.
- Required now.
- Required later.
- Useful but optional.
- Out of scope.

For each learning unit, require:

- Why it exists for this learner and target.
- Prerequisites.
- Specific concepts and explicit exclusions.
- Current sources and selected course segments.
- Hands-on task.
- Retrieval/review activity.
- "Ready to continue" evidence.
- Estimated effort range and dependencies.

Use the work cycle:

```text
Understand → build → explain → self-test → revisit later → apply in a larger task
```

Include weekly sprint design with a realistic outcome, learning activities,
build task, verification, review schedule, and decision gate. Do not create
fake precision in hours or calendar dates when learner inputs are insufficient.

### `technical-quality-framework.md`

Require technology-appropriate professional practice, not a generic checklist.

For every technical learning track, decide whether each category is required,
introduced later, optional, or irrelevant:

- Code readability, naming, formatting, and project conventions.
- Type safety and interfaces where the ecosystem supports them.
- Validation, error handling, and failure modes.
- Unit/integration tests and verification tools.
- Debugging, logging, and observability.
- Dependency, environment, package, and secret management.
- Security fundamentals and relevant threat boundaries.
- Performance basics based on the workload.
- Documentation and code-review readiness.
- Architecture, modularity, SOLID principles, and patterns only where an
  actual design problem warrants them.
- CI/CD, deployment, operations, and monitoring only when the target role or
  final project needs them.

Require the skill to follow the target framework's own conventions ahead of
generic rules. Example: an Odoo developer path must distinguish general Python
practice from Odoo-specific module, ORM, security, and testing conventions.

### `course-selection.md`

Treat courses as curriculum components, not a link dump.

For each selected course or course segment record:

- What it teaches and its current status/version when available.
- Why it closes a specific learner gap.
- Prerequisites and position in the sequence.
- Expected time/effort and cost/access constraints.
- Required, recommended, or optional status.
- Practical outcome and proof of completion.
- Risks: outdated material, duplication, overly broad scope, missing practice,
  or mismatch with the target technology version.

Prefer a small number of complementary resources. Link upstream documentation
instead of paraphrasing it.

### `workspace-output-schema.md`

Define a dynamic Markdown workspace, not a mandatory document count.

Minimum useful output for any non-trivial plan:

```text
README.md
00-learning-contract.md
01-skills-audit-and-gap-map.md
02-master-roadmap.md
resources.md
```

Add files/folders only when justified by the learner's scope:

```text
tracks/<track-name>/
projects/
progress/
career/
```

`README.md` must act as a truthful navigation map. Every generated document
must make clear whether a statement is a verified fact, recommendation,
assumption, or learner decision.

For broad ecosystems, use a competency/dependency map and separate track files
only when they contain substantial independent work. For narrow goals, keep the
workspace compact.

### `existing-plan-review.md`

Define a review workflow that first audits; it does not silently rewrite.

Review the plan against:

- Target capability and role clarity.
- Learner baseline and prerequisite coverage.
- Current technical/version accuracy.
- Dependency order and realistic time capacity.
- Course quality, duplication, and source credibility.
- Technical-quality practice.
- Real work, portfolio, and verification evidence.
- Missing risks, trade-offs, and decision gates.
- Documentation accuracy, navigation, and stale claims.

Report findings in priority order:

```md
## Finding: <short title>
Severity: must fix | should fix | worth noting
Plan section: <file and heading>
Problem: <specific issue>
Why it matters: <real consequence>
Evidence: <verified source or stated limitation>
Recommendation: <concrete correction>
Decision needed: <only if the learner must choose>
```

Only produce a revised plan after the user asks for it or approves the review
direction.

### `docs-guard-adaptation.md`

Adapt the attached DocsGuard skill to learning-plan artifacts. Preserve its
core principle: every technical documentation claim is checkable.

Before delivery, verify:

- Technology versions, support status, compatibility, commands, paths,
  configuration keys, APIs, and course prerequisites against the source of
  truth available in the current session.
- Code samples have valid imports/APIs, explicit prerequisites, clean-machine
  assumptions, correct language/environment labels, no secrets or local paths,
  and a realistic failure path where relevant.
- Version-dependent claims name the relevant version; no unverified
  performance, scale, or "production-ready" claims remain.
- The plan links to upstream docs rather than copying changing manuals.
- Headings, table of contents/navigation, and internal links are accurate; no
  TODO stubs or filler sections remain.

When a claim cannot be verified, state the limitation and ask or qualify; do
not fabricate certainty.

## Implementation Sequence

### Phase 1 — Terra High: design review and final specification

1. Read this plan, the original `Technology research and review analyst` file,
   and the attached `docs-guard.skill` instructions.
2. Challenge any contradictory, over-broad, or unnecessary rule in this plan.
   Preserve the decisions above unless a concrete conflict or stronger reason
   is identified.
3. Produce the final concise skill specification, including the exact
   frontmatter, routing language, and reference content outline.
4. Check that the plan stays a learning/career skill rather than drifting back
   into a generic project-planning or technology-adoption skill.
5. Hand off an implementation checklist to Luna Medium. Do not create the
   skill unless the user explicitly approves this specification.

### Phase 2 — Luna Medium: create the skill after approval

1. Create the portable Agent Skills-standard folder
   `technology-learning-career-path` with `SKILL.md`, `references/`, and
   `tests/`. Do not create platform metadata in the core package.
2. Write concise `SKILL.md` routing, the eight focused reference files, and
   `tests/scenarios.md` using the behavioral test cases below.
3. Validate the package against the current Agent Skills standard and test the
   `SKILL.md` frontmatter against a standards-compatible validator when one is
   available.
4. Do not add generic manuals, copied upstream documentation, empty templates,
   or unneeded scripts/assets.
5. Run a DocsGuard-style accuracy check over the skill's own technical claims,
   file links, routing references, examples, and sample paths.
6. Test the package in each available Agent Skills-compatible AI platform before
   claiming compatibility. If a target platform is unavailable, report it as
   untested rather than assumed compatible.
7. Add a platform adapter only after the core tests pass and only for a
   requested deployment target.
8. Report all validation results and any unresolved ambiguity. Do not install,
   publish, or overwrite an existing skill unless separately authorized.

## Acceptance Criteria

The implementation is complete only when all of the following are true:

- The skill routes reliably between create-from-zero and existing-plan-review
  modes.
- It discovers target capability before treating a technology name as scope.
- It critically tests material learner assumptions while remaining concise and
  asking no more than one focused question at a time.
- It distinguishes demonstrated skills, refresh needs, prerequisites, required
  skills, optional skills, and exclusions.
- It selects compatible current technology versions based on evidence, rather
  than automatically selecting the newest version.
- It covers professional technical practice proportionately and avoids
  premature architecture dogma.
- It treats courses as evaluated curriculum components with expected evidence.
- It creates compact Markdown output for narrow goals and a justified
  multi-file workspace for broad ecosystems.
- It produces realistic work evidence, checkpoints, and plan-adjustment rules.
- It verifies technical Markdown claims and code samples according to the
  DocsGuard adaptation.
- The portable core conforms to the current Agent Skills standard without any
  OpenAI/Codex-specific file being required.
- The portable behavioral test suite is present and usable by any supporting
  Agent Skills platform.
- Compatibility is claimed only for platforms in which the package was tested;
  other standards-compatible platforms are described as expected to work, not
  guaranteed.

## Behavioral Test Cases

Use these tests after implementation. They test decisions, not exact wording.

1. **Python beginner with an unrealistic goal**
   - Request: "Teach me all of Python for backend work in two weeks."
   - Expected: challenge feasibility; ask weekly hours and target capability;
     recommend a narrower milestone before generating a broad roadmap.

2. **Transferable skills are not blindly trusted**
   - Request: "I know Flutter and Git. Make me an Odoo developer plan; I do
     not know Linux."
   - Expected: reuse relevant programming/Git capability only after evidence;
     add Linux, Python, SQL/PostgreSQL, Odoo functional workflows, and
     Odoo-specific development based on a dependency map.

3. **Narrow Node.js goal**
   - Request: "I need Node.js only to build one secure REST API for my
     portfolio."
   - Expected: compact path; focus on the necessary JavaScript/TypeScript,
     HTTP, validation, authentication, testing, error handling, and deployment
     evidence. Do not create an Odoo-scale workspace.

4. **Broad Odoo career goal**
   - Request: "I want an Odoo developer career."
   - Expected: clarify target role/industry/time; research compatible current
     Odoo/Python environment; separate functional ERP understanding from
     technical development; choose relevant modules rather than every module;
     create portfolio and readiness evidence.

5. **Existing weak plan**
   - Request: provide a plan containing course links, no skill audit, outdated
     version claims, and no projects or verification.
   - Expected: audit first; identify each critical gap with evidence; ask the
     necessary learner question; do not silently replace the plan.

## Handoff Instruction

Use Terra High for Phase 1 because the work requires resolving scope,
instruction conflicts, and reference architecture. Use Luna Medium for Phase 2
only after the specification is approved; its job is faithful implementation,
validation, and reporting—not redesigning settled learning-policy decisions.
