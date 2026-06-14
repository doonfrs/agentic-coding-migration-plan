# 1.4 سير عمل Git

> workflow Git المكسور هو أول ما يكسر الـ agentic coding. إذا كانت الـ branches فوضوية والـ commits بلا معنى، فلا يملك الذكاء الاصطناعي تاريخاً موثوقاً ليستند إليه - ولا الفريق أيضاً.

---

## الأهداف

- وضع branching strategy تدعم العمل المتوازي دون تعارض
- تطبيق اتفاقية commit message تجعل التاريخ قابلاً للقراءة وصديقاً للأتمتة
- تعريف عملية PR خفيفة تفرض المراجعة دون خلق اختناقات
- حماية الـ branches الحرجة من الـ direct pushes والـ force-pushes
- منح الـ AI assistant (Claude Code) تاريخاً نظيفاً ومنظماً ليعمل منه

---

## استراتيجية التفريع

### النموذج: GitHub Flow (مبسّط)

GitHub Flow هو الخيار الصحيح لمعظم فرق Laravel. بسيط بما يكفي للمطورين المبتدئين، منظم بما يكفي للإنتاج، ويعمل جيداً مع الـ AI-assisted development.

```
main
  └── feature/TICKET-123-add-user-authentication
  └── fix/TICKET-456-correct-invoice-total
  └── chore/update-dependencies
```

| نوع الـ Branch | النمط | الغرض |
|---------------|-------|--------|
| `main` | `main` | كود جاهز للإنتاج. محمي. |
| Feature | `feature/TICKET-ID-short-description` | ميزات جديدة مرتبطة بتذكرة |
| Fix | `fix/TICKET-ID-short-description` | إصلاح أخطاء |
| Chore | `chore/short-description` | صيانة (dependencies، config، docs) |
| Hotfix | `hotfix/short-description` | إصلاحات إنتاجية طارئة |

### قواعد تسمية الـ Branch

- دائماً بأحرف صغيرة، الكلمات مفصولة بـ hyphens
- دائماً يبدأ بنوع الـ prefix (`feature/`، `fix/`، `chore/`، `hotfix/`)
- أضف ticket ID عند وجوده
- حافظ على قِصَر الوصف - أقل من 5 كلمات
- لا slashes باستثناء الفاصل في الـ prefix

**صحيح:**
```
feature/PROJ-101-add-payment-gateway
fix/PROJ-245-fix-null-invoice-total
chore/upgrade-laravel-11
hotfix/revert-broken-migration
```

**خاطئ:**
```
johns-branch
new_feature
feature/added-some-stuff-for-the-payment-thing
```

### دورة حياة الـ Branch

1. أنشئ من `main` - وليس من branch آخر
2. اعمل بـ commits صغيرة ومتكررة
3. افتح PR عند الجاهزية للمراجعة
4. ادمج عبر PR - لا تدمج مباشرة في `main`
5. احذف الـ branch بعد الدمج

---

## اتفاقية رسائل الـ Commit

### الصيغة: Conventional Commits

استخدم [Conventional Commits](https://www.conventionalcommits.org/) - معيار مُعتمد على نطاق واسع يجعل التاريخ قابلاً للقراءة ويُمكّن الـ automated changelogs.

```
<type>(<scope>): <short description>

[optional body]

[optional footer: TICKET-ID, breaking changes, إلخ]
```

### أنواع الـ Commit

| النوع | متى تستخدمه |
|-------|------------|
| `feat` | ميزة جديدة |
| `fix` | إصلاح خطأ |
| `refactor` | تغيير كود لا يصلح خطأ ولا يضيف ميزة |
| `test` | إضافة أو تحديث tests |
| `chore` | build process، تحديثات dependencies، تغييرات config |
| `docs` | توثيق فقط |
| `style` | تغييرات الـ code style (Pint formatting، مسافات - بدون تغيير في المنطق) |
| `perf` | تحسين الأداء |
| `revert` | التراجع عن commit سابق |

### أمثلة

```
feat(auth): add two-factor authentication via TOTP

fix(invoices): correct subtotal calculation when discount is applied

refactor(OrderController): extract order creation to CreateOrderAction

test(InvoiceService): add unit tests for discount edge cases

chore: upgrade Laravel from 10 to 11

docs: update API authentication section in README

style: apply Pint formatting to app/Models

BREAKING CHANGE: remove legacy v1 API endpoints
Closes PROJ-189
```

### قواعد الوصف القصير

- استخدم صيغة الأمر: "add" وليس "added"، "fix" وليس "fixed"
- لا حرف كبير في البداية
- لا نقطة في النهاية
- أقل من 72 حرفاً
- صف *ماذا* يفعل الـ commit، لا *لماذا* (استخدم الـ body للسبب)

### متى تضيف body؟

أضف body عندما:
- التغيير غير واضح ويحتاج سياقاً
- تصف trade-off أو قرار تصميمي
- هناك مرجع ticket أو breaking change

```
refactor(UserService): split authentication and authorization logic

Authentication (من أنت؟) وauthorization (ماذا تستطيع فعله؟) كانا
مختلطين في UserService. تم تقسيمهما إلى AuthService وPolicyService
لاتباع single-responsibility وتسهيل استيعاب الـ AI agent لكل concern
بشكل مستقل.

Closes PROJ-312
```

---

## مراجعة الكود وPull Requests

### قواعد الـ PR

- كل تغيير على `main` يجب أن يمر عبر PR
- الحد الأدنى موافقة مراجع واحد قبل الدمج
- يجب أن تنجح جميع الفحوصات الآلية (Pint، PHPStan، tests)
- يجب أن تكون الـ PRs صغيرة ومركّزة - تغيير منطقي واحد لكل PR
- Draft PRs مشجّعة للحصول على feedback مبكر

### عنوان الـ PR

اتبع نفس اتفاقية الـ commit messages:

```
feat(auth): add two-factor authentication via TOTP
fix(invoices): correct subtotal calculation when discount is applied
```

### قالب وصف الـ PR

أضف `.github/pull_request_template.md` للـ repository:

```markdown
## Summary

<!-- ماذا يفعل هذا الـ PR؟ فقرة واحدة. -->

## Changes

-
-
-

## Testing

<!-- كيف تم الاختبار؟ -->
- [ ] Unit tests مضافة/محدّثة
- [ ] خطوات الاختبار اليدوي منفّذة

## Checklist

- [ ] Pint formatting ناجح
- [ ] PHPStan ناجح
- [ ] Tests ناجحة
- [ ] لا secrets أو debug code في الـ commit
- [ ] Ticket مرتبط (إن وُجد)

Closes #TICKET-ID
```

### إرشادات المراجعة

**للمراجعين:**
- راجع خلال يوم عمل واحد
- ركّز على المنطق والمعمارية والصحة - ليس على الـ style (هذا دور Pint)
- وافق إذا كان الكود صحيحاً ويتبع الاتفاقيات، حتى لو كنت ستفعله بطريقة مختلفة
- اترك تعليقات قابلة للتنفيذ: "فكّر في X لأن Y" وليس فقط "لا يعجبني هذا"

**للمؤلفين:**
- ردّ على جميع التعليقات - إما أصلح أو اشرح لماذا لا
- لا تدمج بدون موافقة
- حافظ على PRs أقل من 400 سطر تغيير قدر الإمكان - الـ PRs الكبيرة تحصل على مراجعات ضعيفة

### الدمج

استخدم **Squash and Merge** لـ feature branches - يحافظ على تاريخ `main` نظيفاً بـ commit واحد لكل feature.

استخدم **Merge Commit** فقط للـ hotfixes حيث تريد الحفاظ على تاريخ الـ commits الدقيق لـ post-mortem.

لا تستخدم **Rebase and Merge** أبداً - يعيد كتابة التاريخ ويكسر `git bisect`.

---

## حماية الفروع

اضبط هذه القواعد على `main` في GitHub/GitLab:

### الإعدادات المطلوبة

| الإعداد | القيمة | السبب |
|---------|--------|--------|
| Require PR before merging | ✅ مفعّل | لا direct pushes على main |
| Required approvals | 1 كحد أدنى | شخص آخر على الأقل يراجع |
| Dismiss stale reviews | ✅ مفعّل | Commits الجديدة تحتاج إعادة موافقة |
| Require status checks to pass | ✅ مفعّل | CI يجب أن ينجح قبل الدمج |
| Require branches to be up to date | ✅ مفعّل | لا دمج لـ branches قديمة |
| Restrict force pushes | ✅ مفعّل | حماية سلامة التاريخ |
| Restrict deletions | ✅ مفعّل | لا أحد يحذف main عن طريق الخطأ |

### GitHub: الإعداد

انتقل إلى: `Repository → Settings → Branches → Add branch protection rule`

Branch name pattern: `main`

فعّل جميع الإعدادات المذكورة أعلاه.

### لماذا هذا مهم للـ Agentic Coding

عندما يعمل Claude Code في الـ agentic mode (Phase 3)، يمكنه إنشاء branches وفتح PRs. حماية الـ branch تضمن أنه حتى لو أخطأ الـ agent، لا يمكنه دمج عمله بدون مراجعة بشرية. فحوصات الـ CI تعمل كشبكة أمان - يجب على الـ agent إنتاج كود يجتاز الفحوصات، لا مجرد كود يبدو معقولاً.

---

## قائمة التحقق - اكتمل عند

- [ ] branching strategy موثّقة ومشاركة مع الفريق
- [ ] جميع المطورين يفهمون اتفاقية تسمية الـ branch
- [ ] Conventional Commits convention مُعتمد - الفريق لديه بطاقة مرجعية
- [ ] قالب الـ PR مُودَع في `.github/pull_request_template.md`
- [ ] قواعد حماية الـ branch مضبوطة على `main`
- [ ] فحوصات الـ CI مرتبطة بحماية الـ branch (انظر [1.6 النشر](06-deployment.md))
- [ ] دورة كاملة واحدة على الأقل مكتملة: branch → commit → PR → review → merge
- [ ] الفريق متفق على squash merge كاستراتيجية افتراضية
