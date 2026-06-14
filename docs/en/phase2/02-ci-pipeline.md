# 2.2 CI Pipeline

> A pre-commit hook catches mistakes on the developer's machine. A CI pipeline catches them everywhere else - including on the AI agent's machine. If the pipeline doesn't run automatically on every PR, there is no safety net.

---

## Goals

- Configure Bitbucket Pipelines to run on every pull request automatically
- Enforce code style (Pint), static analysis (PHPStan), and tests (Pest) in CI
- Block merges when any check fails - no exceptions
- Establish a coverage gate that prevents regressions
- Create the automated feedback loop that makes AI-assisted coding safe in Phase 3
- Keep pipeline execution under 5 minutes to avoid slowing down the team

---

## Why CI Before AI

Pre-commit hooks (set up in [1.3 Tooling](../phase1/03-tooling-selection.md)) run on the developer's local machine. They work - until they don't:

- A developer skips them (`--no-verify`)
- A new team member hasn't run `composer install` yet
- The AI agent creates a branch and pushes directly
- Someone commits from a machine without the hooks installed

CI is the second wall. It runs in a clean environment, every time, on every PR. No one can skip it. No one can forget it. The pipeline doesn't care who wrote the code - human or AI. It checks everything the same way.

In Phase 3, the AI agent will push code, open PRs, and iterate based on CI feedback. If the pipeline isn't in place before then, you're giving an AI commit access with no guardrails.

**The rule is simple:** nothing merges to `main` unless the pipeline passes. Not for humans, not for AI.

---

## Bitbucket Pipelines Setup

### Base Configuration

Create `bitbucket-pipelines.yml` in the project root:

```yaml
image: php:8.2-cli

definitions:
  caches:
    composer:
      key:
        files:
          - composer.lock
      path: vendor

  steps:
    - step: &install
        name: Install Dependencies
        caches:
          - composer
        script:
          - apt-get update && apt-get install -y git unzip libzip-dev libsqlite3-dev
          - docker-php-ext-install zip pdo_sqlite
          - curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
          - composer install --no-interaction --prefer-dist --optimize-autoloader
        artifacts:
          - vendor/**

pipelines:
  pull-requests:
    '**':
      - step: *install
      - parallel:
          - step:
              name: Code Style (Pint)
              script:
                - ./vendor/bin/pint --test
          - step:
              name: Static Analysis (PHPStan)
              script:
                - ./vendor/bin/phpstan analyse --memory-limit=512M
          - step:
              name: Tests (Pest)
              script:
                - cp .env.testing .env
                - php artisan key:generate
                - ./vendor/bin/pest --coverage --min=60
```

### What This Does

```
PR opened / updated
       │
       ▼
┌──────────────┐
│   Install    │  ← Composer install, cache dependencies
│ Dependencies │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│            Run in Parallel               │
│                                          │
│  ┌─────────┐  ┌──────────┐  ┌────────┐  │
│  │  Pint   │  │ PHPStan  │  │  Pest  │  │
│  │ (style) │  │(analysis)│  │(tests) │  │
│  └─────────┘  └──────────┘  └────────┘  │
└──────────────────────────────────────────┘
       │
       ▼
  All pass? → ✅ Merge allowed
  Any fail? → ❌ Merge blocked
```

The install step runs first and produces an artifact (`vendor/`). The three check steps run in parallel - they share the artifact but don't depend on each other. This keeps the pipeline fast.

### Environment File for CI

Create `.env.testing` in the project root (commit it - it contains no secrets):

```env
APP_NAME=Laravel
APP_ENV=testing
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=sqlite
DB_DATABASE=:memory:

BCRYPT_ROUNDS=4
CACHE_STORE=array
MAIL_MAILER=array
QUEUE_CONNECTION=sync
SESSION_DRIVER=array
```

This mirrors the `phpunit.xml` env settings from [2.1 Testing](01-testing.md) but in `.env` format for CI.

---

## Pipeline Stages - In Detail

### Stage 1: Code Style (Pint)

```yaml
- step:
    name: Code Style (Pint)
    script:
      - ./vendor/bin/pint --test
```

`--test` checks formatting without modifying files. If any file doesn't match the Pint configuration, the step fails.

**Why run Pint in CI if we already have a pre-commit hook?**

Because the pre-commit hook only runs on the developer's machine. CI is the enforcer of last resort. If someone bypasses the hook - intentionally or accidentally - CI catches it.

**When it fails:** the developer runs `./vendor/bin/pint` locally, commits the fix, and pushes again.

### Stage 2: Static Analysis (PHPStan)

```yaml
- step:
    name: Static Analysis (PHPStan)
    script:
      - ./vendor/bin/phpstan analyse --memory-limit=512M
```

PHPStan reads the `phpstan.neon` configuration committed to the repo (set up in [1.3 Tooling](../phase1/03-tooling-selection.md)). The `--memory-limit=512M` flag prevents out-of-memory crashes on larger codebases.

**When it fails:** the developer fixes the reported errors locally. PHPStan errors are real bugs - type mismatches, undefined methods, impossible conditions.

### Stage 3: Tests (Pest)

```yaml
- step:
    name: Tests (Pest)
    script:
      - cp .env.testing .env
      - php artisan key:generate
      - ./vendor/bin/pest --coverage --min=60
```

This runs the full test suite and enforces a minimum 60% overall coverage. If coverage drops below 60%, the step fails - even if all tests pass.

**Why `cp .env.testing .env`?** Laravel needs an `.env` file to boot. In CI, there's no `.env` - we copy the testing config into place.

**Why `php artisan key:generate`?** Laravel requires `APP_KEY` to be set. Generating it in CI is safe because this key is never used in production.

---

## PHPStan Baseline - Dealing with Legacy Code

If you're adding CI to an existing project, PHPStan will likely report hundreds of errors on legacy code that nobody is going to fix right now. The solution is a **baseline**.

### Generate a Baseline

```bash
./vendor/bin/phpstan analyse --generate-baseline
```

This creates `phpstan-baseline.neon` - a file that lists every current error and tells PHPStan to ignore them. New code must be clean; old errors are tracked but don't block CI.

### Update phpstan.neon

```neon
includes:
    - vendor/larastan/larastan/extension.neon
    - phpstan-baseline.neon

parameters:
    paths:
        - app
    level: 5
```

### Commit the Baseline

```bash
git add phpstan-baseline.neon phpstan.neon
git commit -m "chore: add PHPStan baseline for legacy code"
```

### The Ratchet Strategy

Over time, reduce the baseline:

1. Start at PHPStan **level 5** with a baseline
2. When a developer touches a file, fix the PHPStan errors in that file
3. Regenerate the baseline periodically - it should shrink
4. Every quarter, consider bumping the level: 5 → 6 → 7 → 8

**Never increase the level and regenerate the baseline at the same time** - that hides new errors behind the baseline. Increase the level, fix the new errors, then commit.

---

## Coverage Gates

### Minimum Coverage in CI

The `--min=60` flag in the Pest step enforces overall coverage:

```bash
./vendor/bin/pest --coverage --min=60
```

| Metric | Target | Enforced In |
|--------|--------|-------------|
| Overall coverage | 60% minimum | CI (`--min=60`) |
| New code coverage | 80% recommended | Code review (manual) |
| AI-generated code | 100% of changed lines | Code review (manual) |

The 60% overall threshold is enforced automatically. The 80% and 100% targets for new/AI code are enforced through code review - Pest doesn't distinguish "new" from "old" code automatically.

### Coverage Reports

Generate an HTML coverage report as a CI artifact:

```yaml
- step:
    name: Tests (Pest)
    script:
      - cp .env.testing .env
      - php artisan key:generate
      - ./vendor/bin/pest --coverage --min=60 --coverage-html=coverage-report
    artifacts:
      - coverage-report/**
```

Reviewers can download the report from the Bitbucket pipeline results to see exactly which lines are covered.

### Raising the Bar Over Time

| Phase | Coverage Gate | Rationale |
|-------|-------------|-----------|
| Phase 2 start | 60% | Realistic for legacy code with new smoke tests |
| Phase 2 end | 70% | Feature tests added for critical flows |
| Phase 3 | 80% | AI generates tests for all new code |

Increase the `--min` value as coverage grows naturally. Don't chase numbers - let the tests add value first.

---

## Merge Gates

### Bitbucket Branch Permissions

Configure branch permissions so that no code reaches `main` without passing the pipeline.

**Settings path:** `Repository Settings → Branch permissions → Add a branch permission`

| Setting | Value |
|---------|-------|
| Branch | `main` |
| Write access | No direct pushes - PR only |
| Merge checks | All builds must pass |
| Minimum approvals | 1 |
| Merge strategy | Squash (default) |

### The Merge Checklist

Before any PR can merge to `main`:

```
✅ Pint passes      - code is formatted
✅ PHPStan passes   - no static analysis errors
✅ Pest passes      - all tests green
✅ Coverage ≥ 60%   - no coverage regression
✅ 1 approval       - a human reviewed it
```

If any item fails, the merge button is disabled. No exceptions.

### Why This Matters

This isn't bureaucracy - it's the mechanism that makes Phase 3 possible. When the AI agent opens a PR, it goes through the exact same gates as a human. The pipeline doesn't trust the AI. It verifies.

```
AI writes code → pushes branch → opens PR
                                    │
                              Pipeline runs
                                    │
                         ┌──── Pass? ────┐
                         │               │
                    Human reviews    Pipeline fails
                    and approves     AI reads errors
                         │           and iterates
                    Merge to main        │
                                    Push fix → Pipeline reruns
```

---

## Pipeline for AI-Generated Code

### The Automated Feedback Loop

In Phase 3, the CI pipeline becomes the AI agent's primary feedback mechanism. The agent doesn't just push code and hope - it reads the pipeline results and iterates.

```
┌───────────────────────────────────────────┐
│           AI Agent Workflow                │
│                                           │
│   1. Read task / ticket                   │
│   2. Write code                           │
│   3. Run tests locally (fast feedback)    │
│   4. Push branch, open PR                 │
│   5. CI pipeline runs                     │
│   6. If CI fails → read errors → fix      │
│   7. If CI passes → request human review  │
└───────────────────────────────────────────┘
```

The pipeline is what makes this loop safe. Without it, step 6 doesn't exist - and the AI pushes broken code that a human has to debug manually.

### What CI Catches That Local Tests Might Miss

| Issue | Local | CI |
|-------|-------|-----|
| Missing dependency (not committed) | ❌ Works locally | ✅ Fails - clean install |
| Environment-specific bug | ❌ Works on dev machine | ✅ Fails - different environment |
| Uncommitted file | ❌ Tests pass (file exists locally) | ✅ Fails - file not in repo |
| Race condition in parallel tests | ❌ Passes sometimes | ✅ More likely to surface |
| Coverage regression | ❌ Dev doesn't check | ✅ `--min` enforces it |

### Preparing the Pipeline for Phase 3

The pipeline you build now in Phase 2 is the same pipeline the AI uses in Phase 3. No changes needed - by design. The only difference is who pushes the code.

---

## Troubleshooting

### SQLite vs MySQL in CI

The pipeline configuration uses SQLite in-memory for speed. This works for most Laravel tests. However, if your application uses MySQL-specific features (JSON columns, full-text search, specific SQL syntax), tests may pass locally on MySQL but fail in CI on SQLite.

**Option 1: Stay with SQLite** (recommended for most projects)

Keep SQLite for speed. Write tests that don't depend on database-specific syntax. This is the default approach.

**Option 2: Use MySQL in CI**

If you need MySQL, add a service container:

```yaml
- step:
    name: Tests (Pest)
    services:
      - mysql
    script:
      - cp .env.ci-mysql .env
      - php artisan key:generate
      - php artisan migrate
      - ./vendor/bin/pest --coverage --min=60

definitions:
  services:
    mysql:
      image: mysql:8.0
      variables:
        MYSQL_DATABASE: testing
        MYSQL_ROOT_PASSWORD: password
```

With a corresponding `.env.ci-mysql`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=testing
DB_USERNAME=root
DB_PASSWORD=password
```

**Trade-off:** MySQL adds 30-60 seconds to pipeline startup. Use it only if SQLite causes real test failures.

### Pipeline Too Slow

| Problem | Solution |
|---------|----------|
| Composer install takes too long | Enable caching (already in the config above) |
| PHPStan is slow on large codebase | Add `--memory-limit=1G` and consider splitting analysis |
| Tests take over 5 minutes | Run Pest in parallel: `--parallel` |
| Repeated package downloads | Composer cache key is tied to `composer.lock` - changes only when deps change |

### Parallel Test Execution

If your test suite grows beyond 3-4 minutes, enable parallel execution:

```yaml
- step:
    name: Tests (Pest)
    script:
      - cp .env.testing .env
      - php artisan key:generate
      - ./vendor/bin/pest --parallel --coverage --min=60
```

**Requirement:** Pest parallel requires the `brianium/paratest` package:

```bash
composer require brianium/paratest --dev
```

### Memory Limits

PHPStan and Pest can both hit memory limits on large projects:

```yaml
# PHPStan
- ./vendor/bin/phpstan analyse --memory-limit=1G

# Pest (via php.ini)
- echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory.ini
- ./vendor/bin/pest --coverage --min=60
```

### Common CI Failures and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Class not found` | Missing autoload | Run `composer dump-autoload` or check namespace |
| `APP_KEY is empty` | Missing key generation | Add `php artisan key:generate` to pipeline |
| `SQLite driver not found` | Missing PHP extension | Add `docker-php-ext-install pdo_sqlite` |
| `Permission denied` | File not executable | Check file permissions in repo |
| `Coverage below minimum` | Tests don't cover enough code | Write more tests or lower the threshold temporarily |

---

## Full Pipeline Configuration

Here's the complete, production-ready `bitbucket-pipelines.yml`:

```yaml
image: php:8.2-cli

definitions:
  caches:
    composer:
      key:
        files:
          - composer.lock
      path: vendor

  steps:
    - step: &install
        name: Install Dependencies
        caches:
          - composer
        script:
          - apt-get update && apt-get install -y git unzip libzip-dev libsqlite3-dev
          - docker-php-ext-install zip pdo_sqlite
          - curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
          - composer install --no-interaction --prefer-dist --optimize-autoloader
        artifacts:
          - vendor/**

pipelines:
  pull-requests:
    '**':
      - step: *install
      - parallel:
          - step:
              name: Code Style (Pint)
              script:
                - ./vendor/bin/pint --test
          - step:
              name: Static Analysis (PHPStan)
              script:
                - ./vendor/bin/phpstan analyse --memory-limit=512M
          - step:
              name: Tests (Pest)
              script:
                - cp .env.testing .env
                - php artisan key:generate
                - ./vendor/bin/pest --coverage --min=60

  branches:
    main:
      - step: *install
      - parallel:
          - step:
              name: Code Style (Pint)
              script:
                - ./vendor/bin/pint --test
          - step:
              name: Static Analysis (PHPStan)
              script:
                - ./vendor/bin/phpstan analyse --memory-limit=512M
          - step:
              name: Tests (Pest)
              script:
                - cp .env.testing .env
                - php artisan key:generate
                - ./vendor/bin/pest --coverage --min=60 --coverage-html=coverage-report
              artifacts:
                - coverage-report/**
```

The `branches.main` section runs the same checks after merge - plus generates a coverage report artifact. This catches any issues that slip through (e.g., merge conflicts that introduce bugs).

---

## Checklist - Done When

- [ ] `bitbucket-pipelines.yml` committed to the repo
- [ ] `.env.testing` committed (no secrets)
- [ ] Pipeline runs automatically on every PR
- [ ] Pint check passes in CI
- [ ] PHPStan check passes in CI (with baseline if needed)
- [ ] Pest tests pass in CI with coverage reporting
- [ ] Coverage minimum enforced (`--min=60`)
- [ ] PHPStan baseline generated and committed (if legacy project)
- [ ] Branch permissions configured: builds must pass + 1 approval
- [ ] Merge to `main` is blocked when any pipeline step fails
- [ ] Team has seen a failed pipeline and knows how to read the logs
- [ ] Pipeline completes in under 5 minutes
