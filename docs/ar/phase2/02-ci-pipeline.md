# 2.2 مسار CI

> الـ pre-commit hook يلتقط الأخطاء على جهاز المطور. مسار CI يلتقطها في كل مكان آخر - بما في ذلك على جهاز الـ AI agent. إذا لم يعمل الـ pipeline تلقائياً على كل PR، لا توجد شبكة أمان.

---

## الأهداف

- إعداد Bitbucket Pipelines للعمل تلقائياً على كل pull request
- فرض code style (Pint)، وstatic analysis (PHPStan)، والاختبارات (Pest) في CI
- منع الدمج عند فشل أي فحص - بدون استثناءات
- إنشاء coverage gate يمنع التراجع في التغطية
- بناء حلقة التغذية الراجعة الآلية التي تجعل AI-assisted coding آمناً في Phase 3
- إبقاء وقت تنفيذ الـ pipeline أقل من 5 دقائق لتجنب إبطاء الفريق

---

## لماذا CI قبل الذكاء الاصطناعي

الـ pre-commit hooks (التي أُعدّت في [1.3 الأدوات](../phase1/03-tooling-selection.md)) تعمل على جهاز المطور المحلي. تعمل - حتى لا تعمل:

- مطور يتجاوزها (`--no-verify`)
- عضو جديد في الفريق لم يشغّل `composer install` بعد
- الـ AI agent ينشئ branch ويدفع مباشرة
- شخص يعمل commit من جهاز بدون الـ hooks مثبّتة

CI هو الجدار الثاني. يعمل في بيئة نظيفة، كل مرة، على كل PR. لا أحد يستطيع تجاوزه. لا أحد يستطيع نسيانه. الـ pipeline لا يهتم من كتب الكود - إنسان أو ذكاء اصطناعي. يفحص كل شيء بنفس الطريقة.

في Phase 3، سيدفع الـ AI agent الكود، ويفتح PRs، ويعدّل بناءً على ملاحظات CI. إذا لم يكن الـ pipeline جاهزاً قبل ذلك، فأنت تعطي الذكاء الاصطناعي صلاحية commit بدون حواجز أمان.

**القاعدة بسيطة:** لا شيء يُدمج في `main` إلا إذا نجح الـ pipeline. لا للبشر، ولا للذكاء الاصطناعي.

---

## إعداد Bitbucket Pipelines

### الإعداد الأساسي

أنشئ `bitbucket-pipelines.yml` في جذر المشروع:

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

### ماذا يفعل هذا

```
PR مفتوح / محدّث
       │
       ▼
┌──────────────┐
│    تثبيت     │  ← Composer install، تخزين مؤقت للـ dependencies
│ الاعتماديات  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│          التشغيل بالتوازي                │
│                                          │
│  ┌─────────┐  ┌──────────┐  ┌────────┐  │
│  │  Pint   │  │ PHPStan  │  │  Pest  │  │
│  │ (style) │  │(analysis)│  │(tests) │  │
│  └─────────┘  └──────────┘  └────────┘  │
└──────────────────────────────────────────┘
       │
       ▼
  الكل نجح؟ → ✅ الدمج مسموح
  أي فشل؟  → ❌ الدمج ممنوع
```

خطوة التثبيت تعمل أولاً وتنتج artifact (`vendor/`). الخطوات الثلاث للفحص تعمل بالتوازي - تشترك في الـ artifact لكنها لا تعتمد على بعضها. هذا يبقي الـ pipeline سريعاً.

### ملف البيئة لـ CI

أنشئ `.env.testing` في جذر المشروع (ادفعه للـ repo - لا يحتوي أسرار):

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

هذا يطابق إعدادات env في `phpunit.xml` من [2.1 الاختبارات](01-testing.md) لكن بصيغة `.env` لـ CI.

---

## مراحل الـ Pipeline - بالتفصيل

### المرحلة 1: Code Style (Pint)

```yaml
- step:
    name: Code Style (Pint)
    script:
      - ./vendor/bin/pint --test
```

`--test` يفحص التنسيق بدون تعديل الملفات. إذا لم يطابق أي ملف إعدادات Pint، تفشل الخطوة.

**لماذا نشغّل Pint في CI إذا كان لدينا pre-commit hook بالفعل؟**

لأن الـ pre-commit hook يعمل فقط على جهاز المطور. CI هو المُنفِّذ الأخير. إذا تجاوز شخص الـ hook - عمداً أو بالخطأ - CI يلتقطها.

**عند الفشل:** المطور يشغّل `./vendor/bin/pint` محلياً، يعمل commit للإصلاح، ويدفع مرة أخرى.

### المرحلة 2: Static Analysis (PHPStan)

```yaml
- step:
    name: Static Analysis (PHPStan)
    script:
      - ./vendor/bin/phpstan analyse --memory-limit=512M
```

PHPStan يقرأ إعدادات `phpstan.neon` المدفوعة في الـ repo (أُعدّت في [1.3 الأدوات](../phase1/03-tooling-selection.md)). العلم `--memory-limit=512M` يمنع أخطاء نفاد الذاكرة في المشاريع الكبيرة.

**عند الفشل:** المطور يصلح الأخطاء المُبلَّغ عنها محلياً. أخطاء PHPStan هي أخطاء حقيقية - عدم تطابق الأنواع، methods غير معرّفة، شروط مستحيلة.

### المرحلة 3: الاختبارات (Pest)

```yaml
- step:
    name: Tests (Pest)
    script:
      - cp .env.testing .env
      - php artisan key:generate
      - ./vendor/bin/pest --coverage --min=60
```

يشغّل هذا الـ test suite بالكامل ويفرض حد أدنى للتغطية 60%. إذا انخفضت التغطية عن 60%، تفشل الخطوة - حتى لو نجحت جميع الاختبارات.

**لماذا `cp .env.testing .env`؟** Laravel يحتاج ملف `.env` ليبدأ. في CI لا يوجد `.env` - ننسخ إعدادات الاختبار مكانه.

**لماذا `php artisan key:generate`؟** Laravel يتطلب تعيين `APP_KEY`. توليده في CI آمن لأن هذا المفتاح لا يُستخدم أبداً في الإنتاج.

---

## PHPStan Baseline - التعامل مع الكود القديم

إذا كنت تضيف CI لمشروع قائم، سيُبلغ PHPStan على الأرجح عن مئات الأخطاء في كود قديم لن يصلحه أحد الآن. الحل هو **baseline**.

### توليد Baseline

```bash
./vendor/bin/phpstan analyse --generate-baseline
```

هذا ينشئ `phpstan-baseline.neon` - ملف يسرد كل خطأ حالي ويخبر PHPStan بتجاهلها. الكود الجديد يجب أن يكون نظيفاً؛ الأخطاء القديمة مُتتبَّعة لكنها لا تمنع CI.

### تحديث phpstan.neon

```neon
includes:
    - vendor/larastan/larastan/extension.neon
    - phpstan-baseline.neon

parameters:
    paths:
        - app
    level: 5
```

### دفع الـ Baseline

```bash
git add phpstan-baseline.neon phpstan.neon
git commit -m "chore: add PHPStan baseline for legacy code"
```

### استراتيجية السقّاطة

مع الوقت، قلّل الـ baseline:

1. ابدأ بمستوى PHPStan **level 5** مع baseline
2. عندما يلمس مطور ملفاً، يصلح أخطاء PHPStan في ذلك الملف
3. أعد توليد الـ baseline دورياً - يجب أن يتقلص
4. كل ربع سنة، فكّر في رفع المستوى: 5 → 6 → 7 → 8

**لا ترفع المستوى وتعيد توليد الـ baseline في نفس الوقت أبداً** - هذا يخفي أخطاء جديدة خلف الـ baseline. ارفع المستوى، أصلح الأخطاء الجديدة، ثم ادفع.

---

## بوابات التغطية

### الحد الأدنى للتغطية في CI

العلم `--min=60` في خطوة Pest يفرض التغطية الإجمالية:

```bash
./vendor/bin/pest --coverage --min=60
```

| المقياس | الهدف | يُفرض في |
|---------|-------|----------|
| التغطية الإجمالية | 60% حد أدنى | CI (`--min=60`) |
| تغطية الكود الجديد | 80% موصى به | Code review (يدوي) |
| الكود المُولَّد بالذكاء الاصطناعي | 100% من الأسطر المعدّلة | Code review (يدوي) |

حد الـ 60% الإجمالي يُفرض تلقائياً. أهداف الـ 80% و100% للكود الجديد/AI تُفرض عبر code review - Pest لا يميّز الكود "الجديد" عن "القديم" تلقائياً.

### تقارير التغطية

ولّد تقرير HTML coverage كـ CI artifact:

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

المراجعون يمكنهم تحميل التقرير من نتائج Bitbucket pipeline لرؤية الأسطر المُغطّاة بالضبط.

### رفع المعيار مع الوقت

| المرحلة | بوابة التغطية | المبرر |
|---------|-------------|--------|
| بداية Phase 2 | 60% | واقعي للكود القديم مع smoke tests جديدة |
| نهاية Phase 2 | 70% | Feature tests أُضيفت للمسارات الحرجة |
| Phase 3 | 80% | الذكاء الاصطناعي يولّد اختبارات لكل كود جديد |

ارفع قيمة `--min` كلما نمت التغطية طبيعياً. لا تلاحق الأرقام - دع الاختبارات تضيف قيمة أولاً.

---

## بوابة الدمج

### صلاحيات Branch في Bitbucket

أعدّ صلاحيات الـ branch بحيث لا يصل كود إلى `main` بدون نجاح الـ pipeline.

**مسار الإعدادات:** `Repository Settings → Branch permissions → Add a branch permission`

| الإعداد | القيمة |
|---------|--------|
| Branch | `main` |
| Write access | لا دفع مباشر - PR فقط |
| Merge checks | جميع الـ builds يجب أن تنجح |
| Minimum approvals | 1 |
| Merge strategy | Squash (افتراضي) |

### قائمة الدمج

قبل أن يُدمج أي PR في `main`:

```
✅ Pint نجح       - الكود مُنسّق
✅ PHPStan نجح    - لا أخطاء static analysis
✅ Pest نجح       - جميع الاختبارات خضراء
✅ Coverage ≥ 60%  - لا تراجع في التغطية
✅ 1 موافقة       - إنسان راجعه
```

إذا فشل أي عنصر، زر الدمج معطّل. بدون استثناءات.

### لماذا هذا مهم

هذا ليس بيروقراطية - إنه الآلية التي تجعل Phase 3 ممكناً. عندما يفتح الـ AI agent أي PR، يمر بنفس البوابات تماماً كالإنسان. الـ pipeline لا يثق بالذكاء الاصطناعي. يتحقق.

```
AI يكتب كود → يدفع branch → يفتح PR
                                    │
                              Pipeline يعمل
                                    │
                         ┌──── نجح؟ ────┐
                         │               │
                   إنسان يراجع     Pipeline فشل
                    ويوافق        AI يقرأ الأخطاء
                         │          ويعدّل
                   دمج في main        │
                                  دفع إصلاح → Pipeline يعاد
```

---

## الـ Pipeline للكود المُولَّد بالذكاء الاصطناعي

### حلقة التغذية الراجعة الآلية

في Phase 3، يصبح CI pipeline آلية التغذية الراجعة الأساسية للـ AI agent. الـ agent لا يدفع الكود ويأمل فقط - يقرأ نتائج الـ pipeline ويعدّل.

```
┌───────────────────────────────────────────┐
│           سير عمل AI Agent                │
│                                           │
│   1. قراءة المهمة / التذكرة              │
│   2. كتابة الكود                         │
│   3. تشغيل الاختبارات محلياً (ردود سريعة)│
│   4. دفع branch، فتح PR                  │
│   5. CI pipeline يعمل                     │
│   6. إذا فشل CI → قراءة الأخطاء → إصلاح │
│   7. إذا نجح CI → طلب مراجعة بشرية       │
└───────────────────────────────────────────┘
```

الـ pipeline هو ما يجعل هذه الحلقة آمنة. بدونه، الخطوة 6 لا تعمل - والذكاء الاصطناعي يدفع كوداً معطّلاً يضطر الإنسان لتصحيحه يدوياً.

### ما يلتقطه CI ولا تلتقطه الاختبارات المحلية

| المشكلة | محلياً | CI |
|---------|--------|-----|
| Dependency مفقود (لم يُدفع) | ❌ يعمل محلياً | ✅ يفشل - تثبيت نظيف |
| خطأ خاص بالبيئة | ❌ يعمل على جهاز المطور | ✅ يفشل - بيئة مختلفة |
| ملف غير مدفوع | ❌ الاختبارات تنجح (الملف موجود محلياً) | ✅ يفشل - الملف ليس في الـ repo |
| Race condition في الاختبارات المتوازية | ❌ ينجح أحياناً | ✅ أكثر احتمالاً للظهور |
| تراجع التغطية | ❌ المطور لا يفحص | ✅ `--min` يفرضها |

### تجهيز الـ Pipeline لـ Phase 3

الـ pipeline الذي تبنيه الآن في Phase 2 هو نفس الـ pipeline الذي يستخدمه الذكاء الاصطناعي في Phase 3. لا تغييرات مطلوبة - بالتصميم. الفرق الوحيد هو من يدفع الكود.

---

## استكشاف الأخطاء وإصلاحها

### SQLite مقابل MySQL في CI

إعداد الـ pipeline يستخدم SQLite in-memory للسرعة. هذا يعمل لمعظم اختبارات Laravel. لكن إذا كان تطبيقك يستخدم ميزات خاصة بـ MySQL (أعمدة JSON، full-text search، صيغة SQL محددة)، قد تنجح الاختبارات محلياً على MySQL لكن تفشل في CI على SQLite.

**الخيار 1: البقاء مع SQLite** (موصى به لمعظم المشاريع)

ابقَ مع SQLite للسرعة. اكتب اختبارات لا تعتمد على صيغة خاصة بقاعدة البيانات. هذا النهج الافتراضي.

**الخيار 2: استخدام MySQL في CI**

إذا احتجت MySQL، أضف service container:

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

مع ملف `.env.ci-mysql` مقابل:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=testing
DB_USERNAME=root
DB_PASSWORD=password
```

**المقايضة:** MySQL يضيف 30-60 ثانية لبدء الـ pipeline. استخدمه فقط إذا تسبب SQLite في فشل اختبارات حقيقي.

### الـ Pipeline بطيء جداً

| المشكلة | الحل |
|---------|------|
| تثبيت Composer يستغرق وقتاً طويلاً | فعّل التخزين المؤقت (موجود بالفعل في الإعداد أعلاه) |
| PHPStan بطيء على codebase كبيرة | أضف `--memory-limit=1G` وفكّر في تقسيم التحليل |
| الاختبارات تستغرق أكثر من 5 دقائق | شغّل Pest بالتوازي: `--parallel` |
| تحميل packages متكرر | مفتاح cache الـ Composer مرتبط بـ `composer.lock` - يتغير فقط عند تغيير الـ deps |

### التنفيذ المتوازي للاختبارات

إذا نمت الـ test suite لأكثر من 3-4 دقائق، فعّل التنفيذ المتوازي:

```yaml
- step:
    name: Tests (Pest)
    script:
      - cp .env.testing .env
      - php artisan key:generate
      - ./vendor/bin/pest --parallel --coverage --min=60
```

**المتطلب:** Pest parallel يتطلب حزمة `brianium/paratest`:

```bash
composer require brianium/paratest --dev
```

### حدود الذاكرة

PHPStan وPest كلاهما يمكن أن يصطدم بحدود الذاكرة في المشاريع الكبيرة:

```yaml
# PHPStan
- ./vendor/bin/phpstan analyse --memory-limit=1G

# Pest (عبر php.ini)
- echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory.ini
- ./vendor/bin/pest --coverage --min=60
```

### أخطاء CI الشائعة وإصلاحاتها

| الخطأ | السبب | الإصلاح |
|-------|-------|---------|
| `Class not found` | Autoload مفقود | شغّل `composer dump-autoload` أو تحقق من الـ namespace |
| `APP_KEY is empty` | توليد المفتاح مفقود | أضف `php artisan key:generate` للـ pipeline |
| `SQLite driver not found` | PHP extension مفقود | أضف `docker-php-ext-install pdo_sqlite` |
| `Permission denied` | صلاحيات الملف | تحقق من صلاحيات الملفات في الـ repo |
| `Coverage below minimum` | الاختبارات لا تغطي كوداً كافياً | اكتب مزيداً من الاختبارات أو خفّض الحد مؤقتاً |

---

## إعداد الـ Pipeline الكامل

هذا هو `bitbucket-pipelines.yml` الكامل الجاهز للإنتاج:

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

قسم `branches.main` يشغّل نفس الفحوصات بعد الدمج - بالإضافة إلى توليد تقرير coverage كـ artifact. هذا يلتقط أي مشاكل تتسلل (مثل merge conflicts التي تُدخل أخطاء).

---

## قائمة التحقق - اكتمل عند

- [ ] `bitbucket-pipelines.yml` مدفوع في الـ repo
- [ ] `.env.testing` مدفوع (بدون أسرار)
- [ ] الـ Pipeline يعمل تلقائياً على كل PR
- [ ] فحص Pint ينجح في CI
- [ ] فحص PHPStan ينجح في CI (مع baseline إذا لزم)
- [ ] اختبارات Pest تنجح في CI مع تقارير التغطية
- [ ] حد التغطية الأدنى مُفعَّل (`--min=60`)
- [ ] PHPStan baseline مُولَّد ومدفوع (إذا كان مشروع قديم)
- [ ] صلاحيات Branch مُعدّة: الـ builds يجب أن تنجح + 1 موافقة
- [ ] الدمج في `main` ممنوع عند فشل أي خطوة في الـ pipeline
- [ ] الفريق رأى pipeline فاشل ويعرف كيف يقرأ الـ logs
- [ ] الـ Pipeline يكتمل في أقل من 5 دقائق
