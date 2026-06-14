# 1.6 Deployment

> AI makes writing code 10x faster. If deploying that code is still a slow, manual, error-prone ritual that only one person knows how to do, the bottleneck just moves downstream - and a bad deploy at 10x speed is a bigger outage, not a smaller one.

---

## Goals

- Document the current deployment process so it stops living in one person's head
- Identify the pain points that become dangerous once AI accelerates output
- Establish a repeatable, written deployment runbook plus a simple `deploy.sh`
- Add maintenance mode and a tested rollback path
- Lay the groundwork for the CI-gated, automated deploys that arrive in Phase 2 and Phase 3

---

## Why Deployment Belongs in Phase 1

Phase 1 is about stabilizing the foundation before AI is introduced. Standards, Git discipline, and a clean codebase mean nothing if the path to production is chaos.

Right now the team probably deploys the way most legacy Laravel projects do: someone SSHes into the server, pulls the latest code, runs a few commands from memory, and hopes nothing breaks. That works at human speed because changes are infrequent. It stops working the moment AI starts producing changes faster than a fragile manual deploy can absorb them.

This page does not automate deployment - that's Phase 2 ([CI Pipeline](../phase2/02-ci-pipeline.md)) and Phase 3 ([CI/CD Maturity](../phase3/02-cicd-maturity.md)). It does something more basic and more urgent: **make the current process written, repeatable, and reversible.**

---

## Current Process Review

The first step is honest documentation. Write down exactly how deployment happens today - every command, in order, including the ones people forget.

A typical manual Laravel deploy looks like this:

| Step | Command | Often Forgotten? |
|------|---------|------------------|
| 1. Connect to server | `ssh deploy@server` | - |
| 2. Pull latest code | `git pull origin main` | - |
| 3. Install dependencies | `composer install --no-dev --optimize-autoloader` | Sometimes (`--no-dev`) |
| 4. Run migrations | `php artisan migrate --force` | **Often** |
| 5. Clear / rebuild caches | `php artisan config:cache route:cache view:cache` | **Often** |
| 6. Build frontend assets | `npm ci && npm run build` | Sometimes |
| 7. Restart queue workers | `php artisan queue:restart` | **Almost always** |

> If your team cannot produce this list from memory in the same order every time, that is the problem this page exists to solve.

The deliverable for this section is a single document - committed to the repo - that captures the real process, not the idealized one.

---

## Pain Points

Once the process is written down, the weaknesses become obvious. These are the ones that turn from "annoying" into "dangerous" the moment AI increases the volume and frequency of changes.

| Pain Point | Impact Today | Risk Once AI Accelerates Output |
|------------|--------------|--------------------------------|
| Manual, memorized steps | Occasional missed step | More deploys → more chances to forget a step |
| No rollback plan | Stressful hotfixes | A bad AI-generated change has no fast undo |
| Downtime during deploy | Users see errors mid-deploy | More frequent deploys = more frequent downtime |
| Config / env drift | "Works on staging, not prod" | AI code passes CI, then fails on a drifted server |
| Forgotten `migrate` | Runtime errors after deploy | Schema changes from AI silently un-applied |
| Deploys from a dev laptop | Untracked, unrepeatable | No record of what was actually shipped |
| No queue restart | Workers run stale code | Background jobs run old logic against new data |

The common thread: **every one of these is a human-memory problem.** The fix is to move the process out of memory and into a script and a checklist.

---

## Improvements

These are deliberately light-touch. The goal is stability and repeatability now - not a full CI/CD pipeline (that comes later).

### 1. A Written Runbook

Commit a `DEPLOYMENT.md` to the repo with the exact, ordered steps from the Current Process Review. One source of truth. Anyone on the team can deploy by following it.

### 2. A Simple `deploy.sh`

Turn the runbook into a script so the steps can't be skipped or reordered:

```bash
#!/usr/bin/env bash
set -euo pipefail   # stop on any error

php artisan down --retry=15          # maintenance mode

git pull origin main
composer install --no-dev --optimize-autoloader
npm ci && npm run build

php artisan migrate --force          # --force = no interactive prompt

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan queue:restart

php artisan up                        # back online
```

`set -euo pipefail` is the important line: if any step fails, the script stops instead of limping forward into a half-deployed state.

### 3. Maintenance Mode

`php artisan down` puts the app behind a maintenance page during deploy; `php artisan up` brings it back. Users see a clean "be right back" page instead of 500 errors mid-deploy.

> **Rule of thumb:** Always wrap a deploy in `down` / `up`. The few seconds of maintenance page are far better than a user hitting a half-migrated database.

### 4. A Tested Rollback Path

A deploy you can't undo is a gamble. Tag every release so you can return to a known-good state:

```bash
git tag -a v1.4.2 -m "Release 1.4.2" && git push --tags   # before deploy
git checkout v1.4.1 && ./deploy.sh                          # rollback
```

Rollback is only real if you've actually run it once. Test it on staging before you ever need it in production.

### 5. Don't Deploy From a Laptop

Deploys should run on the server (or a fixed deploy machine), from `main`, using the committed script - never ad-hoc from a developer's machine. This guarantees what's deployed matches what's in the repo.

### What Comes Later (Not Now)

| Improvement | Phase | Why Wait |
|-------------|-------|----------|
| Atomic / zero-downtime releases (Deployer, Envoyer) | Phase 3 | Needs a stable base process first |
| Deploy only after CI passes | Phase 2 | Requires the [CI Pipeline](../phase2/02-ci-pipeline.md) |
| Automated deploy on merge to `main` | Phase 3 | See [CI/CD Maturity](../phase3/02-cicd-maturity.md) |
| Guaranteed environment parity | Phase 2 | See [2.3 Environment](../phase2/03-environment.md) |

The script and runbook you write now are not throwaway - they become the exact steps the automated pipeline runs later. You're not building twice; you're building the foundation.

---

## Checklist - Done When

- [ ] The real deployment process is documented step-by-step in `DEPLOYMENT.md`
- [ ] A `deploy.sh` exists, is committed, and uses `set -euo pipefail`
- [ ] Every deploy runs `php artisan down` before and `php artisan up` after
- [ ] Migrations run with `--force` and caches are rebuilt as part of the script
- [ ] Queue workers are restarted on every deploy (`queue:restart`)
- [ ] Releases are tagged in Git, and a rollback has been tested on staging
- [ ] Deploys run on the server from `main`, not from a developer's laptop
- [ ] The whole team can deploy by following the runbook - not just one person
