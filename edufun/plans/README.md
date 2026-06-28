# خطة تحويل EduFun من فرونت إند محلي إلى نظام (Flutter + PHP + MySQL)

هذا المجلد يوثّق **خطة كاملة** لتحويل تطبيق EduFun من تطبيق فلاتر يحفظ بياناته محلياً
عبر `SharedPreferences` إلى نظام متكامل:

```
Flutter (الواجهة) ⇄ REST API (PHP) ⇄ قاعدة بيانات (MySQL) — كلّها تعمل على XAMPP
```

الباك إند يعمل على جهاز اللابتوب عبر **XAMPP** على المسار:

```
http://localhost:80/edufun        ← من نفس اللابتوب (متصفح/محاكي)
http://<IP-اللابتوب>:80/edufun     ← من تطبيق فلاتر على هاتف حقيقي
```

ومن داخل فلاتر يضيف المستخدم زر اتصال عائم (`FloatingActionButton`) يفتح نافذة
لإدخال **IP اللابتوب** و**رقم البورت** واختبار الاتصال قبل الحفظ.

---

## الوضع الحالي (Before)

- التطبيق الفعلي موجود في مجلد `untitled1/` (بنية feature-based).
- لا يوجد سيرفر ولا قاعدة بيانات؛ كل البيانات محلية على الجهاز عبر `SharedPreferences`:
  - `global_stars` — مجموع النجوم.
  - `game_done_<gameId>` — هل أنهى الطفل لعبة معيّنة.
  - `score_math` / `score_language` / `score_logic` — درجات التقييم لكل مجال.
  - `child_age` — عمر الطفل المختار.
- النتيجة: البيانات لا تُشارَك بين الأجهزة، ولا توجد لوحة متابعة مركزية لوليّ الأمر،
  وتضيع البيانات عند حذف التطبيق.

## الوضع المستهدف (After)

- قاعدة بيانات MySQL مركزية تخزّن الأطفال، الألعاب، التقدّم، الدرجات، النجوم، والتقييمات.
- باك إند PHP يوفّر **REST API** بأنظمة **CRUD** كاملة لكل كيان.
- فلاتر يتصل بالـ API عبر طبقة شبكة منظّمة، مع إمكانية ضبط عنوان السيرفر من داخل التطبيق.
- لوحة وليّ الأمر تقرأ بيانات حيّة من السيرفر بدل القراءة المحلية.

---

## فهرس الملفات

| # | الملف | المحتوى |
|---|-------|---------|
| 00 | [README.md](README.md) | هذا الملف — نظرة عامة وفهرس |
| 01 | [01-overview-architecture.md](01-overview-architecture.md) | المعمارية، الفرق بين قبل/بعد، تدفّق البيانات |
| 02 | [02-database-schema.md](02-database-schema.md) | تصميم قاعدة بيانات MySQL + سكربت `edufun_schema.sql` |
| 03 | [03-php-backend-crud.md](03-php-backend-crud.md) | هيكلة باك إند PHP وأنظمة CRUD كاملة |
| 04 | [04-api-documentation.md](04-api-documentation.md) | توثيق الـ API: كل المسارات، الطلبات والاستجابات |
| 05 | [05-flutter-integration.md](05-flutter-integration.md) | ربط فلاتر: طبقة API، النماذج، استبدال التخزين المحلي |
| 06 | [06-connection-fab.md](06-connection-fab.md) | زر الاتصال العائم + نافذة إعدادات IP/البورت |
| 07 | [07-xampp-setup.md](07-xampp-setup.md) | إعداد XAMPP، المسار `/edufun`، الشبكة والجدار الناري |
| 08 | [08-step-by-step-migration.md](08-step-by-step-migration.md) | خطوات التنفيذ بالترتيب + قائمة تحقّق |

> اقرأ الملفات بالترتيب. كل ملف يفترض أنك فهمت ما قبله.

---

## ملخّص المسارات (Endpoints) بنظرة سريعة

القاعدة (Base URL): `http://<IP>:<PORT>/edufun/api`

| المورد | المسار | العمليات |
|--------|--------|----------|
| فحص الاتصال | `/ping.php` | GET |
| الأطفال | `/children/` | GET, POST, PUT, DELETE (CRUD) |
| التقدّم | `/progress/` | GET, POST, PUT, DELETE |
| الدرجات | `/scores/` | GET, PUT |
| التقييم | `/assessment/` | GET, POST |
| الألعاب (كتالوج) | `/games/` | GET (CRUD للإدارة) |

التفاصيل الكاملة في [04-api-documentation.md](04-api-documentation.md).
