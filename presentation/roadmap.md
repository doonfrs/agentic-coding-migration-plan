# Agentic Coding Migration Roadmap

> A structured 3-month plan to safely transition a Laravel team from non-standardized development to AI-assisted, agent-driven coding — without breaking what's already in production.

---

## Phase 1 — Stabilize & Standardize  ·  Month 1

**Goal:** Deliver the current project on time while establishing the coding standards and Git discipline that make AI assistance safe and effective.

> AI amplifies what's already there. If the codebase has no standards, the agent will confidently produce more of the same mess. Standards come first.

### Codebase & Architecture
- [ ] Review project architecture, folder structure, and development cycle
- [ ] Identify and document critical vs. low-risk areas of the codebase
- [ ] Map out current pain points (inconsistent naming, mixed responsibilities, no conventions)

### Laravel Standards
- [ ] Adopt PSR-12 coding style + Laravel naming conventions (models, controllers, routes)
- [ ] Configure Laravel Pint (code formatter) — enforce on every commit
- [ ] Define and document team conventions: RESTful routes, service/repository layers, form requests
- [ ] Establish `.editorconfig` and shared IDE settings

### Git Workflow
- [ ] Adopt a branching strategy (e.g., Git Flow or trunk-based with feature branches)
- [ ] Enforce meaningful commit messages (conventional commits)
- [ ] Introduce Pull Request reviews — no direct push to main

### Deployment
- [ ] Review and document the current deployment process
- [ ] Identify and fix the most fragile steps

**Outcome:** Stable project + consistent codebase conventions + disciplined Git workflow — a clean foundation for AI

---

## Phase 2 — Safety Nets & Supervised AI  ·  Month 2

**Goal:** Build the automated safety nets that allow the team to use AI assistance without fear of regression, and introduce AI as a supervised junior collaborator.

### Testing
- [ ] Introduce PHPUnit / Pest — set up the test environment
- [ ] Write Smoke tests for the most critical user flows
- [ ] Write Feature tests for core business logic (Happy Path first)
- [ ] Define a minimum coverage policy per PR

### CI Pipeline
- [ ] Setup Bitbucket Pipelines (lint → test → build)
- [ ] Block merges on failing tests or lint errors
- [ ] Add static analysis (Larastan / PHPStan level 3+)

### Environment
- [ ] Dockerize the local development environment
- [ ] Align dev/staging/production environments

### Supervised AI Introduction
- [ ] Identify AI-safe tasks: boilerplate generation, test writing, documentation, refactoring with test coverage
- [ ] Identify AI-restricted areas: auth logic, payment flows, migrations on production data
- [ ] Introduce Claude Code / Cursor — structured hands-on sessions
- [ ] Train team on prompt engineering basics for Laravel development
- [ ] Establish the review rule: every AI-generated line goes through code review

**Outcome:** Automated safety net in place + team comfortable using AI under supervision

---

## Phase 3 — Go Agentic  ·  Month 3

**Goal:** Establish a structured Agentic Coding methodology the team can operate independently, with defined agent roles, KPIs, and internal policies.

### Agentic Methodology
- [ ] Design the Agentic SDLC: how agents integrate into planning, coding, testing, and review
- [ ] Define agent roles and responsibilities:
  - **Code Assistant** — feature implementation, refactoring
  - **Test Agent** — test generation and coverage analysis
  - **Documentation Agent** — inline docs, API docs, changelogs
  - **Review Agent** — code review support, pattern enforcement
- [ ] Define human checkpoints: what always requires human sign-off

### CI/CD Maturity
- [ ] Expand pipeline: automated regression tests, deployment to staging
- [ ] Add automated rollback triggers
- [ ] Introduce environment-specific deployment approvals

### Team Enablement
- [ ] Train team on agent management and AI output evaluation
- [ ] Run internal workshops: real task → agent-assisted → reviewed
- [ ] Document and share internal prompt library for common Laravel tasks
- [ ] Define KPIs: PR cycle time, test coverage delta, defect escape rate, AI-assisted vs. manual task ratio

### Governance
- [ ] Write internal AI usage policy (what to delegate, what to own)
- [ ] Document best practices specific to the Laravel stack
- [ ] Establish a retrospective process to continuously improve agent workflows

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
