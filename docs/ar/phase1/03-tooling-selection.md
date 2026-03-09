# 1.3 Tooling Selection

> Standards بدون tools مجرد نوايا. الـ tools تطبّق المعايير تلقائياً — حتى عندما يكون الفريق متعباً أو مستعجلاً أو لا يتذكر القواعد.

> **الفصل عن 1.2:** قواعد الـ coding style موجودة في [1.2 Laravel Standards](02-laravel-standards.md). الـ tools التي تُطبّقها — IDE، extensions، pre-commit، static analysis — موجودة هنا.

---

## الأهداف

- اختيار IDE يدمج الذكاء الاصطناعي بشكل أصلي ويعمل جيداً مع Laravel
- اختيار AI assistant الذي سيستخدمه الفريق يومياً
- auto-format عند الحفظ، auto-check عند الـ commit — صفر جهد يدوي
- جعله مستحيلاً هيكلياً push كود يفشل في الـ style أو الـ static analysis

---

## IDE Selection

### المرشحون

| IDE | المزايا | العيوب |
|-----|---------|--------|
| **Anti-gravity** | AI-native، agentic workflows مدمجة، VS Code compatible، مجاني | أحدث، مجتمع أصغر |
| Cursor | يدمج الذكاء الاصطناعي، قاعدة VS Code مألوفة، شائع | مدفوع، الذكاء الاصطناعي طبقة subscription فوق المحرر |
| VS Code | مجاني، منظومة extensions ضخمة | لا AI أصلي — يعتمد كلياً على الـ extensions |
| PhpStorm | أفضل code intelligence لـ PHP/Laravel | مدفوع، ثقيل، ليس AI-native |

### التوصية: Anti-gravity

Anti-gravity هو editor أصلي للذكاء الاصطناعي مبني من الصفر لـ agent-assisted coding. على عكس Cursor — الذي يضع الذكاء الاصطناعي فوق VS Code — يعامل Anti-gravity الذكاء الاصطناعي كجزء أساسي من سير العمل.

**المزايا الرئيسية لهذا الانتقال:**

- مبني للـ agentic coding — يتوافق مباشرة مع أهداف Phase 3
- VS Code extension compatible — الـ extensions والـ settings الموجودة تعمل بنفس الطريقة
- مجاني — لا per-seat subscription cost للفريق
- يشجع على AI-first thinking من اليوم الأول

### لماذا لا Cursor؟

Cursor خيار متين ومعتمد على نطاق واسع — لكنه يضع نفسه كمنتج الذكاء الاصطناعي، لا مجرد أداة. الفريق ينتهي به الأمر معتمداً على Cursor subscription بدلاً من بناء مهارات مع model-agnostic workflow.

> Anti-gravity + Claude Code = مجموعة أدوات تتحكم بها أنت. Cursor = مجموعة أدوات يتحكم بها شخص آخر.

---

## AI Coding Assistant

### Claude Code vs Cursor AI

| | **Claude Code** | Cursor AI |
|--|-----------------|-----------|
| Model | Claude Opus 4.6 — best in class للكود | GPT-4o / Claude (بحسب اختيارهم) |
| Interface | Terminal + IDE agent | مدمج في Cursor فقط |
| Agentic capability | Full agent — يقرأ، يحرر، ينفذ أوامر | Composer mode (محدود) |
| Context window | 200K tokens | context محدود |
| Portability | يعمل في أي terminal، أي repository | Cursor فقط |
| Cost | Per token (تدفع لما تستخدمه) | Monthly subscription |
| Team control | كامل — تختار الـ model والـ prompts | مقيّد بتطبيق Cursor |

### التوصية: Claude Code

Claude Code هو أداة الذكاء الاصطناعي لهذا الانتقال. يعمل كـ agent — وليس مجرد autocomplete — مما يعني أنه يستطيع قراءة الـ codebase، تخطيط التغييرات، تشغيل الـ tests، والتكرار. هذا هو أساس Phase 3.

### Claude Code: طريقتان للاستخدام

Claude Code يأتي بشكلين — استخدم الاثنين، يكملان بعضهما البعض.

#### 1. Claude Code VS Code Extension (الأساسية)

ثبّتها مباشرة من VS Code marketplace: **Claude Code** من Anthropic.

الـ extension تدمج Claude Code في الـ IDE sidebar. تتفاعل معها دون مغادرة المحرر.

**الأنسب لـ:**
- طرح أسئلة حول الملف الذي تنظر إليه
- طلب targeted edits مع IDE context الكامل (الملفات المفتوحة، التحديد، الأخطاء)
- مراجعة وقبول/رفض تغييرات الذكاء الاصطناعي مباشرة
- البرمجة اليومية — الطريقة منخفضة الاحتكاك للعمل مع الذكاء الاصطناعي

**التثبيت في VS Code / Anti-gravity:**
```
Extensions → Search "Claude Code" → Install
```

ثم sign in بحساب Anthropic أو API key.

#### 2. Claude Code CLI (Terminal Agent)

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
- Agentic workflows — دع Claude يقرأ، يحرر، يُشغّل، ويتكرر باستقلالية
- التشغيل في CI أو automated pipelines
- المهام حيث تصف الهدف وتدع الـ agent يعمل عليه

**مثال على جلسة:**
```bash
claude "Refactor the OrderController to use Form Requests and an action class.
       Follow the conventions in CLAUDE.md. Run Pint after."
```

### CLI vs Extension — مقارنة سريعة

| | **VS Code Extension** | **CLI (Terminal)** |
|--|----------------------|--------------------|
| Interface | IDE sidebar | Terminal |
| الأنسب لـ | Targeted edits، أسئلة، inline review | Long autonomous tasks، multi-file refactors |
| السياق | الملف الحالي + الملفات المفتوحة | المشروع بأكمله (تتحكم في النطاق) |
| التحكم | عالٍ — ترى كل تغيير | متغير — الـ agent يعمل باستقلالية |
| توافق المرحلة | Phase 2 (supervised) | Phase 3 (agentic) |

> ابدأ الفريق على **الـ extension** في Phase 2. قدّم **CLI agent** في Phase 3 مع تزايد الثقة.

---

## Model Selection

### النموذج: Claude Opus 4.6

استخدم **Claude Opus 4.6** (`claude-opus-4-6`) كـ default model للفريق. إنه الأكثر قدرة للمهام الـ agentic المعقدة متعددة الملفات.

اضبطه في Claude Code:
```bash
claude config set model claude-opus-4-6
```

### لماذا Opus 4.6 على البدائل؟

| Model | Provider | جودة الكود | Context | Agentic | الأنسب لـ |
|-------|----------|-----------|--------|---------|-----------|
| **Claude Opus 4.6** | Anthropic | ⭐⭐⭐⭐⭐ | 200K | ✅ Full | مهام معقدة، متعدد الملفات، قرارات معمارية |
| Claude Sonnet 4.6 | Anthropic | ⭐⭐⭐⭐ | 200K | ✅ Full | المهام اليومية، رد أسرع، تكلفة أقل |
| GPT-4o | OpenAI | ⭐⭐⭐⭐ | 128K | ⚠️ Partial | General purpose، منظومة واسعة |
| GPT-o3 | OpenAI | ⭐⭐⭐⭐⭐ | 128K | ⚠️ Partial | Deep reasoning، أبطأ |
| Gemini 2.0 Pro | Google | ⭐⭐⭐⭐ | 1M | ⚠️ Partial | Large context، تكامل مع Google |
| Gemini 2.5 Flash | Google | ⭐⭐⭐ | 1M | ⚠️ Partial | سريع، رخيص، مناسب للمهام البسيطة |
| DeepSeek R2 | DeepSeek | ⭐⭐⭐⭐ | 128K | ❌ Limited | فعّال التكلفة، قوي في المنطق |

**لماذا Claude Opus 4.6 يفوز في Laravel agentic development:**

- **الأفضل في اتباع التعليمات المعقدة** — multi-step refactors، قرارات المعمارية، المهام الطويلة تبقى على المسار
- **200K token context** — يستطيع الاحتفاظ بملفات feature كاملة في جلسة واحدة
- **Full agentic tool use** — يقرأ الملفات، ينفذ أوامر، يكتب tests، يتكرر بدون prompting مستمر
- **يحترم معاييرك** — بوجود `CLAUDE.md` باتفاقيات فريقك، يتبعها باستمرار
- **Safety-first reasoning** — أقل احتمالاً لتوليد breaking changes خاطئة

### متى تستخدم Sonnet بدلاً من ذلك؟

Sonnet 4.6 هو الخيار الصحيح لـ:
- الأسئلة السريعة والمهام القصيرة
- شرح block من الكود
- توليد migration واحد أو simple CRUD
- المواقف التي تهم فيها سرعة الرد

> **قاعدة بسيطة:** استخدم Opus عندما تكون المهمة متعددة الخطوات أو تمس ملفات متعددة. استخدم Sonnet عند سؤال واحد محدد أو تعديل صغير.

---

## VS Code Extensions

تنطبق على كلٍّ من Anti-gravity و VS Code. أضف `.vscode/extensions.json` مشتركاً للـ repository حتى يقترحها الـ IDE تلقائياً على كل عضو في الفريق.

### Required Extensions

| Extension | ID | الغرض |
|-----------|-----|--------|
| PHP Intelephense | `bmewburn.vscode-intelephense-client` | Code intelligence، go-to-definition، autocomplete |
| Laravel Pint | `open-in-browser.laravel-pint` | Auto-format PHP عند الحفظ |
| PHPStan | `swordev.phpstan` | Static analysis errors مباشرة |
| EditorConfig | `editorconfig.editorconfig` | تطبيق قواعد `.editorconfig` تلقائياً |
| Laravel Artisan | `ryannaddy.laravel-artisan` | تشغيل أوامر artisan من الـ IDE |
| DotENV | `mikestead.dotenv` | Syntax highlighting لملفات `.env` |

### `.vscode/extensions.json`

أودِع هذا الملف حتى يقترح الـ IDE الـ extensions عند فتح المشروع:

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

Format on save مع Pint، PHPStan مفعّل inline:

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

*أودِع `.vscode/settings.json` — shared IDE config جزء من المشروع، وليس تفضيلاً شخصياً.*

---

## Code Quality Tools

### PHPStan + Larastan

[PHPStan](https://phpstan.org) يكتشف الأخطاء قبل التشغيل. [Larastan](https://github.com/larastan/larastan) يوسّعه بقواعد خاصة بـ Laravel (Eloquent، relationships، facades).

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

*ابدأ من level 5. ارفع إلى 8+ عندما يصبح الـ codebase نظيفاً.*

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

# الحصول على staged PHP files فقط
STAGED_PHP=$(git diff --cached --name-only --diff-filter=ACM | grep "\.php$" || true)

if [ -z "$STAGED_PHP" ]; then
    exit 0
fi

echo "→ Checking code style (Pint)..."
./vendor/bin/pint --test $STAGED_PHP
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Code style issues found. Run: ./vendor/bin/pint"
    exit 1
fi

echo "→ Running static analysis (PHPStan)..."
./vendor/bin/phpstan analyse $STAGED_PHP --memory-limit=256M
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ PHPStan errors found. Fix them before committing."
    exit 1
fi

echo "✅ All checks passed."
```

*اجعله executable مرة واحدة، ثم أودِعه:*
```bash
chmod +x .githooks/pre-commit
git add .githooks/pre-commit
```

---

## Composer Integration

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

الآن كل مطور يستنسخ الـ repository ويشغّل `composer install` يحصل على الـ hook مثبتاً تلقائياً.

**تحقق من التثبيت:**
```bash
ls -la .git/hooks/pre-commit
cat .git/hooks/pre-commit
```

---

## Checklist — Done When

- [ ] Anti-gravity مثبت على جميع أجهزة المطورين
- [ ] Claude Code مثبت (`npm install -g @anthropic-ai/claude-code`)
- [ ] `.vscode/extensions.json` مُودَع — الفريق يُطلب منه تثبيت الـ extensions
- [ ] `.vscode/settings.json` مُودَع — format on save نشط لـ PHP
- [ ] PHPStan + Larastan مثبتان، `phpstan.neon` مُودَع
- [ ] `.githooks/pre-commit` مُودَع وقابل للتنفيذ
- [ ] Composer `post-install-cmd` / `post-update-cmd` scripts مضافة
- [ ] كل مطور شغّل `composer install` — الـ hook نشط على جهازه
- [ ] اختبر أن الـ commit يُرفض عند فشل Pint أو PHPStan
- [ ] PHPStan level محدد ومتفق عليه من الفريق
