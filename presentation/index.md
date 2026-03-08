# Agentic Coding Migration Roadmap

> A structured 3-month plan to safely transition a Laravel team from non-standardized development to AI-assisted, agent-driven coding — without breaking what's already in production.

---

## Phase 1 — Stabilize & Standardize  ·  Month 1

**Goal:** Deliver the current project on time while establishing the coding standards and Git discipline that make AI assistance safe and effective.

> AI amplifies what's already there. If the codebase has no standards, the agent will confidently produce more of the same mess. Standards come first.

- [Codebase & Architecture Review](./phase1/codebase-architecture.md)
- [Laravel Standards](./phase1/laravel-standards.md)
- [Tooling Selection](./phase1/tooling-selection.md)
- [Git Workflow](./phase1/git-workflow.md)
- [Deployment](./phase1/deployment.md)

**Outcome:** Stable project + consistent codebase conventions + disciplined Git workflow — a clean foundation for AI

---

## Phase 2 — Safety Nets & Supervised AI  ·  Month 2

**Goal:** Build the automated safety nets that allow the team to use AI assistance without fear of regression, and introduce AI as a supervised junior collaborator.

- [Testing](./phase2/testing.md)
- [CI Pipeline](./phase2/ci-pipeline.md)
- [Environment](./phase2/environment.md)
- [Supervised AI Introduction](./phase2/supervised-ai.md)

**Outcome:** Automated safety net in place + team comfortable using AI under supervision

---

## Phase 3 — Go Agentic  ·  Month 3

**Goal:** Establish a structured Agentic Coding methodology the team can operate independently, with defined agent roles, KPIs, and internal policies.

- [Agentic Methodology](./phase3/agentic-methodology.md)
- [CI/CD Maturity](./phase3/cicd-maturity.md)
- [Team Enablement](./phase3/team-enablement.md)
- [Governance](./phase3/governance.md)

**Outcome:** Fully operational agentic team — independent, policy-driven, measurable

---

## Working Method

- 2 weekly supervision meetings (review progress, unblock, hands-on coaching)
- Quality and stability before speed — no shortcuts
- Mix of theory sessions and real task practice
- Direct intervention when blockers arise
- Each phase ends with a team retrospective before moving forward

---

## Why This Order

| Risk | Mitigation |
|------|-----------|
| AI reinforces bad code patterns | Standards enforced in Month 1 before AI is introduced |
| AI-generated bugs reach production | Tests + CI gate introduced in Month 2 before expanding AI use |
| Team adopts AI without oversight | Supervised phase before autonomous agent workflows |
| No way to measure improvement | KPIs and baselines captured before the agentic phase begins |
