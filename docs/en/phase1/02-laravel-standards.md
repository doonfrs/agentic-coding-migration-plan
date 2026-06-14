# 1.2 Laravel Standards

> A team without coding standards is a team where every file looks like it was written by a different person. AI makes this worse - it will mirror whatever inconsistency it sees. Agree on the rules first, then enforce them automatically.

---

## Goals

- Establish a single, consistent coding style across the entire codebase
- Automate enforcement so standards don't depend on discipline
- Give AI tools a consistent pattern to learn from and generate against
- Reduce cognitive overhead during code reviews - style is not a debate

---

## PSR-12 & Coding Style

PSR-12 is the PHP community standard for code formatting. Laravel follows it by default.

**Key rules:**
- 4 spaces for indentation (no tabs)
- Opening braces `{` on the same line as the declaration
- One blank line between methods
- `declare(strict_types=1);` at the top of every PHP file
- Type hints on all method parameters and return types

**Why it matters for AI:**
> When your codebase is consistent, the AI generates consistent code. When it's not, the AI guesses - and guesses wrong half the time.

---

## Laravel Naming Conventions

These are non-negotiable Laravel conventions. Deviating from them breaks framework features and confuses both developers and AI assistants.

| What | Convention | Example |
|------|-----------|---------|
| Models | Singular, PascalCase | `User`, `OrderItem` |
| Controllers | Singular + `Controller` | `UserController`, `OrderController` |
| Migrations | Snake_case, descriptive | `create_users_table`, `add_status_to_orders_table` |
| Routes | Plural, kebab-case | `/users`, `/order-items` |
| Route names | Dot notation | `users.index`, `users.store` |
| Blade views | Snake_case | `user_profile.blade.php` |
| Config keys | Snake_case | `app.timezone`, `mail.default` |
| Database tables | Plural, snake_case | `users`, `order_items` |
| Database columns | Snake_case | `first_name`, `created_at` |
| Methods | camelCase | `getUserOrders()`, `sendWelcomeEmail()` |
| Variables | camelCase | `$userOrders`, `$totalAmount` |

---

## Laravel Pint Setup

[Laravel Pint](https://laravel.com/docs/pint) is the official Laravel code formatter. It enforces PSR-12 automatically - no arguments, no manual fixing.

**Install:**
```bash
composer require laravel/pint --dev
```

**Run manually:**
```bash
./vendor/bin/pint
```

**Check without fixing (CI-friendly):**
```bash
./vendor/bin/pint --test
```

**Configure** `pint.json` in the project root:
```json
{
    "preset": "laravel",
    "rules": {
        "declare_strict_types": true,
        "ordered_imports": true,
        "no_unused_imports": true
    }
}
```

**Enforce on every commit** via a pre-commit hook - see [1.3 Tooling Selection → Pre-commit Hooks](03-tooling-selection.md#pre-commit-hooks) for the full setup including PHPStan and auto-install via composer.

---

## Team Conventions

Beyond formatting, agree on these structural conventions as a team:

### Controllers - Keep Them Thin
Controllers receive a request, delegate to a service or action, and return a response. That's it.

```php
// ✅ Thin controller
public function store(StoreOrderRequest $request, CreateOrder $action): JsonResponse
{
    $order = $action->execute($request->validated());
    return response()->json($order, 201);
}

// ❌ Fat controller - logic belongs elsewhere
public function store(Request $request): JsonResponse
{
    $validated = $request->validate([...]);
    $order = Order::create($validated);
    Mail::to($order->user)->send(new OrderConfirmation($order));
    // 40 more lines...
}
```

### Validation - Always Use Form Requests
Never validate inline inside a controller. Create a dedicated Form Request class.

```bash
php artisan make:request StoreOrderRequest
```

### Business Logic - Services or Actions
Place domain logic in `app/Services/` or `app/Actions/` - never in controllers or models.

### Avoid Query Logic in Controllers
Use Eloquent scopes or repositories. No raw `DB::select()` queries in controllers.

### No Magic Numbers or Hardcoded Strings
Use constants, config values, or enums. `OrderStatus::PENDING` is better than `'pending'`.

---

## EditorConfig & IDE Settings

Add a `.editorconfig` file to the repo root to enforce consistent formatting across all editors:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

**For VS Code** - add a shared `.vscode/settings.json` to the repo:
```json
{
    "editor.formatOnSave": false,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.eol": "\n",
    "[php]": {
        "editor.defaultFormatter": "open-in-browser.default"
    }
}
```

**For PhpStorm** - share the code style config via `.idea/codeStyles/` committed to git.

---

## Checklist - Done When

- [ ] `pint.json` committed to the repo
- [ ] `.editorconfig` committed to the repo
- [ ] Naming convention doc shared with the team
- [ ] Existing codebase formatted with Pint (one-time cleanup commit)
- [ ] First PR reviewed against these standards
