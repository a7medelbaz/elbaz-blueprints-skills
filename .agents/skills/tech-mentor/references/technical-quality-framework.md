# Technical quality framework

For each track, mark every category `required`, `introduced later`, `optional`, or `irrelevant`, with a reason tied to the target role:

- readability, naming, formatting, and ecosystem conventions;
- type safety and interfaces where supported;
- validation, error handling, and failure modes;
- unit/integration tests and verification tools;
- debugging, logging, and observability;
- dependency, environment, package, and secret management;
- security fundamentals and threat boundaries;
- workload-appropriate performance basics;
- documentation and code-review readiness;
- architecture, modularity, SOLID, and patterns only when a real design problem warrants them;
- CI/CD, deployment, operations, and monitoring only when the role or project needs them.

Follow framework-specific conventions before generic advice. For example, an Odoo path distinguishes Python practice from Odoo modules, ORM, access security, and testing. Teach quality progressively through real work; do not turn it into a beginner checklist or abstraction exercise.
