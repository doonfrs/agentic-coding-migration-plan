# 2.3 البيئة

> "يعمل على جهازي" هو أقدم عذر في البرمجيات - وهو قاتل لـ AI-assisted coding. إذا كانت أجهزة المطورين، و CI، و staging، و production تشغّل إصدارات مختلفة، فإن نجاح الـ test suite لا يثبت شيئاً. الـ parity هو ما يجعل نجاح الاختبار يعني "هذا يعمل في الإنتاج".

---

## الأهداف

- وضع development environment داخل containers حتى يشغّل كل مطور بيئة متطابقة
- مطابقة إصدار PHP والـ extensions المحلية مع CI و production
- تحقيق parity عبر dev و staging و production - نفس الإصدارات، نفس الخدمات
- إزالة انحراف الـ config عبر إدارة منضبطة لـ `.env`
- جعل عبارة "نجحت الاختبارات، إذاً يعمل في الإنتاج" عبارة صحيحة

---

## لماذا الـ Parity قبل Supervised AI

Phase 2 تبني شبكات الأمان. [الاختبارات](01-testing.md) و [CI Pipeline](02-ci-pipeline.md) تتحقق من أن الكود صحيح - لكنها تتحقق منه فقط مقابل *البيئة التي تعمل فيها*. وإذا لم تطابق تلك البيئة الإنتاج، ففي شبكة الأمان ثقب.

هذا يهم أكثر مع وجود الذكاء الاصطناعي في الحلقة. عندما يكتب مطور كوداً، يحمل نموذجاً ذهنياً لبيئة الإنتاج ويبرمج لا شعورياً حول خصائصها. الذكاء الاصطناعي لا يفعل. إنه يولّد كوداً مقابل البيئة التي يستطيع ملاحظتها. وإذا اختلفت تلك البيئة عن الإنتاج، فقد ينكسر كود AI الذي مرّ بكل الفحوص عند النشر - ولن يفهم أحد لماذا.

الـ parity يغلق تلك الفجوة. عندما تكون dev و CI و staging و production متطابقة، تصبح "الاختبارات نجحت" وعداً تثق به بما يكفي لتترك الذكاء الاصطناعي يكتب الكود.

---

## Docker Setup

أسرع طريقة للحصول على بيئات متطابقة عبر فريق Laravel هي **Laravel Sail** - Docker، لكن مع الـ boilerplate مكتوباً مسبقاً.

### لماذا Docker / Sail

| بدون Docker | مع Docker / Sail |
|-------------|------------------|
| كل مطور يثبّت PHP و MySQL و Redis يدوياً | `docker-compose.yml` واحد، متطابق في كل مكان |
| انحراف الإصدارات بين الأجهزة | إصدارات مثبّتة للجميع |
| onboarding بصيغة "ثبّت هذه الستة أشياء" | `git clone` + `sail up` |
| dev environment ≠ CI ≠ production | نفس مفهوم الـ image عبر الثلاثة |

### خدمات docker-compose

Sail ينشر `docker-compose.yml` يصف الخدمات التي يحتاجها التطبيق. ثبّت كل إصدار ليطابق الإنتاج:

```yaml
services:
  app:
    image: sail-8.2/app          # PHP 8.2 - يطابق CI image php:8.2-cli
    ports:
      - '80:80'
    volumes:
      - '.:/var/www/html'
    depends_on:
      - mysql
      - redis

  mysql:
    image: mysql:8.0             # نفس الإصدار الرئيسي للإنتاج
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

### الأوامر اليومية

```bash
./vendor/bin/sail up -d          # تشغيل البيئة
./vendor/bin/sail artisan migrate
./vendor/bin/sail pest           # تشغيل الـ test suite داخل الـ container
./vendor/bin/sail down           # إيقافها
```

> **قاعدة عملية:** ثبّت إصدار PHP في Docker على نفس الإصدار في CI image (`php:8.2-cli`، انظر [2.2 CI Pipeline](02-ci-pipeline.md)) وعلى server الإنتاج. إصدار واحد، ثلاثة أماكن. عدم تطابق الإصدارات هو انحراف config متنكّر.

---

## Environment Parity (dev / staging / production)

الـ parity يعني أن الأشياء التي تؤثر على كيفية تشغيل الكود متطابقة في كل مكان. وهو **لا** يعني أن البيانات أو الأسرار متطابقة - تلك تختلف عن قصد.

### مصفوفة الـ Parity

| الجانب | Dev (Sail) | CI | Staging | Production |
|--------|-----------|-----|---------|------------|
| إصدار PHP | 8.2 | 8.2 | 8.2 | 8.2 |
| محرك قاعدة البيانات | MySQL 8.0 | SQLite *أو* MySQL 8.0 | MySQL 8.0 | MySQL 8.0 |
| Cache / queue | Redis | array / sync | Redis | Redis |
| `APP_DEBUG` | `true` | `true` | `false` | `false` |
| `APP_ENV` | `local` | `testing` | `staging` | `production` |
| الأسرار | `.env` محلي | `.env.testing` مُضاف | secret store | secret store |

الإصدارات تتطابق عبر كل عمود. فقط أعلام الـ debug، وأسماء البيئات، والأسرار، والبيانات تختلف - وهذه *يجب* أن تختلف.

### قرار SQLite في CI

[2.2 CI Pipeline](02-ci-pipeline.md) يستخدم SQLite in-memory لسرعة الاختبار، بينما يشغّل الإنتاج MySQL. هذه مقايضة مقصودة، ولها ثمن: الاختبارات التي تعتمد على سلوك خاص بـ MySQL (JSON columns، full-text search، صيغة SQL محددة) يمكن أن تنجح على SQLite وتفشل في الإنتاج.

| الخيار | الـ Parity | السرعة | استخدمه عندما |
|--------|------------|--------|----------------|
| SQLite في CI | أقل | سريع | الاختبارات تتجنب SQL خاصاً بقاعدة البيانات (الافتراضي) |
| خدمة MySQL في CI | كامل | +30-60 ثانية بدء | التطبيق يعتمد على ميزات خاصة بـ MySQL |

> **التوصية:** شغّل MySQL محلياً في Sail بغض النظر - تطويرك اليومي يجب أن يكون دائماً على المحرك الحقيقي. أبقِ SQLite في CI فقط كمقايضة سرعة، وبدّل CI إلى خدمة MySQL (الموضّحة في [2.2](02-ci-pipeline.md)) أول مرة تعضّك فيها فجوة SQLite مقابل MySQL.

### بناء parity حقيقي

- **نفس الـ migrations في كل مكان** - لا تعدّل schema الإنتاج يدوياً أبداً. تغييرات الـ schema تمر عبر `php artisan migrate` فقط.
- **خزّن الـ config في الإنتاج** - شغّل `php artisan config:cache` على staging و production (موجود في سكربت النشر من [1.6 Deployment](../phase1/06-deployment.md)). dev يتركها غير مخزّنة للتكرار السريع.
- **طابق drivers الـ queue والـ cache** - إذا استخدم الإنتاج Redis، فـ staging يستخدم Redis. اختبار المسار السعيد على `sync`/`array` والشحن إلى Redis هو فجوة parity.

---

## المتغيرات البيئية

البيئة تُعرَّف بـ `.env` بقدر ما تُعرَّف بـ Docker. انحراف الـ config يختبئ عادة في قيمة `.env` مضبوطة على server ومفقودة على آخر.

### الانضباط

- **`.env.example` هو العقد.** كل متغير يقرأه التطبيق يجب أن يوجد في `.env.example` (بقيمة placeholder آمنة). إنه مُضاف؛ وهو قائمة التحقق لإعداد أي بيئة.
- **ملفات `.env` الحقيقية لا تُضاف أبداً.** `.env` (dev)، و staging، و production لكلٍّ منها ملفه الخاص، يُبقى خارج Git.
- **`.env.testing` هو الاستثناء الوحيد** - يُضاف *لأنه* لا يحتوي أسراراً (انظر [2.2 CI Pipeline](02-ci-pipeline.md)). هذا هو الخط: أضِفه فقط إذا كان تسريبه لا يكلّف شيئاً.
- **أسرار الإنتاج تعيش في secret store**، لا في ملف يستطيع مطور نسخه إلى جهازه.

```bash
# عند إضافة متغير جديد، يذهب إلى مكانين:
.env              # القيمة الحقيقية (غير مُضافة)
.env.example      # placeholder (مُضاف) - حتى لا تفتقده بيئة أحدهم
```

> **قاعدة عملية:** إذا أضفت مفتاحاً إلى `.env`، أضِفه إلى `.env.example` في نفس الـ commit. إدخال مفقود في `.env.example` هو حادثة إنتاج تنتظر النشر التالي.

---

## قائمة التحقق - اكتمل عند

- [ ] Laravel Sail (أو إعداد Docker مكافئ) يشغّل المشروع بـ `sail up`
- [ ] إصدار PHP المحلي يطابق CI image و server الإنتاج (8.2)
- [ ] التطوير المحلي يعمل مقابل MySQL، لا SQLite
- [ ] drivers الـ cache والـ queue تتطابق بين staging و production (مثل Redis)
- [ ] مصفوفة الـ parity موثّقة ومُراجَعة مع الفريق
- [ ] `.env.example` يسرد كل متغير يقرأه التطبيق، بـ placeholders آمنة
- [ ] لا يوجد `.env` حقيقي (dev/staging/prod) مُضاف؛ أسرار الإنتاج في secret store
- [ ] مطور جديد يستطيع الانتقال من `git clone` إلى تطبيق يعمل باستخدام README و Docker فقط
