# 1.2 Laravel Standards

> فريق بدون coding standards هو فريق يبدو فيه كل ملف كأنه كتبه شخص مختلف. الذكاء الاصطناعي يجعل هذا أسوأ - سيعكس أي تناقض يراه. اتفق على القواعد أولاً، ثم طبّقها تلقائياً.

---

## الأهداف

- تأسيس coding style واحد ومتسق عبر كامل الـ codebase
- أتمتة التطبيق حتى لا تعتمد المعايير على الانضباط الشخصي
- منح أدوات الذكاء الاصطناعي نمطاً متسقاً تتعلم منه وتولّد بناءً عليه
- تقليل العبء الذهني أثناء code reviews - الـ style ليس موضع جدل

---

## PSR-12 & Coding Style

PSR-12 هو معيار مجتمع PHP لتنسيق الكود. Laravel يتبعه افتراضياً.

**القواعد الأساسية:**
- 4 spaces للمسافة البادئة (بدون tabs)
- الأقواس الفتحية `{` على نفس سطر الـ declaration
- سطر فارغ واحد بين الـ methods
- `declare(strict_types=1);` في بداية كل ملف PHP
- Type hints على جميع معاملات الـ methods وأنواع الـ return

**لماذا يهم ذلك للذكاء الاصطناعي:**
> عندما يكون الـ codebase متسقاً، ينتج الذكاء الاصطناعي كوداً متسقاً. عندما لا يكون كذلك، يخمّن - ويخطئ في نصف الأحيان.

---

## Laravel Naming Conventions

هذه اتفاقيات Laravel غير القابلة للتفاوض. الانحراف عنها يكسر features في الـ framework ويربك المطورين والذكاء الاصطناعي على حد سواء.

| ما هو | الاتفاقية | مثال |
|-------|-----------|------|
| Models | Singular, PascalCase | `User`، `OrderItem` |
| Controllers | Singular + `Controller` | `UserController`، `OrderController` |
| Migrations | snake_case، وصفية | `create_users_table`، `add_status_to_orders_table` |
| Routes | Plural, kebab-case | `/users`، `/order-items` |
| Route names | Dot notation | `users.index`، `users.store` |
| Blade views | snake_case | `user_profile.blade.php` |
| Config keys | snake_case | `app.timezone`، `mail.default` |
| Database tables | Plural, snake_case | `users`، `order_items` |
| Database columns | snake_case | `first_name`، `created_at` |
| Methods | camelCase | `getUserOrders()`، `sendWelcomeEmail()` |
| Variables | camelCase | `$userOrders`، `$totalAmount` |

---

## Laravel Pint Setup

[Laravel Pint](https://laravel.com/docs/pint) هو الـ code formatter الرسمي في Laravel. يطبّق PSR-12 تلقائياً - بلا جدال، بلا إصلاح يدوي.

**التثبيت:**
```bash
composer require laravel/pint --dev
```

**التشغيل اليدوي:**
```bash
./vendor/bin/pint
```

**الفحص بدون إصلاح (مناسب للـ CI):**
```bash
./vendor/bin/pint --test
```

**الإعداد** عبر `pint.json` في مجلد المشروع:
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

**التطبيق عند كل commit** عبر pre-commit hook - انظر [1.3 Tooling Selection → Pre-commit Hooks](03-tooling-selection.md#pre-commit-hooks) للإعداد الكامل بما في ذلك PHPStan والتثبيت التلقائي عبر composer.

---

## Team Conventions

بعيداً عن التنسيق، اتفق على هذه الاتفاقيات الهيكلية كفريق:

### Controllers - Keep Them Thin
الـ controller يستقبل الـ request، يفوّض إلى service أو action، ويُعيد الـ response. هذا كل شيء.

```php
// ✅ Thin controller
public function store(StoreOrderRequest $request, CreateOrder $action): JsonResponse
{
    $order = $action->execute($request->validated());
    return response()->json($order, 201);
}

// ❌ Fat controller - المنطق يجب أن يكون في مكان آخر
public function store(Request $request): JsonResponse
{
    $validated = $request->validate([...]);
    $order = Order::create($validated);
    Mail::to($order->user)->send(new OrderConfirmation($order));
    // 40 سطراً إضافياً...
}
```

### Validation - استخدم Form Requests دائماً
لا تُحقق أبداً inline داخل الـ controller. أنشئ dedicated Form Request class.

```bash
php artisan make:request StoreOrderRequest
```

### Business Logic - Services أو Actions
ضع domain logic في `app/Services/` أو `app/Actions/` - أبداً في الـ controllers أو الـ models.

### لا Query Logic في الـ Controllers
استخدم Eloquent scopes أو repositories. لا `DB::select()` raw queries في الـ controllers.

### لا Magic Numbers أو Hardcoded Strings
استخدم constants أو config values أو enums. `OrderStatus::PENDING` أفضل من `'pending'`.

---

## EditorConfig & IDE Settings

أضف ملف `.editorconfig` إلى مجلد المشروع لتطبيق تنسيق متسق عبر جميع المحررات:

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

**لـ VS Code** - أضف `.vscode/settings.json` مشتركاً إلى الـ repository:
```json
{
    "editor.formatOnSave": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.eol": "\n"
}
```

**لـ PhpStorm** - شارك الـ code style config عبر `.idea/codeStyles/` مُودَع في git.

---

## Checklist - Done When

- [ ] `pint.json` مُودَع في الـ repository
- [ ] `.editorconfig` مُودَع في الـ repository
- [ ] Naming conventions doc مشاركة مع الفريق
- [ ] الـ codebase الموجود منسَّق بـ Pint (one-time cleanup commit)
- [ ] أول PR مراجع وفق هذه المعايير
