# Agentic Coding Migration Plan

> خطة منظمة لمدة 3 أشهر للانتقال التدريجي بفريق Laravel من أسلوب التطوير التقليدي غير المقنن إلى البرمجة بمساعدة الذكاء الاصطناعي - دون المساس بما هو موجود في production.

---

## Phase 1 - Stabilize & Standardize · الشهر الأول

**الهدف:** تسليم المشروع الحالي في موعده مع بناء coding standards وانضباط Git الذي يجعل مساعدة الذكاء الاصطناعي آمنة وفعّالة.

> الذكاء الاصطناعي يضخّم ما هو موجود. إذا كان الـ codebase بلا معايير، سينتج الـ agent المزيد من نفس الفوضى. المعايير تأتي أولاً.

- [1.1 Codebase & Architecture Review](./phase1/01-codebase-architecture.md)
- [1.2 Laravel Standards](./phase1/02-laravel-standards.md)
- [1.3 Tooling Selection](./phase1/03-tooling-selection.md)
- [1.4 Git Workflow](./phase1/04-git-workflow.md)
- [1.5 Claude Code بالتفصيل](./phase1/05-claude-code.md)
- [1.6 النشر](./phase1/06-deployment.md)

**النتيجة المتوقعة:** مشروع مستقر + codebase conventions متسقة + Git workflow منضبط - أساس نظيف للذكاء الاصطناعي

---

## Phase 2 - Safety Nets & Supervised AI · الشهر الثاني

**الهدف:** بناء شبكات الأمان الآلية التي تتيح للفريق استخدام مساعدة الذكاء الاصطناعي دون خوف من regression، وتقديم الذكاء الاصطناعي بوصفه junior developer تحت الإشراف.

- [2.1 Testing](./phase2/01-testing.md)
- [2.2 CI Pipeline](./phase2/02-ci-pipeline.md)
- [2.3 Environment](./phase2/03-environment.md)
- [2.4 Supervised AI Introduction](./phase2/04-supervised-ai.md)

**النتيجة المتوقعة:** automated safety net جاهز + فريق مرتاح لاستخدام الذكاء الاصطناعي تحت الإشراف

---

## Phase 3 - Go Agentic · الشهر الثالث

**الهدف:** ترسيخ منهجية Agentic Coding التي يستطيع الفريق تشغيلها باستقلالية، مع تعريف agent roles وKPIs والسياسات الداخلية.

- [3.1 Agentic Methodology](./phase3/01-agentic-methodology.md)
- [3.2 CI/CD Maturity](./phase3/02-cicd-maturity.md)
- [3.3 Team Enablement](./phase3/03-team-enablement.md)
- [3.4 Governance](./phase3/04-governance.md)

**النتيجة المتوقعة:** فريق agentic يعمل بالكامل - مستقل، مدفوع بالسياسات، قابل للقياس

---

## أسلوب العمل

- اجتماعان أسبوعيان للإشراف (مراجعة التقدم، رفع العقبات، hands-on coaching)
- الجودة والاستقرار قبل السرعة - لا shortcuts
- مزيج من الجلسات النظرية وتطبيق المهام الحقيقية
- تدخل مباشر عند ظهور blockers
- كل phase تنتهي بـ retrospective للفريق قبل الانتقال للتالية

---

## لماذا هذا الترتيب؟

| الخطر | الحل |
|-------|------|
| الذكاء الاصطناعي يعزز أنماط الكود السيئة | Standards تُطبَّق في Phase 1 قبل تقديم الذكاء الاصطناعي |
| أخطاء الذكاء الاصطناعي تصل إلى production | Tests + CI gate تُقدَّم في Phase 2 قبل توسيع استخدام الذكاء الاصطناعي |
| الفريق يتبنى الذكاء الاصطناعي بدون إشراف | Supervised phase قبل autonomous agent workflows |
| لا توجد طريقة لقياس التحسن | KPIs وbaselines تُسجَّل قبل بدء الـ agentic phase |
