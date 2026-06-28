# خطة التحسينات التالية لـ EduFun (للتنفيذ عبر وكيل فرعي)

هذا المجلد يحتوي خطّة من **3 مهام مستقلّة**، كل ملف قابل للتنفيذ وحده. نفّذها بالترتيب
المقترح: `01 → 03 → 02`.

> اقرأ هذا الملف كاملاً **قبل** أي مهمة — يحتوي السياق والثوابت التي تفترضها كل المهام.

---

## سياق المشروع (ثوابت مهمة لكل المهام)

| العنصر | القيمة |
|---|---|
| جذر مشروع Flutter | `C:\Users\Abdalgani\Desktop\wpu\EduFun\edufun` |
| مصدر الباك إند (نسخة العمل) | `edufun\backend\` |
| الباك إند المنشور (الحيّ) | `C:\xampp\htdocs\edufun\` |
| قاعدة البيانات | `edufun_db` (MySQL، مستخدم `root` بلا كلمة مرور) |
| أداة mysql | `C:\xampp\mysql\bin\mysql.exe` |
| قاعدة الـ API | `http://localhost/edufun/api` |
| أمر Flutter | `C:\cores\flutter\bin\flutter` |

### المسارات (Endpoints) المتوفّرة
`/ping.php` · `/children/` · `/videos/` · `/questions/` · `/games/` · `/progress/` · `/scores/` · `/assessment/`
— كلها CRUD على نمط `children/index.php`، وتُرجع غلافاً موحّداً `{success, message, data}`.

### طبقة الشبكة في Flutter
- `lib/core/network/api_client.dart` — `ApiClient.get/post/put/delete` (تُرجع `ApiResult`).
- `lib/core/network/api_config.dart` — يبني `baseUrl` من إعدادات الاتصال.
- `lib/core/network/connection_settings.dart` — حفظ/قراءة الـ IP والبورت.
- `lib/core/network/session.dart` — هوية الطفل الحالي (`registerNewChild` / `ensureChild`).

---

## ⚠️ مزالق إلزامية (تجنّبها وإلا فسد العمل)

1. **بعد أي تعديل في `backend\`، انسخ الملف إلى `C:\xampp\htdocs\edufun\`** — السيرفر الحيّ يقرأ من `htdocs` فقط. النسختان يجب أن تبقيا متطابقتين.
2. **استيراد SQL يجب أن يفرض utf8mb4** وإلا تَلِف النص العربي (يصبح mojibake):
   ```
   & "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 edufun_db < "ملف.sql"
   ```
3. **Git Bash يُفسد العربي داخل وسائط `curl`** (مثل `--data-urlencode "x=عربي"`). لاختبار مسارات الكتابة استخدم المتصفّح (Playwright) أو جسم طلب من ملف — لا تكتب العربي مباشرة في سطر الأوامر.
4. **تحقّق من الترميز عبر HEX** عند الشك:
   `SELECT HEX(col) ...` — حروف عربية سليمة تبدأ بـ `D8`/`D9`، والإيموجي بـ `F0`.
5. **لا تكسر الوضع المحلي (offline):** كل قراءة من السيرفر يجب أن يكون لها بديل محلي عند فشل الاتصال (النمط المتّبع في `lessons_screen` و `assessment_screen`).

---

## التحقّق العام بعد كل مهمة
- `C:\cores\flutter\bin\flutter analyze <الملفات المعدّلة>` → بلا أخطاء (تحذيرات `withOpacity` قديمة ومقبولة).
- اختبر الـ Endpoint المعني بـ `curl http://localhost/edufun/api/...` (قراءة فقط آمنة في Git Bash).

---

## ملفات الخطة

| # | الملف | الهدف | الأولوية |
|---|------|------|---------|
| 01 | [01-fix-connection-ip.md](01-fix-connection-ip.md) | إصلاح فخّ الـ IP: زرّ اتصال في الـ onboarding + قيمة افتراضية ذكية حسب المنصّة | **عالية** |
| 03 | [03-live-verification.md](03-live-verification.md) | تشغيل حيّ والتأكّد أنّ طفلاً جديداً يُضاف فعلاً للقاعدة | **عالية** |
| 02 | [02-games-from-db.md](02-games-from-db.md) | ربط كتالوج الألعاب بالقاعدة (أكبر مهمة) | متوسطة |

> السبب في ترتيب `01 ← 03`: المهمة 01 تجعل التسجيل ينجح من أول مرة، والمهمة 03 تُثبت ذلك. المهمة 02 أكبر وتُؤجَّل.
