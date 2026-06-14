# 3.1 Agentic Methodology

> In Phase 2 a developer used AI to write code faster. In Phase 3 the developer stops writing most of the code and starts directing agents - reviewing outcomes, not keystrokes. This only works because Phases 1 and 2 built the standards and the safety nets that let you trust an agent's output without watching every line it types.

---

## Goals

- Define a repeatable agentic development loop the team can run on any ticket
- Assign clear agent roles so each step of the loop has an owner
- Define the human checkpoints where a person must approve before work proceeds
- Make the methodology measurable, so improvement can be tracked (see [3.3 Team Enablement](03-team-enablement.md))

---

## What Changes in Phase 3

The shift is in *where the human spends attention*. The mechanics built in earlier phases don't change - they get pointed at an autonomous agent instead of a supervised one.

| | Phase 2 (Supervised) | Phase 3 (Agentic) |
|--|----------------------|-------------------|
| Who writes the code | Developer, with AI help | The agent |
| Who runs the tests | Developer | The agent (then CI) |
| Tool | VS Code extension | Claude Code CLI agent |
| Human focus | Every line, as it's written | The plan and the final result |
| Human role | Author | Director & reviewer |

Everything that makes this safe already exists: branch protection from [1.4 Git Workflow](../phase1/04-git-workflow.md), the test suite from [2.1 Testing](../phase2/01-testing.md), the [CI Pipeline](../phase2/02-ci-pipeline.md) that gates merges, and the review instincts from [2.4 Supervised AI](../phase2/04-supervised-ai.md). Phase 3 wires them into a loop.

---

## Agentic SDLC Design

The agentic software development lifecycle is a loop with two human gates - one at the start (approve the plan) and one before merge (review the result). Everything in between, the agent does.

```
   ┌──────────────────────────────────────────────────────────┐
   │                                                          │
   │   1. Ticket / task                                       │
   │          │                                               │
   │          ▼                                               │
   │   2. Agent proposes a PLAN  ──▶  👤 Human approves plan   │  ◀── checkpoint 1
   │          │                                               │
   │          ▼                                               │
   │   3. Agent implements                                    │
   │          │                                               │
   │          ▼                                               │
   │   4. Agent runs tests locally  ──▶ fail? back to step 3  │
   │          │ pass                                          │
   │          ▼                                               │
   │   5. Agent pushes branch, opens PR                       │
   │          │                                               │
   │          ▼                                               │
   │   6. CI pipeline runs  ──▶ fail? agent reads errors,     │
   │          │ pass            fixes, pushes again           │
   │          ▼                                               │
   │   7. 👤 Human reviews & approves  ◀── checkpoint 2       │
   │          │                                               │
   │          ▼                                               │
   │   8. Merge to main  ──▶  deploy                          │
   │                                                          │
   └──────────────────────────────────────────────────────────┘
```

Each step maps to an asset built in an earlier phase:

| Step | Powered By |
|------|-----------|
| Plan proposal | Plan mode + `CLAUDE.md` ([1.5 Claude Code](../phase1/05-claude-code.md)) |
| Implementation | The agent + the standards from [1.2 Laravel Standards](../phase1/02-laravel-standards.md) |
| Local tests | Pest suite ([2.1 Testing](../phase2/01-testing.md)) |
| Push & PR | Git workflow + branch protection ([1.4](../phase1/04-git-workflow.md)) |
| CI gate | [2.2 CI Pipeline](../phase2/02-ci-pipeline.md) |
| Human review | Review rules from [2.4 Supervised AI](../phase2/04-supervised-ai.md) |

> **The agent never merges its own code.** Step 8 happens only after a human approves in step 7 and CI is green. The loop is autonomous in the middle and gated at both ends.

---

## Agent Roles

"Agentic" doesn't mean one agent does everything in one pass. The work splits into roles - implemented as Claude Code modes, subagents, or skills (see [1.5 Claude Code Deep Dive](../phase1/05-claude-code.md)). One ticket flows through all of them.

| Role | Responsibility | Input | Output |
|------|----------------|-------|--------|
| **Planner** | Break the ticket into a concrete approach | Ticket + codebase context | A reviewable plan |
| **Implementer** | Write the code to match the approved plan | Approved plan | Code changes |
| **Tester** | Write and run tests; verify behavior | Code changes | Passing test suite |
| **Reviewer (critic)** | Self-review for bugs, standards, security before the PR | The diff | Issues to fix, or "ready" |

The **Reviewer** role is what makes the loop trustworthy. Before a human ever sees the PR, a critic agent has already checked the diff against the standards and run `/security-review` on restricted areas - so the human reviews polished work, not first drafts.

> **Roles are a separation of concerns, not necessarily separate sessions.** A single capable agent can play each role in sequence; the value is that each concern gets explicit attention, the same way a good developer plans, codes, tests, then reviews.

---

## Human Checkpoints

Autonomy without checkpoints is just unsupervised AI with extra steps. These are the points where a human must engage - chosen because they're where judgment, accountability, or irreversibility live.

| Checkpoint | Owner | What They Verify | Gate |
|------------|-------|------------------|------|
| Plan approval | Developer / lead | The approach is sound before any code is written | Agent waits for approval |
| PR review | Reviewer | Code is correct, readable, follows standards | Required approval on the PR |
| Restricted-area sign-off | Senior | Auth, payments, migrations, security are correct | Senior approval mandatory |
| Production deploy | Lead | The release is ready and rollback is ready | Manual deploy approval |

### The Principle

**Humans review intent and outcomes; automation enforces correctness.**

- *Correctness* - formatting, types, tests, coverage - is mechanical. CI does it, every time, without fatigue. Don't spend human attention there.
- *Intent and judgment* - is this the right approach? is this safe to ship? does this restricted change actually do what we mean? - is human. That's where the checkpoints are.

This is the same discipline from [2.4 Supervised AI](../phase2/04-supervised-ai.md), formalized into a system: you own the code you merge, no matter who wrote it. The boundaries, policies, and KPIs that keep this honest at scale are covered in [3.4 Governance](04-governance.md).

---

## Checklist - Done When

- [ ] The agentic loop is documented and the team has run it end to end on a real ticket
- [ ] The agent proposes a plan and waits for human approval before implementing
- [ ] The agent runs tests locally and iterates on CI failures on its own
- [ ] No agent-authored PR merges without CI green **and** a human approval
- [ ] Agent roles (Planner / Implementer / Tester / Reviewer) are defined and in use
- [ ] All four human checkpoints are enforced, with restricted areas requiring senior sign-off
- [ ] Production deploys still require explicit human approval
- [ ] The team understands they own merged code regardless of who authored it
