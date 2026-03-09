# 1.1 Codebase & Architecture Review

> قبل كتابة سطر واحد من الكود الجديد — أو إعطاء أي أمر للذكاء الاصطناعي — يجب أن تفهم ما تعمل عليه. هذه المراجعة تهدف إلى رؤية الـ codebase بصدق، وليس إصلاحه بعد.

---

## الأهداف

- الحصول على صورة واضحة عن الوضع الحالي: الـ structure، الأنماط، والتناقضات
- تحديد المناطق الآمنة للتعديل مقابل المناطق ذات المخاطر العالية
- إنشاء baseline document مشترك يتفق عليه كامل الفريق
- تجهيز الأرضية لمساعدة الذكاء الاصطناعي — الـ agent يحتاج context ليكون مفيداً

---

## ما الذي نراجعه؟

### Folder Structure
- هل يتبع اتفاقيات Laravel؟ (`app/`، `routes/`، `resources/`، إلخ)
    - *شغّل `ls app/` — يجب أن ترى `Models/`، `Http/`، `Providers/`. أي شيء آخر؟ دوّنه.*
- هل توجد custom folders تحيد عن المعيار؟ وثّقها.
    - *مثل: `app/Helpers/`، `app/Libs/`، `app/Core/` — لاحظ ما بداخلها ولماذا توجد.*
- هل business logic مبعثر في الـ controllers، أم منظم في services أو repositories؟
    - *افتح أي controller كبير. إذا كان يحتوي على DB queries وإرسال بريد وتوليد PDF — فهو مبعثر.*

### Routing
- هل الـ routes RESTful أم عشوائية؟
    - *افتح `routes/web.php` و `routes/api.php`. RESTful = `GET /users`، `POST /users`. عشوائي = `GET /doSomethingWithUser`.*
- هل أسماء الـ routes متسقة؟
    - *شغّل `php artisan route:list` — افحص عمود الـ Name. هل تتبع نمطاً مثل `users.index`، `users.store`؟*
- هل توجد orphaned routes تشير إلى controllers محذوفة؟
    - *شغّل `php artisan route:list` — أي أخطاء أو إشارات لـ controllers مفقودة ستظهر هنا.*

### Controllers
- هل الـ controllers thin (تفوّض المنطق) أم fat (تحتوي على كل شيء)؟
    - *الـ thin method تكون 5–15 سطراً. إذا كانت الـ method 50+ سطر — فهي fat.*
- هل يوجد منطق مكرر عبر controllers متعددة؟
    - *ابحث عن كتل نُسخت ولصقت — نفس validation rules، نفس الـ queries في أماكن متعددة.*
- هل validation rules مضمّنة أم تستخدم Form Requests؟
    - *مضمّنة: `$request->validate([...])` داخل الـ controller. أفضل: dedicated class مثل `StoreUserRequest`.*

### Models & Database
- هل Eloquent relationships معرّفة ومستخدمة بشكل صحيح؟
    - *افتح بعض الـ models — هل تحتوي على `hasMany`، `belongsTo`، إلخ؟ أم أن الـ joins تتم يدوياً في الـ controllers؟*
- هل توجد raw queries حيث يجب استخدام Eloquent؟
    - *ابحث عن `DB::statement`، `DB::select` مع raw SQL strings — هذه أصعب في الصيانة والاختبار.*
- هل database schema موثق في أي مكان؟
    - *ابحث عن ERD أو README أو حتى تعليق. إذا لم يوجد شيء — يجب إنشاؤه.*
- هل الـ migrations متزامنة مع الـ database الفعلية، أم أن أحدهم عدّل الـ database يدوياً؟
    - *شغّل `php artisan migrate:status` — أي `Pending` migrations أو entries مفقودة = red flag.*

### Dependencies
- راجع `composer.json` — هل جميع الـ packages لا تزال مستخدمة؟
    - *افتح `composer.json` وابحث عن اسم كل package في الـ codebase. إذا لم تظهر في أي مكان — ربما غير ضرورية.*
- هل توجد packages قديمة أو متروكة؟
    - *شغّل `composer outdated` — ركز على الـ packages المصنّفة abandoned أو ذات major version gaps.*
- هل إصدار Laravel لا يزال يتلقى security updates؟
    - *تحقق من [laravel.com/docs/releases](https://laravel.com/docs/releases) — الإصدارات الأقدم من آخر إصدارين رئيسيين خارج الدعم.*

### Configuration & Environment
- هل البيانات الحساسة مكتوبة مباشرة في الكود (passwords، API keys)؟
    - *ابحث عن كلمات مثل `password`، `secret`، `api_key` في ملفات `.php` خارج مجلد config. أي نتائج = خطر فوري.*
- هل ملف `.env` مستثنى من git بشكل صحيح؟
    - *شغّل `git ls-files .env` — إذا أعاد أي شيء، الملف متابَع في git. هذه مشكلة أمنية.*
- هل توجد environment-specific hacks في الكود؟
    - *ابحث عن `if (env('APP_ENV') === 'production')` داخل business logic — هذه fragile وصعبة الاختبار.*

### Code Quality Signals
- هل يوجد commented-out code متروك في مكانه؟
    - *بضعة أسطر أمر طبيعي. صفحات من الكود المعلّق = الفريق خائف من الحذف = لا ثقة بالـ version control.*
- هل توجد `dd()`، `var_dump()`، أو debug statements في الكود؟
    - *شغّل `grep -r "dd(" app/` — أي نتائج في production code يجب إزالتها فوراً.*
- هل يوجد error handling، أم أن الـ exceptions تُبتلع صامتة؟
    - *ابحث عن empty catch blocks: `catch (\Exception $e) {}` بدون شيء بداخلها = silent failures.*

---

## مستويات مراجعة مخرجات الذكاء الاصطناعي

كجزء من هذه المراجعة، صنّف كل منطقة رئيسية في الـ codebase بمستوى المراجعة المطلوب:

| المنطقة | مستوى المراجعة | ما يعنيه |
|---------|---------------|----------|
| Boilerplate CRUD | 🟢 Quick Review | تصفّحه، شغّل الـ tests، ادمجه |
| Blade views / UI | 🟢 Quick Review | تحقق منه بصرياً في المتصفح |
| Test generation | 🟢 Quick Review | اقرأ الـ assertions، شغّل الـ suite |
| Documentation | 🟢 Quick Review | اقرأ للدقة، ادمجه |
| API integrations (3rd party) | 🟡 Standard Review | تحقق من input/output contracts ومعالجة الأخطاء |
| Business rules / core logic | 🟡 Standard Review | المطور يجب أن يفهم المنطق ويتملّكه |
| Authentication & Authorization | 🔴 Senior Review | سطراً بسطر — افتراض خاطئ هنا = ثغرة أمنية |
| Payment / financial logic | 🔴 Senior Review | كل edge case مهم — اختبر بشكل مكثف على staging |
| Database migrations | 🔴 Senior Review | شغّلها على نسخة من بيانات production أولاً، بلا استثناء |

---

## Output / Deliverables

بنهاية هذه المراجعة، أنتج وثيقة مشتركة واحدة تحتوي على:

1. **Architecture Map** — نظرة عامة نصية أو مخططاتية لكيفية بناء التطبيق
2. **Pain Points List** — مشاكل ملموسة وُجدت (مثل: "UserController يحتوي 800 سطر"، "لا migrations لجدول orders")
3. **AI Scope Map** — الجدول أعلاه مُكمَّل لهذا المشروع تحديداً
4. **Risk Register** — الـ 3–5 مناطق الأكثر احتمالاً لإحداث مشاكل أثناء الانتقال
5. **Open Questions** — أشياء تحتاج توضيحاً من الفريق قبل المتابعة

---

## كيفية إجراء المراجعة

- نفّذها كـ team session (وليس solo) — الفهم المشترك هو الهدف
- استخدم الـ codebase كما هو، لا تُعيد هيكلته أثناء المراجعة
- حدد وقتاً محدداً لها: 1–2 جلسات مركزة، وليس audit لا نهاية له
- اعرض الـ deliverables في وثيقة مشتركة يستطيع الجميع الوصول إليها والتعليق عليها
