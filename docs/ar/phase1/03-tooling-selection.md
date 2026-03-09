# 1.3 اختيار الأدوات

> المعايير بدون أدوات مجرد نوايا. الأدوات تطبّق المعايير تلقائياً — حتى عندما يكون الفريق متعباً أو مستعجلاً أو لا يتذكر القواعد.

> **الفصل عن 1.2:** قواعد أسلوب الكود موجودة في [1.2 معايير Laravel](02-laravel-standards.md). الأدوات التي تُطبّقها — IDE، الإضافات، pre-commit، التحليل الثابت — موجودة هنا.

---

## الأهداف

- اختيار IDE يدمج الذكاء الاصطناعي بشكل أصلي ويعمل جيداً مع Laravel
- اختيار مساعد الذكاء الاصطناعي الذي سيستخدمه الفريق يومياً
- تنسيق تلقائي عند الحفظ، فحص تلقائي عند الـ commit — صفر جهد يدوي
- جعله مستحيلاً هيكلياً دفع كود يفشل في أسلوب الكتابة أو التحليل الثابت

---

## اختيار IDE

### المرشحون

| IDE | المزايا | العيوب |
|-----|---------|--------|
| **Anti-gravity** | ذكاء اصطناعي أصلي، سير عمل وكيلي مدمج، متوافق مع VS Code، مجاني | أحدث، مجتمع أصغر |
| Cursor | يدمج الذكاء الاصطناعي، قاعدة VS Code مألوفة، شائع | مدفوع، الذكاء الاصطناعي طبقة اشتراك فوق المحرر |
| VS Code | مجاني، منظومة إضافات ضخمة | لا ذكاء اصطناعي أصلي — يعتمد كلياً على الإضافات |
| PhpStorm | أفضل ذكاء كودي لـ PHP/Laravel | مدفوع، ثقيل، ليس أصلياً للذكاء الاصطناعي |

### التوصية: Anti-gravity

Anti-gravity محرر أصلي للذكاء الاصطناعي مبني من الصفر لسير عمل البرمجة الوكيلية. على عكس Cursor — الذي يضع الذكاء الاصطناعي فوق VS Code — يعامل Anti-gravity الذكاء الاصطناعي كجزء أساسي من سير العمل.

**المزايا الرئيسية لهذا الانتقال:**

- مبني للبرمجة الوكيلية — يتوافق مباشرة مع أهداف المرحلة الثالثة
- متوافق مع إضافات VS Code — الإضافات والإعدادات الموجودة تعمل بنفس الطريقة
- مجاني — لا تكلفة اشتراك لكل عضو في الفريق
- يشجع على التفكير الأولي بالذكاء الاصطناعي من اليوم الأول

### لماذا لا Cursor؟

Cursor خيار متين ومعتمد على نطاق واسع — لكنه يضع نفسه كمنتج الذكاء الاصطناعي، لا مجرد أداة. الفريق ينتهي به الأمر معتمداً على اشتراك Cursor للذكاء الاصطناعي بدلاً من بناء مهارات مع سير عمل مستقل عن النموذج.

> Anti-gravity + Claude Code = مجموعة أدوات تتحكم بها أنت. Cursor = مجموعة أدوات يتحكم بها شخص آخر.

---

## مساعد الذكاء الاصطناعي للبرمجة

### Claude Code مقابل Cursor AI

| | **Claude Code** | Cursor AI |
|--|-----------------|-----------|
| النموذج | Claude Opus 4.6 — الأفضل في فئته للكود | GPT-4o / Claude (بحسب اختيارهم) |
| الواجهة | Terminal + IDE agent | مدمج في Cursor فقط |
| القدرة الوكيلية | وكيل كامل — يقرأ، يحرر، ينفذ أوامر | Composer mode (محدود) |
| نافذة السياق | 200K token | سياق محدود |
| قابلية النقل | يعمل في أي terminal، أي مستودع | Cursor فقط |
| التكلفة | لكل token (تدفع لما تستخدمه) | اشتراك شهري |
| تحكم الفريق | كامل — تختار النموذج والأوامر | مقيّد بتطبيق Cursor |

### التوصية: Claude Code

Claude Code هو أداة الذكاء الاصطناعي لهذا الانتقال. يعمل كوكيل — وليس مجرد إكمال تلقائي — مما يعني أنه يستطيع قراءة كودك، تخطيط التغييرات، تشغيل الاختبارات، والتكرار. هذا هو أساس المرحلة الثالثة.

### Claude Code: طريقتان للاستخدام

Claude Code يأتي بشكلين — استخدم الاثنين، يكملان بعضهما البعض.

#### 1. إضافة Claude Code لـ VS Code (الأساسية)

ثبّتها مباشرة من سوق VS Code: **Claude Code** من Anthropic.

الإضافة تدمج Claude Code في الشريط الجانبي للـ IDE. تتفاعل معها دون مغادرة المحرر.

**الأنسب لـ:**
- طرح أسئلة حول الملف الذي تنظر إليه
- طلب تعديلات محددة مع سياق IDE الكامل (الملفات المفتوحة، التحديد، الأخطاء)
- مراجعة وقبول/رفض تغييرات الذكاء الاصطناعي مباشرة
- البرمجة اليومية — الطريقة منخفضة الاحتكاك للعمل مع الذكاء الاصطناعي

**التثبيت في VS Code / Anti-gravity:**
```
Extensions → Search "Claude Code" → Install
```

ثم سجّل الدخول بحساب Anthropic أو API key.

#### 2. Claude Code CLI (وكيل Terminal)

ثبّته عالمياً عبر npm:
```bash
npm install -g @anthropic-ai/claude-code
```

شغّله من أي مجلد مشروع:
```bash
claude
```

**الأنسب لـ:**
- المهام المعقدة متعددة الخطوات التي تمتد عبر ملفات كثيرة
- سير العمل الوكيلي — دع Claude يقرأ، يحرر، يُشغّل، ويتكرر باستقلالية
- التشغيل في CI أو pipelines آلية
- المهام حيث تصف الهدف وتدع الوكيل يعمل عليه

**مثال على جلسة:**
```bash
claude "أعد هيكلة OrderController لاستخدام Form Requests وكلاس action.
       اتبع الاتفاقيات في CLAUDE.md. شغّل Pint بعد الانتهاء."
```

### CLI مقابل الإضافة — مقارنة سريعة

| | **إضافة VS Code** | **CLI (Terminal)** |
|--|-------------------|-------------------|
| الواجهة | الشريط الجانبي للـ IDE | Terminal |
| الأنسب لـ | تعديلات محددة، أسئلة، مراجعة مباشرة | مهام مستقلة طويلة، إعادة هيكلة متعددة الملفات |
| السياق | الملف الحالي + الملفات المفتوحة | المشروع بأكمله (تتحكم في النطاق) |
| التحكم | عالٍ — ترى كل تغيير | متغير — الوكيل يعمل باستقلالية |
| توافق المرحلة | المرحلة الثانية (بإشراف) | المرحلة الثالثة (وكيلي) |

> ابدأ الفريق على **الإضافة** في المرحلة الثانية. قدّم **وكيل CLI** في المرحلة الثالثة مع تزايد الثقة.

---

## اختيار النموذج

### النموذج: Claude Opus 4.6

استخدم **Claude Opus 4.6** (`claude-opus-4-6`) كنموذج افتراضي للفريق. إنه الأكثر قدرة للمهام الوكيلية المعقدة متعددة الملفات.

اضبطه في Claude Code:
```bash
claude config set model claude-opus-4-6
```

### لماذا Opus 4.6 على البدائل؟

| النموذج | المزوّد | جودة الكود | السياق | وكيلي | الأنسب لـ |
|---------|--------|-----------|--------|--------|-----------|
| **Claude Opus 4.6** | Anthropic | ⭐⭐⭐⭐⭐ | 200K | ✅ كامل | مهام معقدة، متعدد الملفات، قرارات معمارية |
| Claude Sonnet 4.6 | Anthropic | ⭐⭐⭐⭐ | 200K | ✅ كامل | المهام اليومية، رد أسرع، تكلفة أقل |
| GPT-4o | OpenAI | ⭐⭐⭐⭐ | 128K | ⚠️ جزئي | عام، منظومة واسعة |
| GPT-o3 | OpenAI | ⭐⭐⭐⭐⭐ | 128K | ⚠️ جزئي | تفكير عميق، أبطأ |
| Gemini 2.0 Pro | Google | ⭐⭐⭐⭐ | 1M | ⚠️ جزئي | سياق كبير، تكامل مع Google |
| Gemini 2.5 Flash | Google | ⭐⭐⭐ | 1M | ⚠️ جزئي | سريع، رخيص، مناسب للمهام البسيطة |
| DeepSeek R2 | DeepSeek | ⭐⭐⭐⭐ | 128K | ❌ محدود | فعّال التكلفة، قوي في المنطق |

**لماذا Claude Opus 4.6 يفوز في تطوير Laravel الوكيلي:**

- **الأفضل في اتباع التعليمات المعقدة** — إعادة الهيكلة متعددة الخطوات، قرارات المعمارية، المهام الطويلة تبقى على المسار
- **سياق 200K token** — يستطيع الاحتفاظ بملفات ميزة كاملة في جلسة واحدة
- **استخدام أدوات وكيلية كاملة** — يقرأ الملفات، ينفذ أوامر، يكتب اختبارات، يتكرر بدون توجيه مستمر
- **يحترم معاييرك** — بوجود `CLAUDE.md` باتفاقيات فريقك، يتبعها باستمرار
- **تفكير بالسلامة أولاً** — أقل احتمالاً لتوليد تغييرات غير صحيحة

### متى تستخدم Sonnet بدلاً من ذلك؟

Sonnet 4.6 هو الخيار الصحيح لـ:
- الأسئلة السريعة والمهام القصيرة
- شرح كتلة من الكود
- توليد migration واحد أو CRUD بسيط
- المواقف التي تهم فيها سرعة الرد

> **قاعدة بسيطة:** استخدم Opus عندما تكون المهمة متعددة الخطوات أو تمس ملفات متعددة. استخدم Sonnet عند سؤال واحد محدد أو تعديل صغير.

---

## إضافات VS Code

تنطبق على كلٍّ من Anti-gravity و VS Code. أضف `.vscode/extensions.json` مشتركاً للمستودع حتى يقترحها الـ IDE تلقائياً على كل عضو في الفريق.

### الإضافات المطلوبة

| الإضافة | المعرّف | الغرض |
|---------|--------|--------|
| PHP Intelephense | `bmewburn.vscode-intelephense-client` | ذكاء كودي، الانتقال إلى التعريف، الإكمال التلقائي |
| Laravel Pint | `open-in-browser.laravel-pint` | تنسيق PHP تلقائي عند الحفظ |
| PHPStan | `swordev.phpstan` | أخطاء التحليل الثابت مباشرة |
| EditorConfig | `editorconfig.editorconfig` | تطبيق قواعد `.editorconfig` تلقائياً |
| Laravel Artisan | `ryannaddy.laravel-artisan` | تشغيل أوامر artisan من الـ IDE |
| DotENV | `mikestead.dotenv` | تمييز صيغة ملفات `.env` |

### `.vscode/extensions.json`

أودِع هذا الملف حتى يقترح الـ IDE الإضافات عند فتح المشروع:

```json
{
    "recommendations": [
        "bmewburn.vscode-intelephense-client",
        "open-in-browser.laravel-pint",
        "swordev.phpstan",
        "editorconfig.editorconfig",
        "ryannaddy.laravel-artisan",
        "mikestead.dotenv"
    ]
}
```

### `.vscode/settings.json`

تنسيق عند الحفظ مع Pint، PHPStan مفعّل مباشرة:

```json
{
    "editor.formatOnSave": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.eol": "\n",
    "[php]": {
        "editor.defaultFormatter": "open-in-browser.laravel-pint"
    },
    "phpstan.enabled": true,
    "phpstan.configFile": "phpstan.neon",
    "intelephense.environment.phpVersion": "8.2"
}
```

*أودِع `.vscode/settings.json` — إعداد IDE المشترك جزء من المشروع، وليس تفضيلاً شخصياً.*

---

## أدوات جودة الكود

### PHPStan + Larastan

[PHPStan](https://phpstan.org) يكتشف الأخطاء قبل التشغيل. [Larastan](https://github.com/larastan/larastan) يوسّعه بقواعد خاصة بـ Laravel (Eloquent، العلاقات، facades).

**التثبيت:**
```bash
composer require --dev phpstan/phpstan larastan/larastan
```

**الإعداد** في `phpstan.neon` بمجلد المشروع:
```neon
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app

    level: 5

    ignoreErrors:

    excludePaths:
        - app/Http/Middleware/RedirectIfAuthenticated.php
```

*ابدأ من المستوى 5. ارفع إلى 8+ عندما يصبح الكود نظيفاً.*

**التشغيل اليدوي:**
```bash
./vendor/bin/phpstan analyse
./vendor/bin/phpstan analyse --memory-limit=512M  # للمشاريع الكبيرة
```

---

## Pre-commit Hooks

الـ hook يعمل تلقائياً عند كل `git commit`. يمنع الـ commit إذا فشل Pint أو PHPStan. لا حاجة لتذكّر تشغيل الفحوصات يدوياً.

### ملف الـ Hook

خزّن hooks في `.githooks/` (متابَعة بالـ git — لذا كل مطور يحصل عليها تلقائياً عبر composer):

**`.githooks/pre-commit`:**
```bash
#!/bin/bash

set -e

# الحصول على ملفات PHP المرحلية فقط
STAGED_PHP=$(git diff --cached --name-only --diff-filter=ACM | grep "\.php$" || true)

if [ -z "$STAGED_PHP" ]; then
    exit 0
fi

echo "→ فحص أسلوب الكود (Pint)..."
./vendor/bin/pint --test $STAGED_PHP
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ مشاكل في أسلوب الكود. شغّل: ./vendor/bin/pint"
    exit 1
fi

echo "→ تشغيل التحليل الثابت (PHPStan)..."
./vendor/bin/phpstan analyse $STAGED_PHP --memory-limit=256M
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ أخطاء PHPStan. أصلحها قبل الـ commit."
    exit 1
fi

echo "✅ جميع الفحوصات نجحت."
```

*اجعله قابلاً للتنفيذ مرة واحدة، ثم أودِعه:*
```bash
chmod +x .githooks/pre-commit
git add .githooks/pre-commit
```

---

## التكامل مع Composer

ثبّت git hook تلقائياً عند تشغيل أي شخص `composer install` أو `composer update`. لا إعداد يدوي مطلوب لكل مطور.

**أضف إلى `composer.json`:**
```json
{
    "scripts": {
        "post-install-cmd": [
            "@php -r \"copy('.githooks/pre-commit', '.git/hooks/pre-commit'); chmod('.git/hooks/pre-commit', 0755);\""
        ],
        "post-update-cmd": [
            "@php -r \"copy('.githooks/pre-commit', '.git/hooks/pre-commit'); chmod('.git/hooks/pre-commit', 0755);\""
        ]
    }
}
```

الآن كل مطور يستنسخ المستودع ويشغّل `composer install` يحصل على الـ hook مثبتاً تلقائياً.

**تحقق من التثبيت:**
```bash
ls -la .git/hooks/pre-commit
cat .git/hooks/pre-commit
```

---

## قائمة التحقق — اكتمل عند

- [ ] Anti-gravity مثبت على جميع أجهزة المطورين
- [ ] Claude Code مثبت (`npm install -g @anthropic-ai/claude-code`)
- [ ] `.vscode/extensions.json` مُودَع — الفريق يُطلب منه تثبيت الإضافات
- [ ] `.vscode/settings.json` مُودَع — التنسيق عند الحفظ نشط لـ PHP
- [ ] PHPStan + Larastan مثبتان، `phpstan.neon` مُودَع
- [ ] `.githooks/pre-commit` مُودَع وقابل للتنفيذ
- [ ] إضافة scripts `post-install-cmd` / `post-update-cmd` إلى composer
- [ ] كل مطور شغّل `composer install` — الـ hook نشط على جهازه
- [ ] اختبر أن الـ commit يُرفض عند فشل Pint أو PHPStan
- [ ] مستوى PHPStan محدد ومتفق عليه من الفريق
