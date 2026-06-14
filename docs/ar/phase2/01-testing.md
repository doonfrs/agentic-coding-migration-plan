# 2.1 الاختبارات

> الذكاء الاصطناعي يكتب الكود أسرع بعشر مرات من المطور - لكنه لا يعرف إذا كان الكود يعمل فعلاً. الاختبارات هي الشيء الوحيد الذي يقف بين كود الذكاء الاصطناعي وأخطاء الإنتاج. بدونها، السرعة هي مجرد طريقة أسرع لكسر الأشياء.

---

## الأهداف

- تثبيت وإعداد Pest كـ testing framework أساسي
- تحقيق smoke test coverage على جميع الـ routes الموجودة (بدون أخطاء 500)
- كتابة feature tests لأهم 5 business flows حرجة
- وضع coverage policy واقعية للكود القديم والجديد
- بناء شبكة الأمان التي تجعل AI-assisted coding ممكناً في Phase 3

---

## لماذا الاختبارات قبل الذكاء الاصطناعي

الذكاء الاصطناعي يولّد كوداً يبدو صحيحاً، لكنه ليس بالضرورة صحيحاً. سيكتب function تبدو سليمة، تمر بمراجعة بصرية سريعة، ثم تنكسر بصمت على حالة حدّية لم يفكر فيها الذكاء الاصطناعي أبداً.

بدون اختبارات، الطريقة الوحيدة للتحقق هي QA اليدوي - النقر في التطبيق، فحص الصفحات، مراقبة البيانات بالعين. هذا لا يتوسع عندما ينتج الذكاء الاصطناعي كوداً بعشرة أضعاف سرعة المطور.

الاختبارات تخلق **contract**. المطور يحدد السلوك المتوقع؛ والكود (سواء كتبه إنسان أو ذكاء اصطناعي) يجب أن يحققه. إذا نجح الاختبار، السلوك صحيح. إذا فشل، الكود خاطئ - بغض النظر عمن كتبه.

في Phase 3، سيشغّل AI agent الـ test suite بعد كل تعديل تلقائياً. لكن أولاً، الاختبارات يجب أن تكون موجودة. هذا ما تقدمه هذه المرحلة.

---

## PHPUnit / Pest Setup

### لماذا Pest

| الجانب | PHPUnit | Pest |
|--------|---------|------|
| الصيغة | مطوّلة، class-based | تعبيرية، closure-based |
| منحنى التعلم | أصعب | سلس |
| التوافق مع AI | جيد | ممتاز - boilerplate أقل لتوليد الذكاء الاصطناعي |
| التكامل مع Laravel | مدمج | first-class عبر `pestphp/pest-plugin-laravel` |

**التوصية:** استخدم Pest. ينتج output أنظف، يتطلب boilerplate أقل، والذكاء الاصطناعي ينتج اختبارات Pest أفضل لأن الصيغة أكثر إيجازاً.

### التثبيت

```bash
composer require pestphp/pest --dev --with-all-dependencies
composer require pestphp/pest-plugin-laravel --dev
./vendor/bin/pest --init
```

### الإعداد

حدّث `phpunit.xml` لاستخدام test database مخصصة:

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

أعدّ الـ base test case في `tests/Pest.php`:

```php
<?php

uses(Tests\TestCase::class)->in('Feature');
uses(Tests\TestCase::class)->in('Unit');
```

### تشغيل الاختبارات

```bash
./vendor/bin/pest                    # تشغيل جميع الاختبارات
./vendor/bin/pest --filter=UserTest  # تشغيل اختبار محدد
./vendor/bin/pest --parallel         # تشغيل بالتوازي (أسرع)
./vendor/bin/pest --coverage         # تشغيل مع تقرير التغطية
```

---

## استراتيجية الاختبار - من أين تبدأ

في مشروع جديد، تبدأ بـ unit tests وتبني للأعلى. في كود قديم بدون اختبارات، افعل العكس - ابدأ بشكل واسع، ثم اتجه للعمق.

### هرم الاختبار للكود القديم

```
    ┌─────────────┐
    │  Unit Tests  │  ← أضفها أخيراً (للكود الجديد فقط)
    ├─────────────┤
    │Feature Tests │  ← أضفها ثانياً (المسارات الحرجة)
    ├─────────────┤
    │ Smoke Tests  │  ← أضفها أولاً (شبكة أمان واسعة)
    └─────────────┘
```

لا تحاول كتابة unit tests لكود قديم لم يُصمَّم لذلك. ابدأ بـ smoke tests (تلتقط أخطاء 500 عبر التطبيق)، ثم اكتب feature tests للمسارات الحرجة (تتحقق من السلوك)، ثم أضف unit tests فقط للـ logic الجديد المعزول.

### ترتيب الأولويات

| الأولوية | النوع | ما يلتقطه | الجهد |
|----------|-------|-----------|-------|
| 🟢 الأول | Smoke tests | Routes معطّلة، أخطاء 500، middleware مفقود | منخفض |
| 🟡 الثاني | Feature tests | Business logic خاطئ، flows معطّلة | متوسط |
| 🔴 الثالث | Unit tests | حالات حدّية في logic معزول | مرتفع (للكود القديم) |

---

## Smoke Tests

الـ smoke test يضرب كل route في التطبيق ويتأكد أنه لا يعيد خطأ 500. لا يتحقق من الـ business logic - فقط أن الصفحة تُحمَّل.

### الـ Routes العامة

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

### الـ Routes المحمية

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

### ما لا تلتقطه الـ Smoke Tests

- Routes بمعاملات مطلوبة (تحتاج feature tests مخصصة)
- POST/PUT/DELETE routes (تحتاج feature tests بـ payloads)
- أخطاء business logic (response 200 ببيانات خاطئة)

---

## الاختبارات الوظيفية

ركّز على المال، والمصادقة، وسلامة البيانات - المناطق التي تسبب فيها الأخطاء ضرراً حقيقياً.

### ماذا تختبر أولاً

1. تسجيل المستخدم وتسجيل الدخول
2. عمليات CRUD الأساسية (الكيان الرئيسي في النظام)
3. عمليات الدفع والفوترة
4. تصدير / استيراد البيانات
5. العمليات الحساسة للصلاحيات

### مثال: اختبار API Endpoint

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

### مثال: اختبار Validation

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

### مثال: اختبار Auth / Permission

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

## الاختبارات الوحدوية

الـ unit tests للـ logic المعزول والحتمي بدون database أو HTTP.

### متى تكتبها

- Service classes بـ business logic صرف
- Action classes
- Value objects
- Helper / utility functions
- Calculation methods

### مثال: Unit Test لـ Service

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

### لا تكتب Unit Tests لهذه (في الكود القديم)

- Eloquent models (اختبرها عبر feature tests)
- Controllers (اختبرها عبر feature tests)
- Blade views (اختبرها عبر smoke / feature tests)
- Third-party packages

---

## سياسة التغطية

### الأهداف

| فئة الكود | الهدف | المبرر |
|-----------|-------|--------|
| الكود الجديد (Phase 2+) | 80% | كل كود جديد يجب أن يكون له اختبارات |
| المسارات الحرجة (الموجودة) | Feature tests مطلوبة | Auth، المدفوعات، CRUD الأساسي |
| الكود القديم الموجود | Smoke coverage فقط | لا تكتب unit tests بأثر رجعي للكود القديم |
| الكود المُولَّد بالذكاء الاصطناعي | 100% من الأسطر المعدّلة | الذكاء الاصطناعي يكتب الكود → الاختبارات تتحقق منه |

### تطبيق Coverage

```bash
./vendor/bin/pest --coverage --min=60
```

أضفها إلى CI pipeline - انظر [2.2 CI Pipeline](02-ci-pipeline.md).

### ما يجب فعله وما يجب تجنّبه

- ❌ لا تسعَ لتغطية 100% على الكود القديم - مضيعة للوقت بعوائد متناقصة
- ❌ لا تكتب اختبارات لـ getters/setters أو كود بديهي
- ❌ لا تختبر framework internals (Laravel يختبرها بالفعل)
- ✅ ركّز التغطية على المسارات الحرجة للـ business
- ✅ اطلب اختبارات لكل feature جديدة وكل bug fix

---

## الاختبارات + سير عمل الذكاء الاصطناعي

### كيف تمكّن الاختبارات كتابة كود آمن بالذكاء الاصطناعي

```
المطور يكتب اختبار  →  AI يكتب التطبيق  →  الاختبارات نجحت؟  →  Merge
المطور يصف الميزة  →  AI يكتب كود + اختبارات  →  الإنسان يراجع الاختبارات  →  Merge
بلاغ عن خطأ  →  المطور يكتب اختبار فاشل  →  AI يصلح الكود  →  الاختبار نجح  →  Merge
```

### سير عمل Red-Green مع الذكاء الاصطناعي

1. **الإنسان يكتب اختبار فاشل** يصف السلوك المتوقع
2. **الذكاء الاصطناعي يكتب التطبيق** لجعل الاختبار ينجح
3. **الإنسان يراجع** كلاً من assertions الاختبار وكود الذكاء الاصطناعي
4. **CI يشغّل جميع الاختبارات** للتحقق من عدم وجود regressions

هذا هو سير العمل الأساسي لـ Phase 3 (agentic coding). انظر [2.4 Supervised AI Introduction](04-supervised-ai.md) لخطة الانتقال.

### الذكاء الاصطناعي يكتب الاختبارات

الذكاء الاصطناعي يمكنه أيضاً كتابة الاختبارات - لكن يجب على الإنسان مراجعة الـ assertions:

- ✅ الذكاء الاصطناعي جيد في: توليد هيكل الاختبار، الـ boilerplate، حالات الحدود
- ❌ الذكاء الاصطناعي ضعيف في: معرفة ما هو السلوك الصحيح للـ business
- القاعدة: **لا تدمج اختبارات كتبها الذكاء الاصطناعي بدون قراءة كل assertion**

---

## قائمة التحقق - اكتمل عند

- [ ] Pest مثبّت ومُعدّ (`composer.json`، `Pest.php`، `phpunit.xml`)
- [ ] Smoke test يغطي جميع GET routes - صفر أخطاء 500
- [ ] Feature tests مكتوبة لأهم 5 business flows حرجة
- [ ] على الأقل unit test واحد موجود لـ service أو action class
- [ ] Coverage report يعمل محلياً: `./vendor/bin/pest --coverage`
- [ ] Coverage minimum محدد (60% إجمالي، 80% للكود الجديد)
- [ ] الفريق شغّل الـ test suite ويفهم كيف يكتب اختبار جديد
- [ ] Test database مُعدّ (SQLite in-memory أو DB مخصصة)
- [ ] CI pipeline مُعدّ لتشغيل الاختبارات على كل PR - انظر [2.2 CI Pipeline](02-ci-pipeline.md)
