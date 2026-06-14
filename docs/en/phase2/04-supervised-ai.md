# 2.4 Supervised AI Introduction

> Treat AI like a brilliant, fast, eager junior developer who has read every Laravel doc but has never been burned by a production incident. It will produce a lot of good code and the occasional confidently-wrong disaster. Supervision is what turns that junior into someone the team trusts.

---

## Goals

- Get every developer using Claude Code on real tasks, under supervision
- Define clear boundaries: which tasks AI can take on, and which it can't
- Build a baseline of prompt-engineering skill across the team
- Establish a non-negotiable review habit for AI-generated code
- Build the confidence and discipline that Phase 3 autonomy depends on

---

## Why "Supervised"

The safety nets are now in place: [tests](01-testing.md), a [CI pipeline](02-ci-pipeline.md), and a consistent [environment](03-environment.md). The team also knows the tool - [1.5 Claude Code Deep Dive](../phase1/05-claude-code.md) covered its features. This phase is where theory meets a real codebase.

It's called *supervised* on purpose. In Phase 2, a human is always in the loop: choosing the task, guiding the prompt, and reviewing every line before it merges. The AI is a collaborator, not an autonomous agent. That comes in [Phase 3](../phase3/01-agentic-methodology.md) - and only after the team has built the instincts this phase teaches.

> **Start on the extension, not the CLI agent.** As recommended in [1.3 Tooling Selection](../phase1/03-tooling-selection.md), the VS Code extension keeps the developer in the driver's seat. The autonomous CLI agent is a Phase 3 tool.

---

## AI-Safe Tasks

These are tasks where AI is genuinely strong and the blast radius of a mistake is small. They get **light review** - read it, run the tests, merge it.

| Task Type | Why It's Safe | Review Level |
|-----------|---------------|--------------|
| Boilerplate CRUD | Predictable, pattern-based | Light |
| Writing tests for existing code | Tests are verifiable; you read the assertions | Light + read assertions |
| Refactors **with test coverage** | Tests catch regressions | Light |
| Documentation & comments | No runtime impact | Light |
| Blade views / UI markup | Visually verifiable | Light |
| Form Requests & validation rules | Easy to read and test | Light |
| Factories & seeders | Test-only code | Light |
| Repetitive edits across many files | AI excels at mechanical consistency | Light |

The pattern: **AI-safe means verifiable.** If a human can quickly confirm the result is correct (or a test confirms it), AI can lead.

---

## AI-Restricted Areas

These are the areas mapped as high-risk back in [1.1 Codebase & Architecture Review](../phase1/01-codebase-architecture.md). AI can *assist* here, but a senior must review and sign off. Never light-touch.

| Restricted Area | Why | Required |
|-----------------|-----|----------|
| Authentication & authorization | A subtle bug = security hole | Senior sign-off |
| Payments & billing | Money is unforgiving | Senior sign-off |
| Database migrations on production data | Hard or impossible to reverse | Senior review + backup |
| Security-sensitive code (encryption, tokens, file uploads) | High-impact failure modes | Senior + [`/security-review`](#review-rules) |
| Infrastructure & queue configuration | Affects the whole system | Senior sign-off |
| Any code with no test coverage | Nothing to catch a regression | Write tests first, then proceed |

> **Rule of thumb:** If a mistake here would cost money, leak data, or be hard to undo, a human owns it. AI can draft; a senior decides.

---

## Hands-on Sessions

This phase is hands-on, not a lecture. The migration plan already includes 2 weekly supervision meetings - use them to coach AI work on real tickets.

### Session Structure

| Part | Duration | Focus |
|------|----------|-------|
| Warm-up | 10 min | Review last week's AI-assisted PRs together |
| Live coding | 30 min | Lead picks a real ticket, the team drives Claude Code on it |
| Pairing | 30 min | Devs pair on their own tickets with AI; lead floats |
| Debrief | 10 min | What worked, what AI got wrong, what to watch for |

### Task Progression

Start small and verifiable, then widen the scope as trust builds:

1. **Week 1-2:** AI-safe tasks only - write a test, add a form request, generate a factory
2. **Week 3:** A small CRUD feature end to end, fully reviewed
3. **Week 4:** A refactor on code that already has tests

Refer to [1.5 Claude Code Deep Dive](../phase1/05-claude-code.md) for the specific features (plan mode, slash commands, `CLAUDE.md`) the team should be practicing in these sessions.

---

## Prompt Engineering Basics

The quality of AI output is mostly determined by the quality of the prompt. The team doesn't need tricks - it needs a few solid habits.

### The Habits That Matter

- **Give context.** Point the AI at the relevant files, the related model, the existing pattern to follow.
- **Be specific.** "Add validation" is weak. "Add a Form Request that validates `email` is required and unique on `users`" is strong.
- **Ask for a plan first.** On anything non-trivial, have the AI propose an approach before it writes code. Cheaper to fix a plan than a diff.
- **State acceptance criteria.** Tell it what "done" looks like - ideally as a test it must make pass.
- **Iterate.** The first output is a draft. Refine it; don't accept-and-merge.

### Weak vs Strong Prompt

```text
❌ Weak:
"Make an orders feature."

✅ Strong:
"Add an OrderController with store() following the pattern in
ProductController. Validate via a new StoreOrderRequest (product_id
required+exists, quantity required+min:1). Return 201 with the order
JSON. Write a Pest feature test covering the happy path and a 422
validation case. Show me the plan before editing."
```

> **Remember `CLAUDE.md`.** The project's `CLAUDE.md` (from [1.5](../phase1/05-claude-code.md)) already feeds the AI your standards and conventions on every prompt. Good prompts build on that shared context instead of repeating it.

---

## Review Rules

This is the heart of supervision. AI-generated code is *unreviewed by default* - the human reviewer is the safety net that the tests and CI can't replace.

### The Non-Negotiables

- ❌ **Never merge code you haven't read.** "The tests pass" is necessary, not sufficient.
- ❌ **Never merge AI-written tests without reading every assertion.** AI is great at test *structure* and bad at knowing the *correct* business behavior (see [2.1 Testing](01-testing.md)).
- ✅ **Run it locally.** Don't review only the diff - run the code.
- ✅ **CI must be green.** Pint, PHPStan, and Pest all pass (see [2.2 CI Pipeline](02-ci-pipeline.md)). No exceptions.
- ✅ **Run `/security-review` on anything touching a restricted area** - auth, authorization, payments, or user input.

### The Reviewer's Questions

| Question | Why It Matters |
|----------|----------------|
| Do I understand every line? | If you can't explain it, you can't own it |
| Does it follow our existing patterns? | AI sometimes invents its own conventions |
| Are the test assertions actually correct? | A passing test can assert the wrong thing |
| Did it touch anything in a restricted area? | If so, escalate to senior review |
| Would I have shipped this if I'd written it? | The honest bar for "good enough" |

> **Rule of thumb:** You own the code you merge, regardless of who or what wrote it. "The AI wrote it" is never an explanation for a production bug. Supervision here is exactly the muscle Phase 3 turns into the [human checkpoints](../phase3/01-agentic-methodology.md) of agentic coding.

---

## Checklist - Done When

- [ ] Every developer has completed at least one AI-assisted PR under supervision
- [ ] The AI-safe vs AI-restricted boundaries are documented and agreed
- [ ] The team runs Claude Code via the VS Code extension on real tickets
- [ ] Every developer can write a strong, context-rich prompt and ask for a plan first
- [ ] No AI-generated code merges without a human reading every line
- [ ] AI-written tests are reviewed assertion by assertion before merge
- [ ] `/security-review` is run on every PR touching a restricted area
- [ ] The 2 weekly hands-on sessions are running and producing reviewed PRs
