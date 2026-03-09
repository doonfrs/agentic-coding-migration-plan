# 1.1 Codebase & Architecture Review

> Before writing a single line of new code — or prompting any AI — you must understand what you're working with. This review is about seeing the codebase honestly, not fixing it yet.

---

## Goals

- Get a clear picture of the current state: structure, patterns, and inconsistencies
- Identify areas that are safe to touch vs. areas that carry high risk
- Create a shared baseline document the whole team agrees on
- Prepare the ground for AI assistance — an agent needs context to be useful

---

## What to Review

### Folder Structure
- Does it follow Laravel conventions? (`app/`, `routes/`, `resources/`, etc.)
    - *Run `ls app/` — you should see `Models/`, `Http/`, `Providers/`. Anything else? Write it down.*
- Are there custom folders that deviate from the standard? Document them.
    - *e.g., `app/Helpers/`, `app/Libs/`, `app/Core/` — note what's in them and why they exist.*
- Is business logic scattered across controllers, or organized into services/repositories?
    - *Open any large controller. If it has DB queries and email sending and PDF generation — it's scattered.*

### Routing
- Are routes RESTful or arbitrary?
    - *Check `routes/web.php` and `routes/api.php`. RESTful = `GET /users`, `POST /users`, `DELETE /users/{id}`. Arbitrary = `GET /doSomethingWithUser`.*
- Are routes named consistently?
    - *Run `php artisan route:list` — scan the Name column. Are they all following a pattern like `users.index`, `users.store`?*
- Are there orphaned routes pointing to deleted controllers?
    - *Run `php artisan route:list` — any errors or missing controller references will show up.*

### Controllers
- Are controllers thin (delegating logic) or fat (containing everything)?
    - *A thin controller method is 5–15 lines. If a method is 50+ lines, it's fat.*
- Is there duplicated logic across multiple controllers?
    - *Search for copy-pasted blocks — same validation rules, same queries appearing in multiple places.*
- Are form validation rules inline or using Form Requests?
    - *Inline: `$request->validate([...])` inside the controller. Better: a dedicated `StoreUserRequest` class.*

### Models & Database
- Are Eloquent relationships defined and used correctly?
    - *Open a few Models — do they have `hasMany`, `belongsTo`, etc.? Or are joins being done manually in controllers?*
- Are there raw queries where Eloquent should be used?
    - *Search for `DB::statement`, `DB::select` with raw SQL strings — these are harder to maintain and test.*
- Is the database schema documented anywhere?
    - *Check for an ERD, a README, or even a comment. If nothing exists, it needs to be created.*
- Are migrations in sync with the actual DB, or has someone been editing the DB manually?
    - *Run `php artisan migrate:status` — any `Pending` migrations or missing entries are a red flag.*

### Dependencies
- Review `composer.json` — are all packages still used?
    - *Open `composer.json` and grep each package name in the codebase. If it appears nowhere, it may be dead weight.*
- Are there outdated or abandoned packages?
    - *Run `composer outdated` — focus on packages flagged as abandoned or with major version gaps.*
- Is the Laravel version still receiving security updates?
    - *Check [laravel.com/docs/releases](https://laravel.com/docs/releases) — versions older than the last two major releases are out of support.*

### Configuration & Environment
- Is sensitive data hardcoded anywhere (credentials, API keys)?
    - *Search for strings like `password`, `secret`, `api_key` in `.php` files outside of config. Any hits = immediate risk.*
- Is `.env` properly gitignored?
    - *Run `git ls-files .env` — if it returns anything, the file is tracked in git. That's a security issue.*
- Are there environment-specific hacks in the code?
    - *Search for `if (env('APP_ENV') === 'production')` inside business logic — these are fragile and hard to test.*

### Code Quality Signals
- Is there commented-out code left in place?
    - *A few lines is normal. Pages of commented code = the team is afraid to delete things = no version control confidence.*
- Are there `dd()`, `var_dump()`, or debug statements in the codebase?
    - *Run `grep -r "dd(" app/` — any results in production code should be removed immediately.*
- Is error handling present, or are exceptions swallowed silently?
    - *Search for empty `catch` blocks: `catch (\Exception $e) {}` with nothing inside = silent failures.*

---

## AI-Safe vs. AI-Restricted Areas

As part of this review, map every major area of the codebase by the level of review the AI output requires:

| Area | Review Level | What it means |
|------|-------------|---------------|
| Boilerplate CRUD | 🟢 Quick Review | Skim it, run the tests, merge |
| Blade views / UI | 🟢 Quick Review | Check it visually in the browser |
| Test generation | 🟢 Quick Review | Read the assertions, run the suite |
| Documentation | 🟢 Quick Review | Read for accuracy, merge |
| API integrations (3rd party) | 🟡 Standard Review | Verify input/output contracts and error handling |
| Business rules / core logic | 🟡 Standard Review | Developer must understand and own the logic |
| Authentication & Authorization | 🔴 Senior Review | Line-by-line — a wrong assumption here is a security hole |
| Payment / financial logic | 🔴 Senior Review | Every edge case matters — test thoroughly on staging |
| Database migrations | 🔴 Senior Review | Run on a copy of production data first, no exceptions |

---

## Output / Deliverables

By the end of this review, produce a single shared document containing:

1. **Architecture Map** — a plain-text or diagram overview of how the app is structured
2. **Pain Points List** — concrete issues found (e.g., "UserController has 800 lines", "no migrations for the `orders` table")
3. **AI Scope Map** — the table above, filled in for this specific project
4. **Risk Register** — the 3–5 areas most likely to cause problems during the migration
5. **Open Questions** — things that need clarification from the team before proceeding

---

## How to Conduct the Review

- Do it as a team session (not solo) — shared understanding is the goal
- Use the codebase as-is, don't refactor during the review
- Time-box it: 1–2 focused sessions, not an endless audit
- Output the deliverables in a shared document everyone can access and annotate
