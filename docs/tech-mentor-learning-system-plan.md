# Tech Mentor Learning-System Redesign Plan

## Purpose

Evolve `tech-mentor` from a learning-path recommender into a learning-system builder. The skill will discover the learner's demonstrated capability and real-work goal, then create a proportionate Markdown workspace that guides learning, practice, verification, and adaptation with AI support.

This is a design-and-implementation plan. It does not change the published skill yet.

## Product decisions already agreed

1. Discovery must be evidence-based. Familiarity with a topic is not treated as competence without a project, explanation, code sample, or small diagnostic.
2. Questions are adaptive: ask every question whose answer can materially improve scope, sequence, depth, pace, resources, or evidence; stop when further answers would not change the plan.
3. The path begins with the learner's intended real work, then derives competencies and prerequisites.
4. Output size scales with scope: a focused Python task receives a compact plan; a broad platform such as Odoo receives a staged roadmap with tracks and projects.
5. The result is a usable learning workspace, not only recommendations or links.
6. Learning files include targeted content, practice, real-work tasks, self-checks, readiness evidence, and AI prompts.
7. Checkpoints update the plan using learner evidence: continue, revisit a prerequisite, adjust pace/scope, or advance.
8. The published skill, its references, human guide, README, and manifest description will remain consistent.

## Boundaries

- The skill designs and writes the learner's workspace; it does not implement the learner's final software project unless separately asked.
- The initial workspace should not attempt to copy a full technology manual. Broad paths disclose detailed lesson files by phase, keeping the first output navigable and maintainable.
- Existing-plan review remains audit-first. It must not rewrite a learner's plan until the learner requests or approves revision.

## Design phase

Each workstream is designed, reviewed with the user, and marked **approved** before it becomes an implementation phase.

| Workstream | Design deliverable | Completion criterion | Status |
| --- | --- | --- | --- |
| 1. Adaptive discovery | Question map, stop rules, diagnostic policy | Every required input has a decision it changes; no low-impact questions remain | Approved |
| 2. Scope scaling | Compact, standard, and large workspace rules | A request can be classified consistently, including Python and Odoo examples | Pending |
| 3. Workspace architecture | File/folder schemas and navigation rules | Each workspace size has the smallest set of files that enables learning | Pending |
| 4. Learning-unit design | Required sections for lesson and project files | A unit tells the learner what to learn, do, prove, and ask AI | Pending |
| 5. Adaptation loop | Checkpoint inputs, decisions, and update rules | Evidence leads to a specific next action | Pending |
| 6. Existing-plan review | Relationship between review findings and workspace creation | Audit and approved revision remain distinct | Pending |
| 7. Publication design | Exact skill/reference/guide/README/manifest changes | Every behavior has one authoritative source and public docs match it | Approved |

### 1. Adaptive discovery — design questions

Define a staged interview that can branch by subject and learner goal.

### Approved interview model

Use **adaptive question sets**, not a one-question-per-turn limit. Ask a batch of three to five related, high-impact questions, then ask follow-ups only when an answer is missing, uncertain, or changes the plan. This gathers enough context without turning discovery into an exhaustive questionnaire.

Every learner begins with these areas:

| Area | Questions establish | Planning decision affected |
| --- | --- | --- |
| Real outcome | Intended role, real tasks, deliverable, domain | Scope and competency graph |
| Current ability | What the learner has built alone and can use or explain | Reuse, refresh, and prerequisite work |
| Evidence | Project, code sample, explanation, or diagnostic result | Confidence in each claimed competency |
| Time and context | Weekly capacity, deadline, environment, budget, and constraints | Pace, resources, and plan size |
| Target proof | Portfolio project, work task, interview, certification, or personal outcome | Projects and readiness checkpoints |

After the universal set, ask only subject-specific questions. For example, Python discovery can cover functions, files, errors, packages, APIs, SQL, Git, and testing; Odoo discovery can additionally cover PostgreSQL, Linux, HTTP, business workflows, and the desired Odoo role.

### Approved self-assessment and diagnostic policy

The default is a **guided self-assessment**, which must be enough to produce a useful plan immediately. Do not require a repository, code sample, quiz, or diagnostic before planning.

For each capability that materially affects the plan, collect:

1. the learner's confidence level: `new`, `can follow examples`, `can build alone`, or `can explain and debug`;
2. a short description of where and how they used it;
3. the learner's broader programming background, transferable languages/tools, and previous projects; and
4. the learner's own uncertainty or desired refresh level.

Classify the result as `demonstrated`, `verify or refresh`, `required now`, `required later`, `optional`, or `out of scope`. A self-report can justify a provisional placement, but it must be labelled as learner-reported rather than demonstrated evidence.

Use a **micro-diagnostic** only after planning, or before a consequential branch, when a short task would resolve uncertainty more efficiently than reviewing material. It is optional, matched to the learner's target work, and should lead to one concrete adjustment: reuse, refresh, begin a prerequisite, or advance. It is never a gate to receiving a plan.

Research current, topic-specific facts after the learner identifies the technology and target work. Use direct official documentation, release notes, support policies, repositories, specifications, or standards; record source, review date, and status. Select a compatible maintained version rather than defaulting to the newest release.

### Approved required inputs and stop rules

Before creating any plan, establish the real outcome, learner baseline, time capacity, constraints, and target proof. A standard or large roadmap additionally requires the target role or work domain and the intended technology scope. If any required input is unavailable, state the assumption and produce a provisional plan with a checkpoint that validates it.

Stop discovery when every unanswered question would leave scope, sequence, depth, pace, resources, and evidence unchanged. Continue only when an answer changes one of those decisions or resolves a material uncertainty. The skill must not collect background details solely because they are interesting.

- **Outcome:** target role, real tasks, domain, deadline, and proof required.
- **Baseline:** demonstrated skills, prior projects, transferable skills, uncertain areas, and diagnostic evidence.
- **Context:** realistic weekly capacity, budget, device/environment, language, and work/study constraints.
- **Learning fit:** format preferences and resource constraints, only where they affect practice or completion.
- **Technology fit:** target stack, compatible versions, prerequisite technologies, and scope risks.

Design decisions still to make:

1. Which questions are universal versus topic-specific?
2. What is the smallest valid evidence signal for a claimed skill?
3. When should the skill use a micro-diagnostic instead of another question?
4. What information is mandatory before creating a compact, standard, or large plan?

### 2. Scope scaling — design questions

Classify the request by dependency breadth, real-work outcomes, prerequisites, expected duration, and proof complexity.

| Scale | Intended use | Example |
| --- | --- | --- |
| Compact | One focused outcome with limited prerequisites | Python file automation |
| Standard | Connected competencies and one substantial proof project | Python backend foundations |
| Large | Broad platform, multiple tracks, or role-specific work | Odoo ERP development |

Decide the threshold between scales and the minimum deliverables for each.

### Approved scope-scaling model

Choose scale from the learner's target work, dependency graph, demonstrated baseline, required evidence, and the number of independent competency areas. Never infer scale from a technology name alone: Python can be a compact automation task or a large backend path; Odoo can be a narrow functional workflow or a broad developer roadmap.

| Scale | Choose when | Initial workspace | Learning detail | Example |
| --- | --- | --- | --- | --- |
| Compact | One concrete outcome; limited prerequisites; one proof task | Navigation, focused plan, and proof-project file | All units can be detailed initially | Automate a recurring file task with Python |
| Standard | One coherent capability; several connected competencies; one substantial project | Navigation, learning contract, gap map, roadmap, resources, and project file | Detail the first unit and roadmap the remainder | Build and test a small Python API |
| Large | Multiple independent competency areas, business domains, target roles, or substantial prerequisites | Navigation, learning contract, gap map, master roadmap, resources, tracks, projects, and progress records | Detail only the current phase; disclose later units at checkpoints | Become an Odoo developer for a defined business domain |

For a large request, first narrow the target role, business domain, version/environment, and real workflows. Treat requests such as “learn all Odoo” as a scope-discovery request, not as permission to generate an encyclopedic course.

### Scale adjustment rules

- **Escalate** a plan when discovery reveals an additional independent competency area, proof project, work domain, or prerequisite chain.
- **Reduce** a plan when the learner's required outcome is narrower than the named technology or the learner already demonstrates major dependencies.
- **Reclassify** at checkpoints when evidence shows the original scope or baseline was wrong; preserve completed evidence and adjust only unfinished work.
- State the selected scale, the evidence supporting it, and what condition would change it.

### 3. Workspace architecture — design questions

Define the files created at each scale and what each owns. Candidate large-workspace structure:

```text
README.md
00-learning-contract.md
01-skills-audit-and-gap-map.md
02-master-roadmap.md
resources.md
tracks/
projects/
progress/
```

Decide when detailed lesson files are created initially versus generated at the start of a later phase.

### Approved workspace architecture

All workspaces are small enough to use, progressive, and navigable. Create a file only when it has substantive content. Every `README.md` identifies the learner outcome, selected scale, current phase, next action, and links only to existing files. Units and projects link back to the roadmap. At a checkpoint, update the roadmap before creating the next needed file.

#### Compact workspace

```text
README.md
learning-plan.md
proof-project.md
```

- `README.md` owns the learner profile, goal, pace, and start point.
- `learning-plan.md` owns focused units, practice, AI prompts, self-checks, and readiness evidence.
- `proof-project.md` owns a small real-work task, acceptance criteria, and completion proof.

Embed resources in the relevant unit unless they are substantial enough to deserve their own file.

#### Standard workspace

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

The roadmap owns sequence and dependencies. Initially, create detailed content only for the current unit; subsequent unit files are created after the learner reaches the appropriate checkpoint.

#### Large workspace

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

Tracks represent independent capability areas. Projects prove real work. Progress records checkpoint evidence and adjustments. Do not create empty folders or future lesson files; fully detail only the active track and first project, while the master roadmap describes later work.

### 4. Learning-unit design — design questions

Define one reusable schema for a lesson or project unit:

1. Real-work purpose
2. Prerequisites and exclusions
3. Concepts and selected sources
4. Practice and retrieval activity
5. Realistic work task
6. AI interaction prompts
7. Self-check and review timing
8. Ready-to-continue evidence
9. Effort range, dependencies, and adjustment rule

Decide how much explanatory teaching content belongs in a unit versus authoritative source links and AI-guided explanation.

### Approved learning-unit design

A learning unit is the smallest complete step toward a real task. It teaches only what the learner needs now, pairs learning with practice and feedback, and has an observable readiness condition. It uses current official documentation or selected learning material for topic-specific facts; it does not reproduce a full upstream manual.

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

The sections have these responsibilities:

- **Why this matters** connects the capability to the learner's intended work.
- **Prerequisites** and **Scope and exclusions** prevent misplaced or premature study.
- **Learn** gives only the concepts and sources necessary for the task.
- **Practice** builds toward a **Real-work task** that resembles the target environment.
- **AI support** supplies prompts for explanation at the learner's level, hints without solutions, review against requirements, additional targeted practice, and scenario/interview simulation.
- **Self-check** asks the learner to explain decisions and handle a variation.
- **Ready to continue when** defines the required artifact, explanation, test result, or other evidence.
- **Review later** schedules retrieval and retention work; **If blocked or weak** states the adjustment route.

### 5. Adaptation loop — design questions

At a checkpoint, the learner supplies evidence such as a completed task, repository link, explanation, quiz result, or stated blocker. The skill chooses one next action:

- continue;
- revisit a prerequisite;
- change pace or reduce scope;
- increase difficulty;
- replace a resource;
- add a missing competency.

Decide the checkpoint cadence and the minimum evidence needed for each decision.

### Approved adaptation loop

Checkpoints are evidence-triggered, not calendar-triggered. They occur after a completed unit, real-work task, project milestone, reported blocker, or discovery that the learner's baseline was misclassified. The learner provides the relevant artifact, explanation, test result, outcome, or a clear blocker description.

The skill selects one explicit decision:

1. **Continue** when required evidence is sufficient.
2. **Refresh** when a prerequisite needs focused review.
3. **Simplify** when the current task or scope is too large.
4. **Extend** when the learner is ready for greater depth.
5. **Re-plan** when pace, resources, sequence, or plan scale must change.
6. **Investigate** with an optional micro-diagnostic when the blocker is unclear.

Each decision states the evidence reviewed, assessment, decision, next action, and next evidence required. Preserve completed work and revise only unfinished work. If technology or version assumptions change, recheck current official sources before revising affected work.

For standard and large workspaces, create or update this record:

```md
# Checkpoint: <name>

## Evidence reviewed
## Assessment
## Decision
## Roadmap changes
## Next action
## Next evidence required
```

Compact workspaces keep checkpoint information inside `learning-plan.md`. Standard workspaces create a progress record after each major unit or project milestone. Large workspaces create one at every track transition, project milestone, or material scope change.

### 6. Existing-plan review — design questions

Preserve the current audit format. Define whether an approved revision:

- edits the learner's existing plan;
- produces a separate reviewed version; or
- turns the approved plan into the new learning workspace.

### Approved existing-plan review flow

Keep review audit-first. The skill reports findings about target clarity, prerequisites, currency, sequence, capacity, resources, practice, proof, risks, and documentation before proposing a replacement.

After the learner approves revisions, create a **new learning workspace** derived from the accepted findings. Preserve the original plan. The new workspace records the source plan, accepted findings, assumptions and decisions, revised roadmap, and initial learning unit/project.

- A learner who requests review only receives findings only.
- Apply only the recommendations the learner approves; record rejected or deferred recommendations.
- If the learner explicitly requests an in-place edit, confirm the target file and approved changes before editing it.
- Scale the resulting workspace using the same compact, standard, and large rules as a new plan.

### 7. Publication design — design questions

Map each approved behavior to a single source of truth:

| Concern | Planned authoritative location |
| --- | --- |
| Mode routing and shared constraints | `skills/general/tech-mentor/SKILL.md` |
| Discovery policy | `references/discovery-and-critique.md` or a focused successor |
| Scaling and workspace structure | `references/learning-path-design.md` and `references/workspace-output-schema.md` |
| Learning-unit and adaptation specifications | New focused references if the design warrants them |
| Review behavior | `references/existing-plan-review.md` |
| Human explanation | `guides/general/tech-mentor/README.md` |
| Repository catalog | Root `README.md` and `skills.sh.json` |

## Implementation phases

Implementation begins only after the corresponding design workstream is approved.

1. Update discovery and diagnostic instructions.
2. Add scope-scaling and workspace-generation instructions.
3. Add learning-unit and adaptation-loop instructions.
4. Align existing-plan review behavior.
5. Update the guide, root README, and manifest description.
6. Validate the final skill with representative scenarios:
   - compact Python automation goal;
   - standard Python backend goal;
   - large Odoo developer goal;
   - review of an existing learning plan.

## Approval log

| Decision or workstream | Status | Notes |
| --- | --- | --- |
| Product direction | Approved | Captured from the planning discussion |
| Adaptive discovery | Approved | Adaptive question sets, guided self-assessment, optional diagnostics, required inputs, and stop rules defined |
| Scope scaling | Approved | Capability-first classification, initial workspace, detail timing, and adjustment rules defined |
| Workspace architecture | Approved | Compact, standard, and large schemas plus progressive creation and navigation rules defined |
| Learning-unit design | Approved | Reusable task-first unit schema, source policy, AI support, and readiness evidence defined |
| Adaptation loop | Approved | Evidence-triggered decisions, progress-record schema, and scale-specific cadence defined |
| Existing-plan review | Approved | Audit-first findings, approval gate, derived workspace, and explicit in-place-edit exception defined |
| Publication design | Approved | Behavior ownership, publication surfaces, and validation scenarios defined |
