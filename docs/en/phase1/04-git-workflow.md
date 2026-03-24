# 1.4 Git Workflow

> A broken git workflow is the first thing that breaks agentic coding. If branches are chaotic and commits are meaningless, the AI has no reliable history to reason about — and neither does the team.

---

## Goals

- Establish a branching strategy that supports parallel work without conflict
- Enforce a commit message convention that makes history readable and automation-friendly
- Define a lightweight PR process that enforces review without creating bottlenecks
- Protect critical branches from direct pushes and force-pushes
- Give the AI assistant (Claude Code) a clean, structured history to work from

---

## Branching Strategy

### Model: GitHub Flow (simplified)

GitHub Flow is the right choice for most Laravel teams. It's simple enough for junior developers, structured enough for production, and works well with AI-assisted development.

```
main
  └── feature/TICKET-123-add-user-authentication
  └── fix/TICKET-456-correct-invoice-total
  └── chore/update-dependencies
```

| Branch Type | Pattern | Purpose |
|-------------|---------|---------|
| `main` | `main` | Production-ready code. Protected. |
| Feature | `feature/TICKET-ID-short-description` | New features tied to a ticket |
| Fix | `fix/TICKET-ID-short-description` | Bug fixes |
| Chore | `chore/short-description` | Maintenance (deps, config, docs) |
| Hotfix | `hotfix/short-description` | Emergency production fixes |

### Branch Naming Rules

- Always lowercase, words separated by hyphens
- Always start with the type prefix (`feature/`, `fix/`, `chore/`, `hotfix/`)
- Include the ticket ID when one exists
- Keep the description short — under 5 words
- No slashes except the prefix separator

**Good:**
```
feature/PROJ-101-add-payment-gateway
fix/PROJ-245-fix-null-invoice-total
chore/upgrade-laravel-11
hotfix/revert-broken-migration
```

**Bad:**
```
johns-branch
new_feature
feature/added-some-stuff-for-the-payment-thing
```

### Branch Lifecycle

1. Create from `main` — never from another feature branch
2. Work in small, frequent commits
3. Open a PR when ready for review
4. Merge via PR — never directly to `main`
5. Delete the branch after merge

---

## Commit Message Convention

### Format: Conventional Commits

Use [Conventional Commits](https://www.conventionalcommits.org/) — a widely adopted standard that makes history readable and enables automated changelogs.

```
<type>(<scope>): <short description>

[optional body]

[optional footer: TICKET-ID, breaking changes, etc.]
```

### Commit Types

| Type | When to Use |
|------|------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `chore` | Build process, dependency updates, config changes |
| `docs` | Documentation only |
| `style` | Code style changes (Pint formatting, whitespace — no logic change) |
| `perf` | Performance improvement |
| `revert` | Reverting a prior commit |

### Examples

```
feat(auth): add two-factor authentication via TOTP

fix(invoices): correct subtotal calculation when discount is applied

refactor(OrderController): extract order creation to CreateOrderAction

test(InvoiceService): add unit tests for discount edge cases

chore: upgrade Laravel from 10 to 11

docs: update API authentication section in README

style: apply Pint formatting to app/Models

BREAKING CHANGE: remove legacy v1 API endpoints
Closes PROJ-189
```

### Short Description Rules

- Use imperative mood: "add" not "added", "fix" not "fixed"
- No capital letter at the start
- No period at the end
- Under 72 characters
- Describe *what* the commit does, not *why* (use the body for why)

### When to Add a Body

Add a body when:
- The change is non-obvious and needs context
- You're describing a trade-off or design decision
- There's a ticket reference or breaking change

```
refactor(UserService): split authentication and authorization logic

Authentication (who are you?) and authorization (what can you do?) were
mixed in UserService. Split into AuthService and PolicyService to follow
single-responsibility and make it easier for the AI agent to reason
about each concern independently.

Closes PROJ-312
```

---

## Pull Request Process

### PR Rules

- Every change to `main` must go through a PR
- Minimum 1 reviewer approval before merging
- All automated checks must pass (Pint, PHPStan, tests)
- PRs should be small and focused — one logical change per PR
- Draft PRs are encouraged for early feedback

### PR Title

Follow the same convention as commit messages:

```
feat(auth): add two-factor authentication via TOTP
fix(invoices): correct subtotal calculation when discount is applied
```

### PR Description Template

Add `.github/pull_request_template.md` to the repo:

```markdown
## Summary

<!-- What does this PR do? One paragraph. -->

## Changes

-
-
-

## Testing

<!-- How was this tested? -->
- [ ] Unit tests added/updated
- [ ] Manual test steps performed

## Checklist

- [ ] Pint formatting passes
- [ ] PHPStan passes
- [ ] Tests pass
- [ ] No secrets or debug code committed
- [ ] Ticket linked (if applicable)

Closes #TICKET-ID
```

### Review Guidelines

**For reviewers:**
- Review within 1 business day
- Focus on logic, architecture, and correctness — not style (that's Pint's job)
- Approve if the code is correct and follows conventions, even if you'd do it differently
- Leave actionable comments: "Consider X because Y" not just "I don't like this"

**For authors:**
- Respond to all comments — either fix or explain why not
- Don't merge without approval
- Keep PRs under 400 lines of change where possible — large PRs get poor reviews

### Merging

Use **Squash and Merge** for feature branches — keeps `main` history clean with one commit per feature.

Use **Merge Commit** only for hotfixes where you want to preserve the exact commit history for a post-mortem.

Never use **Rebase and Merge** — it rewrites history and breaks `git bisect`.

---

## Branch Protection

Configure these rules on `main` in GitHub/GitLab:

### Required Settings

| Setting | Value | Reason |
|---------|-------|--------|
| Require PR before merging | ✅ Enabled | No direct pushes to main |
| Required approvals | 1 minimum | At least one other person reviews |
| Dismiss stale reviews | ✅ Enabled | New commits require re-approval |
| Require status checks to pass | ✅ Enabled | CI must pass before merge |
| Require branches to be up to date | ✅ Enabled | No merging outdated branches |
| Restrict force pushes | ✅ Enabled | Protect history integrity |
| Restrict deletions | ✅ Enabled | Nobody accidentally deletes main |

### GitHub: Setting It Up

Go to: `Repository → Settings → Branches → Add branch protection rule`

Branch name pattern: `main`

Enable all settings listed above.

### Why This Matters for Agentic Coding

When Claude Code operates in agentic mode (Phase 3), it can create branches and open PRs. Branch protection ensures that even if an agent makes a mistake, it cannot merge its own work without human review. The CI checks act as a safety net — the agent must produce passing code, not just plausible-looking code.

---

## Checklist — Done When

- [ ] Branching strategy documented and shared with team
- [ ] All developers understand the branch naming convention
- [ ] Conventional Commits convention adopted — team has reference card
- [ ] PR template committed to `.github/pull_request_template.md`
- [ ] Branch protection rules configured on `main`
- [ ] CI checks wired to branch protection (see [1.6 Deployment](06-deployment.md))
- [ ] At least one full cycle completed: branch → commit → PR → review → merge
- [ ] Team agrees on squash merge as the default strategy
