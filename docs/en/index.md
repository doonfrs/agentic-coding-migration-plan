# Agentic Coding Migration Roadmap

> A structured 3-month plan to safely transition a Laravel team from non-standardized development to AI-assisted, agent-driven coding — without breaking what's already in production.

---

## Phase 1 — Stabilize & Standardize  ·  Month 1

**Goal:** Deliver the current project on time while establishing the coding standards and Git discipline that make AI assistance safe and effective.

> AI amplifies what's already there. If the codebase has no standards, the agent will confidently produce more of the same mess. Standards come first.


- [1.1 Codebase & Architecture Review](./phase1/01-codebase-architecture.md)
- [1.2 Laravel Standards](./phase1/02-laravel-standards.md)
- [1.3 Tooling Selection](./phase1/03-tooling-selection.md)
- [1.4 Git Workflow](./phase1/04-git-workflow.md)
- [1.5 Deployment](./phase1/05-deployment.md)

**Outcome:** Stable project + consistent codebase conventions + disciplined Git workflow — a clean foundation for AI

---

## Phase 2 — Safety Nets & Supervised AI  ·  Month 2

**Goal:** Build the automated safety nets that allow the team to use AI assistance without fear of regression, and introduce AI as a supervised junior collaborator.

- [2.1 Testing](./phase2/01-testing.md)
- [2.2 CI Pipeline](./phase2/02-ci-pipeline.md)
- [2.3 Environment](./phase2/03-environment.md)
- [2.4 Supervised AI Introduction](./phase2/04-supervised-ai.md)

**Outcome:** Automated safety net in place + team comfortable using AI under supervision

---

## Phase 3 — Go Agentic  ·  Month 3

**Goal:** Establish a structured Agentic Coding methodology the team can operate independently, with defined agent roles, KPIs, and internal policies.

- [3.1 Agentic Methodology](./phase3/01-agentic-methodology.md)
- [3.2 CI/CD Maturity](./phase3/02-cicd-maturity.md)
- [3.3 Team Enablement](./phase3/03-team-enablement.md)
- [3.4 Governance](./phase3/04-governance.md)

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
