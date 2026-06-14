# 2.3 Environment

> "Works on my machine" is the oldest excuse in software - and it's fatal to AI-assisted coding. If the developer's machine, CI, staging, and production all run different versions, a green test suite proves nothing. Parity is what makes a passing test mean "this works in production."

---

## Goals

- Containerize local development so every developer runs an identical environment
- Match the local PHP version and extensions to CI and production
- Achieve parity across dev, staging, and production - same versions, same services
- Eliminate config drift through disciplined `.env` management
- Make "it passed the tests, so it works in production" a true statement

---

## Why Parity Before Supervised AI

Phase 2 builds safety nets. [Testing](01-testing.md) and the [CI Pipeline](02-ci-pipeline.md) verify that code is correct - but they only verify it against *whatever environment they run in*. If that environment doesn't match production, the safety net has a hole in it.

This matters more with AI in the loop. When a developer writes code, they carry a mental model of the production environment and unconsciously code around its quirks. AI doesn't. It generates code against the environment it can observe. If that environment differs from production, AI-generated code that passes every check can still break on deploy - and nobody will understand why.

Parity closes that gap. When dev, CI, staging, and production are the same, "the tests pass" becomes a promise you can trust enough to let AI write the code.

---

## Docker Setup

The fastest way to get identical environments across a Laravel team is **Laravel Sail** - Docker, but with the boilerplate already written.

### Why Docker / Sail

| Without Docker | With Docker / Sail |
|----------------|--------------------|
| Each dev installs PHP, MySQL, Redis manually | One `docker-compose.yml`, identical everywhere |
| Version drift between machines | Pinned versions for everyone |
| "Install these 6 things" onboarding | `git clone` + `sail up` |
| Dev environment ≠ CI ≠ production | Same image concept across all three |

### docker-compose Services

Sail publishes a `docker-compose.yml` describing the services the app needs. Pin every version to match production:

```yaml
services:
  app:
    image: sail-8.2/app          # PHP 8.2 - matches CI image php:8.2-cli
    ports:
      - '80:80'
    volumes:
      - '.:/var/www/html'
    depends_on:
      - mysql
      - redis

  mysql:
    image: mysql:8.0             # same major version as production
    environment:
      MYSQL_DATABASE: laravel
      MYSQL_ROOT_PASSWORD: password
    volumes:
      - sail-mysql:/var/lib/mysql

  redis:
    image: redis:alpine

volumes:
  sail-mysql:
```

### Daily Commands

```bash
./vendor/bin/sail up -d          # start the environment
./vendor/bin/sail artisan migrate
./vendor/bin/sail pest           # run the test suite inside the container
./vendor/bin/sail down           # stop it
```

> **Rule of thumb:** Pin the PHP version in Docker to the exact version in the CI image (`php:8.2-cli`, see [2.2 CI Pipeline](02-ci-pipeline.md)) and on the production server. One version, three places. A version mismatch is config drift wearing a disguise.

---

## Environment Parity (dev / staging / production)

Parity means the things that affect how code runs are the same everywhere. It does **not** mean the data or the secrets are the same - those differ by design.

### The Parity Matrix

| Concern | Dev (Sail) | CI | Staging | Production |
|---------|-----------|-----|---------|------------|
| PHP version | 8.2 | 8.2 | 8.2 | 8.2 |
| Database engine | MySQL 8.0 | SQLite *or* MySQL 8.0 | MySQL 8.0 | MySQL 8.0 |
| Cache / queue | Redis | array / sync | Redis | Redis |
| `APP_DEBUG` | `true` | `true` | `false` | `false` |
| `APP_ENV` | `local` | `testing` | `staging` | `production` |
| Secrets | local `.env` | committed `.env.testing` | secret store | secret store |

Versions match across every column. Only debug flags, environment names, secrets, and data differ - and those *should* differ.

### The SQLite-in-CI Decision

[2.2 CI Pipeline](02-ci-pipeline.md) uses SQLite in-memory for test speed, while production runs MySQL. That's a deliberate trade-off, and it has a cost: tests that rely on MySQL-specific behavior (JSON columns, full-text search, specific SQL syntax) can pass on SQLite and fail in production.

| Option | Parity | Speed | Use When |
|--------|--------|-------|----------|
| SQLite in CI | Lower | Fast | Tests avoid DB-specific SQL (default) |
| MySQL service in CI | Full | +30-60s startup | App relies on MySQL-specific features |

> **Recommendation:** Run MySQL locally in Sail regardless - your daily development should always be on the real engine. Keep SQLite in CI only as a speed trade-off, and switch CI to the MySQL service (shown in [2.2](02-ci-pipeline.md)) the first time a SQLite-vs-MySQL gap bites you.

### Building Real Parity

- **Same migrations everywhere** - never hand-edit a production schema. Schema changes flow through `php artisan migrate` only.
- **Cache config in production** - run `php artisan config:cache` on staging and production (it's in the deploy script from [1.6 Deployment](../phase1/06-deployment.md)). Dev leaves it uncached for fast iteration.
- **Match queue and cache drivers** - if production uses Redis, staging uses Redis. Testing the happy path on `sync`/`array` and shipping to Redis is a parity gap.

---

## Environment Variables

The environment is defined as much by `.env` as by Docker. Config drift usually hides in a `.env` value that's set on one server and missing on another.

### The Discipline

- **`.env.example` is the contract.** Every variable the app reads must exist in `.env.example` (with a safe placeholder). It's committed; it's the checklist for setting up any environment.
- **Real `.env` files are never committed.** `.env` (dev), staging, and production each have their own, kept out of Git.
- **`.env.testing` is the one exception** - it's committed *because* it contains no secrets (see [2.2 CI Pipeline](02-ci-pipeline.md)). That's the line: commit it only if leaking it costs nothing.
- **Production secrets live in a secret store**, not in a file a developer can copy to their laptop.

```bash
# When a new variable is added, it goes in two places:
.env              # real value (not committed)
.env.example      # placeholder (committed) - so no one's env is missing it
```

> **Rule of thumb:** If you add a key to `.env`, add it to `.env.example` in the same commit. A missing entry in `.env.example` is a production incident waiting for the next deploy.

---

## Checklist - Done When

- [ ] Laravel Sail (or equivalent Docker setup) runs the project with `sail up`
- [ ] Local PHP version matches the CI image and the production server (8.2)
- [ ] Local development runs against MySQL, not SQLite
- [ ] Cache and queue drivers match between staging and production (e.g. Redis)
- [ ] The parity matrix is documented and reviewed with the team
- [ ] `.env.example` lists every variable the app reads, with safe placeholders
- [ ] No real `.env` (dev/staging/prod) is committed; production secrets live in a secret store
- [ ] A new developer can go from `git clone` to a running app using only the README and Docker
