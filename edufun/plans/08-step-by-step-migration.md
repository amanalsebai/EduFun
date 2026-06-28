# 08 — خطوات التنفيذ بالترتيب + قائمة تحقّق

خطة تنفيذ عملية مقسّمة إلى مراحل. نفّذها بالترتيب؛ كل مرحلة تنتهي بنقطة تحقّق
يمكن اختبارها قبل الانتقال للتالية.

---

## المرحلة 0 — التحضير

- [ ] تثبيت XAMPP وتشغيل Apache + MySQL (الملف 07).
- [ ] التأكّد أن `http://localhost` يفتح صفحة XAMPP.
- [ ] أخذ نسخة احتياطية / فرع git جديد قبل أي تعديل على `untitled1/`.

> **نقطة تحقّق:** صفحة XAMPP تظهر، وأنت على فرع git منفصل.

---

## المرحلة 1 — قاعدة البيانات (Backend Data)

- [ ] إنشاء `C:\xampp\htdocs\edufun\db\edufun_schema.sql` (الملف 02).
- [ ] استيراد المخطّط عبر phpMyAdmin أو سطر الأوامر.
- [ ] تشغيل سكربت الـ Seed (المجالات + 12 لعبة + طفل تجريبي).
- [ ] التحقّق في phpMyAdmin أن الجداول والبيانات موجودة.

> **نقطة تحقّق:** القاعدة `edufun_db` فيها 6 جداول وبيانات أوّلية صحيحة.

---

## المرحلة 2 — الباك إند PHP (CRUD + API)

- [ ] إنشاء بنية `htdocs/edufun/api/` (الملف 03).
- [ ] ملفات `config/database.php` و `config/cors.php` و `helpers/response.php`.
- [ ] `ping.php` ثم اختباره: `http://localhost/edufun/api/ping.php`.
- [ ] `children/index.php` (CRUD كامل) واختباره بـ curl/المتصفح.
- [ ] `progress/index.php` (مع زيادة النجوم + transaction).
- [ ] `scores/index.php` و `assessment/index.php` و `games/index.php`.

> **نقطة تحقّق:** كل مسارات الملف 04 ترجع JSON صحيحاً عبر curl. اختبر:
> ```bash
> curl http://localhost/edufun/api/ping.php
> curl -X POST http://localhost/edufun/api/children/ -H "Content-Type: application/json" -d '{"name":"سارة","age":7}'
> curl http://localhost/edufun/api/children/
> ```

---

## المرحلة 3 — طبقة الشبكة في فلاتر

- [ ] إضافة `http` إلى `pubspec.yaml` ثم `flutter pub get` (الملف 05).
- [ ] إنشاء `core/network/`: `connection_settings.dart`, `api_config.dart`,
      `api_result.dart`, `api_client.dart`.
- [ ] إضافة إذن الإنترنت + `usesCleartextTraffic` في `AndroidManifest.xml`.

> **نقطة تحقّق:** كود يبني (`flutter analyze` نظيف) ولو لم يُربط بالواجهات بعد.

---

## المرحلة 4 — زر الاتصال (FAB)

- [ ] إنشاء `connection_settings_dialog.dart` (الملف 06).
- [ ] إضافة `FloatingActionButton` للشاشة الرئيسية.
- [ ] تشغيل التطبيق، فتح الزر، إدخال IP/البورت، **اختبار الاتصال** ← ✅.

> **نقطة تحقّق:** زر «اختبار الاتصال» يعطي «ناجح ✅» مقابل سيرفر XAMPP حيّ.
> هذه أهم نقطة: تثبت أن فلاتر ↔ PHP ↔ MySQL تعمل من طرف إلى طرف.

---

## المرحلة 5 — ربط الكيانات (تحويل المديرين)

نحوّل ميزة واحدة في كل مرة، ونختبرها، قبل التالية:

- [ ] **النماذج والريبو:** `child.dart`, `child_repository.dart`, …
- [ ] **التقدّم:** تحويل `ProgressManager.markGameCompleted` لاستدعاء `/progress/`
      مع الإبقاء على الكاش المحلي (الملف 05).
- [ ] **النجوم:** تحويل `ScoreManager` لقراءة `total_stars` من السيرفر مع بديل محلي.
- [ ] **التقييم:** ربط `assessment_screen` بـ `POST /assessment/`.
- [ ] **لوحة وليّ الأمر:** `parent_portal_screen` يقرأ الدرجات من `GET /scores/`
      بدل `SharedPreferences`.
- [ ] **اختيار الطفل:** ضبط `ScoreManager.currentChildId` بعد اختيار/إنشاء الطفل.

> **نقطة تحقّق:** افتح لعبة، افز بها، ثم راقب في phpMyAdmin أن صفّاً أُضيف في
> `game_progress` و `children.total_stars` زاد. لوحة وليّ الأمر تعرض القيم الحيّة.

---

## المرحلة 6 — المتانة (Resilience) والإنهاء

- [ ] التأكّد أن التطبيق لا ينهار عند توقّف السيرفر (وضع البديل المحلي يعمل).
- [ ] رسائل خطأ واضحة للمستخدم عند فشل الاتصال.
- [ ] اختبار على هاتف حقيقي عبر IP اللابتوب (الملف 07).
- [ ] توثيق الـ IP/البورت المستخدمَين في README المشروع.

> **نقطة تحقّق:** التطبيق يعمل أونلاين (بيانات حيّة) وأوفلاين (كاش) دون انهيار.

---

## ترتيب الاعتمادية (ماذا يعتمد على ماذا)

```
المرحلة 1 (DB)
   └─> المرحلة 2 (PHP API)         ← يحتاج الجداول
          └─> المرحلة 3 (طبقة شبكة فلاتر)  ← يحتاج API يعمل
                 └─> المرحلة 4 (FAB)        ← يحتاج طبقة الشبكة
                        └─> المرحلة 5 (ربط الميزات) ← يحتاج اتصالاً مثبتاً
                               └─> المرحلة 6 (متانة)
```

ابدأ من الأسفل (قاعدة البيانات) وتصاعد. لا تربط ميزة قبل أن ينجح زر الاتصال.

---

## ملخّص ربط الكيانات القديمة بالجديدة

| المحلي الحالي (SharedPreferences) | البديل الجديد (API + DB) |
|-----------------------------------|--------------------------|
| `global_stars` | `children.total_stars` ← `GET/PUT /children/` |
| `game_done_<id>` | `game_progress.completed` ← `POST /progress/` |
| `score_math/language/logic` | جدول `child_scores` ← `GET/PUT /scores/` |
| `child_age` | `children.age` |
| نتيجة التقييم | جدول `assessments` ← `POST/GET /assessment/` |
| `ProgressManager.gamesByAge` | جدول `games` (seed) ← `GET /games/` |

> الفكرة الجوهرية: **أسماء الدوال في `ScoreManager`/`ProgressManager` تبقى كما هي**،
> فلا تتأثّر الواجهات؛ يتغيّر فقط ما يحدث داخلها (سيرفر بدل تخزين محلي + كاش بديل).
