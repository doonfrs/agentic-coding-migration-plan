# 1.2 معايير Laravel

> فريق بدون معايير برمجية هو فريق يبدو فيه كل ملف كأنه كتبه شخص مختلف. الذكاء الاصطناعي يجعل هذا أسوأ — سيعكس أي تناقض يراه. اتفق على القواعد أولاً، ثم طبّقها تلقائياً.

---

## الأهداف

- تأسيس أسلوب كود واحد ومتسق عبر كامل المشروع
- أتمتة التطبيق حتى لا تعتمد المعايير على الانضباط الشخصي
- منح أدوات الذكاء الاصطناعي نمطاً متسقاً تتعلم منه وتولّد بناءً عليه
- تقليل العبء الذهني أثناء مراجعات الكود — الأسلوب ليس موضع جدل

---

## PSR-12 وأسلوب الكتابة

PSR-12 هو معيار مجتمع PHP لتنسيق الكود. Laravel يتبعه افتراضياً.

**القواعد الأساسية:**
- 4 مسافات للمسافة البادئة (بدون tabs)
- الأقواس الفتحية `{` على نفس سطر التعريف
- سطر فارغ واحد بين الدوال
- `declare(strict_types=1);` في بداية كل ملف PHP
- تلميحات الأنواع على جميع معاملات الدوال وأنواع الإرجاع

**لماذا يهم ذلك للذكاء الاصطناعي:**
> عندما يكون كودك متسقاً، ينتج الذكاء الاصطناعي كوداً متسقاً. عندما لا يكون كذلك، يخمّن — ويخطئ في نصف الأحيان.

---

## اتفاقيات تسمية Laravel

هذه اتفاقيات Laravel غير القابلة للتفاوض. الانحراف عنها يكسر ميزات الإطار ويربك المطورين والذكاء الاصطناعي على حد سواء.

| ما هو | الاتفاقية | مثال |
|-------|-----------|------|
| النماذج (Models) | مفرد، PascalCase | `User`، `OrderItem` |
| الكونترولرز | مفرد + `Controller` | `UserController`، `OrderController` |
| ملفات Migration | snake_case، وصفية | `create_users_table`، `add_status_to_orders_table` |
| المسارات | جمع، kebab-case | `/users`، `/order-items` |
| أسماء المسارات | نقطة فاصلة | `users.index`، `users.store` |
| واجهات Blade | snake_case | `user_profile.blade.php` |
| مفاتيح الإعداد | snake_case | `app.timezone`، `mail.default` |
| جداول قاعدة البيانات | جمع، snake_case | `users`، `order_items` |
| أعمدة قاعدة البيانات | snake_case | `first_name`، `created_at` |
| الدوال (Methods) | camelCase | `getUserOrders()`، `sendWelcomeEmail()` |
| المتغيرات | camelCase | `$userOrders`، `$totalAmount` |

---

## إعداد Laravel Pint

[Laravel Pint](https://laravel.com/docs/pint) هو أداة التنسيق الرسمية في Laravel. تطبّق PSR-12 تلقائياً — بلا جدال، بلا إصلاح يدوي.

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

**التطبيق عند كل commit** عبر pre-commit hook — انظر [1.3 اختيار الأدوات ← Pre-commit Hooks](03-tooling-selection.md#pre-commit-hooks) للإعداد الكامل بما في ذلك PHPStan والتثبيت التلقائي عبر composer.

---

## اتفاقيات الفريق

بعيداً عن التنسيق، اتفق على هذه الاتفاقيات الهيكلية كفريق:

### الكونترولرز — أبقِها نحيلة
الكونترولر يستقبل الطلب، يفوّض إلى خدمة أو action، ويُعيد الرد. هذا كل شيء.

```php
// ✅ كونترولر نحيل
public function store(StoreOrderRequest $request, CreateOrder $action): JsonResponse
{
    $order = $action->execute($request->validated());
    return response()->json($order, 201);
}

// ❌ كونترولر سمين — المنطق يجب أن يكون في مكان آخر
public function store(Request $request): JsonResponse
{
    $validated = $request->validate([...]);
    $order = Order::create($validated);
    Mail::to($order->user)->send(new OrderConfirmation($order));
    // 40 سطراً إضافياً...
}
```

### التحقق — استخدم Form Requests دائماً
لا تُحقق أبداً بشكل مضمّن داخل الكونترولر. أنشئ كلاس Form Request مخصصاً.

```bash
php artisan make:request StoreOrderRequest
```

### منطق الأعمال — Services أو Actions
ضع منطق المجال في `app/Services/` أو `app/Actions/` — أبداً في الكونترولرز أو النماذج.

### تجنب منطق الاستعلام في الكونترولرز
استخدم Eloquent scopes أو repositories. لا استعلامات `DB::select()` خام في الكونترولرز.

### لا أرقام سحرية أو نصوص مُشفّرة
استخدم الثوابت أو قيم الإعداد أو enums. `OrderStatus::PENDING` أفضل من `'pending'`.

---

## EditorConfig وإعدادات IDE

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

**لـ VS Code** — أضف `.vscode/settings.json` مشتركاً إلى المستودع:
```json
{
    "editor.formatOnSave": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.eol": "\n"
}
```

**لـ PhpStorm** — شارك إعداد أسلوب الكود عبر `.idea/codeStyles/` المُودَع في git.

---

## قائمة التحقق — اكتمل عند

- [ ] `pint.json` مُودَع في المستودع
- [ ] `.editorconfig` مُودَع في المستودع
- [ ] وثيقة اتفاقيات التسمية مشاركة مع الفريق
- [ ] الكود الموجود منسَّق بـ Pint (commit تنظيف واحد)
- [ ] أول PR مراجع وفق هذه المعايير
