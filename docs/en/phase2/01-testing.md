# 2.1 Testing

> AI writes code 10x faster than a developer — but it has no idea if the code actually works. Tests are the only thing standing between AI-generated code and production bugs. Without them, speed is just a faster way to break things.

---

## Goals

- Install and configure Pest as the primary testing framework
- Achieve smoke-test coverage on all existing routes (no 500s)
- Write feature tests for the top 5 critical business flows
- Establish a realistic coverage policy for legacy and new code
- Build the safety net that makes AI-assisted coding possible in Phase 3

---

## Why Testing Before AI

AI generates plausible code, not correct code. It will write a function that looks right, passes a quick visual scan, and breaks silently on an edge case the AI never considered.

Without tests, the only verification is manual QA — clicking through the app, checking pages, eyeballing data. That doesn't scale when AI is producing code at 10x the rate a developer does.

Tests create a **contract**. The developer defines the expected behavior; the code (whether written by a human or AI) must satisfy it. If the test passes, the behavior is correct. If it fails, the code is wrong — regardless of who or what wrote it.

In Phase 3, the AI agent will run the test suite after every code change automatically. But first, the tests need to exist. That's what this phase delivers.

---

## PHPUnit / Pest Setup

### Why Pest

| Aspect | PHPUnit | Pest |
|--------|---------|------|
| Syntax | Verbose, class-based | Expressive, closure-based |
| Learning curve | Steeper | Gentle |
| AI compatibility | Good | Excellent — less boilerplate for AI to generate |
| Laravel integration | Built-in | First-class via `pestphp/pest-plugin-laravel` |

**Recommendation:** Use Pest. It generates cleaner output, requires less boilerplate, and AI assistants produce better Pest tests because the syntax is more concise.

### Installation

```bash
composer require pestphp/pest --dev --with-all-dependencies
composer require pestphp/pest-plugin-laravel --dev
./vendor/bin/pest --init
```

### Configuration

Update `phpunit.xml` to use a dedicated test database:

```xml
<env name="APP_ENV" value="testing"/>
<env name="DB_CONNECTION" value="sqlite"/>
<env name="DB_DATABASE" value=":memory:"/>
<env name="BCRYPT_ROUNDS" value="4"/>
<env name="CACHE_STORE" value="array"/>
<env name="MAIL_MAILER" value="array"/>
<env name="QUEUE_CONNECTION" value="sync"/>
<env name="SESSION_DRIVER" value="array"/>
```

Set up the base test case in `tests/Pest.php`:

```php
<?php

uses(Tests\TestCase::class)->in('Feature');
uses(Tests\TestCase::class)->in('Unit');
```

### Running Tests

```bash
./vendor/bin/pest                    # Run all tests
./vendor/bin/pest --filter=UserTest  # Run specific test
./vendor/bin/pest --parallel         # Run in parallel (faster)
./vendor/bin/pest --coverage         # Run with coverage report
```

---

## Testing Strategy — Where to Start

In a greenfield project, you'd start with unit tests and build up. In legacy code with zero tests, do the opposite — start broad, then go deep.

### The Legacy Testing Pyramid

```
    ┌─────────────┐
    │  Unit Tests  │  ← Add last (for new code only)
    ├─────────────┤
    │Feature Tests │  ← Add second (critical flows)
    ├─────────────┤
    │ Smoke Tests  │  ← Add FIRST (broad safety net)
    └─────────────┘
```

Don't try to unit-test legacy code that wasn't designed for it. Start with smoke tests (catch 500 errors across the app), then write feature tests for critical flows (verify behavior), then add unit tests only for new isolated logic.

### Priority Order

| Priority | Type | What It Catches | Effort |
|----------|------|----------------|--------|
| 🟢 1st | Smoke tests | Broken routes, 500 errors, missing middleware | Low |
| 🟡 2nd | Feature tests | Wrong business logic, broken flows | Medium |
| 🔴 3rd | Unit tests | Edge cases in isolated logic | High (for legacy) |

---

## Smoke Tests

A smoke test hits every route in the application and asserts it doesn't return a 500 error. It doesn't check business logic — just that the page loads.

### Public Routes

```php
// tests/Feature/SmokeTest.php

use Illuminate\Support\Facades\Route;

it('returns a successful response for all public GET routes', function () {
    $routes = collect(Route::getRoutes())
        ->filter(fn ($route) => in_array('GET', $route->methods()))
        ->filter(fn ($route) => !str_starts_with($route->uri(), '_'))
        ->reject(fn ($route) => collect($route->middleware())->contains('auth'));

    foreach ($routes as $route) {
        $uri = $route->uri();

        // Skip routes with parameters for now
        if (str_contains($uri, '{')) {
            continue;
        }

        $response = $this->get($uri);

        expect($response->status())
            ->not->toBe(500, "Route GET /{$uri} returned 500");
    }
});
```

### Authenticated Routes

```php
it('returns a successful response for authenticated GET routes', function () {
    $user = User::factory()->create();

    $routes = collect(Route::getRoutes())
        ->filter(fn ($route) => in_array('GET', $route->methods()))
        ->filter(fn ($route) => collect($route->middleware())->contains('auth'));

    foreach ($routes as $route) {
        $uri = $route->uri();
        if (str_contains($uri, '{')) continue;

        $response = $this->actingAs($user)->get($uri);

        expect($response->status())
            ->not->toBe(500, "Auth route GET /{$uri} returned 500");
    }
});
```

### What Smoke Tests Won't Catch

- Routes with required parameters (need dedicated feature tests)
- POST/PUT/DELETE routes (need feature tests with payloads)
- Business logic errors (200 response with wrong data)

---

## Feature Tests

Focus on money, auth, and data integrity — the areas where bugs cause real damage.

### What to Test First

1. User registration and login
2. Core CRUD operations (the main entity in the system)
3. Payment / billing flows
4. Data export / import
5. Permission-sensitive operations

### Example: API Endpoint Test

```php
it('creates an order with valid data', function () {
    $user = User::factory()->create();
    $product = Product::factory()->create(['price' => 1000]);

    $response = $this->actingAs($user)
        ->postJson('/api/orders', [
            'product_id' => $product->id,
            'quantity' => 2,
        ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'data' => ['id', 'total', 'status'],
        ]);

    expect($response->json('data.total'))->toBe(2000);
    $this->assertDatabaseHas('orders', [
        'user_id' => $user->id,
        'total' => 2000,
    ]);
});
```

### Example: Validation Test

```php
it('rejects an order with missing product_id', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)
        ->postJson('/api/orders', [
            'quantity' => 2,
        ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['product_id']);
});
```

### Example: Auth / Permission Test

```php
it('prevents non-admin from deleting users', function () {
    $regularUser = User::factory()->create();
    $targetUser = User::factory()->create();

    $response = $this->actingAs($regularUser)
        ->deleteJson("/api/users/{$targetUser->id}");

    $response->assertStatus(403);
    $this->assertDatabaseHas('users', ['id' => $targetUser->id]);
});
```

---

## Unit Tests

Unit tests are for isolated, deterministic logic with no database or HTTP involved.

### When to Write Them

- Service classes with pure business logic
- Action classes
- Value objects
- Helper / utility functions
- Calculation methods

### Example: Service Unit Test

```php
// tests/Unit/Services/PricingServiceTest.php

it('calculates discount correctly', function () {
    $service = new PricingService();

    expect($service->applyDiscount(1000, 15))->toBe(850);
    expect($service->applyDiscount(500, 0))->toBe(500);
    expect($service->applyDiscount(200, 100))->toBe(0);
});

it('throws exception for negative discount', function () {
    $service = new PricingService();

    expect(fn () => $service->applyDiscount(1000, -5))
        ->toThrow(InvalidArgumentException::class);
});
```

### Don't Unit Test These (in legacy code)

- Eloquent models (test through feature tests)
- Controllers (test through feature tests)
- Blade views (test through smoke / feature tests)
- Third-party packages

---

## Coverage Policy

### Targets

| Code Category | Target | Rationale |
|--------------|--------|-----------|
| New code (Phase 2+) | 80% | All new code must have tests |
| Critical paths (existing) | Feature tests required | Auth, payments, core CRUD |
| Existing legacy code | Smoke coverage only | Don't retroactively unit-test legacy |
| AI-generated code | 100% of changed lines | AI writes code → tests verify it |

### Enforcing Coverage

```bash
./vendor/bin/pest --coverage --min=60
```

Add to CI pipeline — see [2.2 CI Pipeline](02-ci-pipeline.md).

### What to Do and What to Avoid

- ❌ Don't chase 100% coverage on legacy code — it's a time sink with diminishing returns
- ❌ Don't write tests for getters/setters or trivial code
- ❌ Don't test framework internals (Laravel already tests those)
- ✅ Focus coverage on business-critical paths
- ✅ Require tests for every new feature and every bug fix

---

## Testing + AI Workflow

### How Tests Enable Safe AI Coding

```
Developer writes test  →  AI writes implementation  →  Tests pass?  →  Merge
Developer describes feature  →  AI writes code + tests  →  Human reviews tests  →  Merge
Bug reported  →  Developer writes failing test  →  AI fixes code  →  Test passes  →  Merge
```

### The Red-Green Workflow with AI

1. **Human writes a failing test** that describes the expected behavior
2. **AI writes the implementation** to make the test pass
3. **Human reviews** both the test assertions and the AI's code
4. **CI runs all tests** to verify no regressions

This is the core workflow for Phase 3 (agentic coding). See [2.4 Supervised AI Introduction](04-supervised-ai.md) for the transition plan.

### AI Writing Tests

AI can also write tests — but the human must review the assertions:

- ✅ AI is good at: generating test structure, boilerplate, edge cases
- ❌ AI is bad at: knowing what the correct business behavior should be
- Rule: **Never merge AI-written tests without reading every assertion**

---

## Checklist — Done When

- [ ] Pest installed and configured (`composer.json`, `Pest.php`, `phpunit.xml`)
- [ ] Smoke test covers all GET routes — zero 500 errors
- [ ] Feature tests written for top 5 critical business flows
- [ ] At least one unit test exists for a service or action class
- [ ] Coverage report runs locally: `./vendor/bin/pest --coverage`
- [ ] Coverage minimum set (60% overall, 80% for new code)
- [ ] Team has run the test suite and understands how to write a new test
- [ ] Test database configured (SQLite in-memory or dedicated DB)
- [ ] CI pipeline configured to run tests on every PR — see [2.2 CI Pipeline](02-ci-pipeline.md)
