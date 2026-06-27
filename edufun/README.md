# EduFun — تطبيق تعليمي تفاعلي للأطفال (Flutter + PHP + MySQL)

تطبيق فلاتر تعليمي للأطفال (6–9 سنوات) مع باك إند PHP/MySQL يعمل على **XAMPP**.
تمّ تحويل التطبيق من تخزين محلي (`SharedPreferences`) إلى نظام متكامل مع
**بديل محلي تلقائي** عند انقطاع الاتصال (يعمل أوفلاين).

```
Flutter (الواجهة)  ⇄  REST API (PHP)  ⇄  قاعدة بيانات (MySQL/MariaDB) — كلها على XAMPP
```

---

## البنية

```
edufun/
├─ lib/                      # تطبيق فلاتر
│  ├─ app.dart, main.dart    # نقطة الدخول (RTL + ثيم)
│  ├─ core/
│  │  ├─ network/            # ⭐ طبقة الشبكة الجديدة
│  │  │  ├─ api_client.dart          # غلاف HTTP موحّد
│  │  │  ├─ api_config.dart          # يبني baseUrl من IP/البورت
│  │  │  ├─ api_result.dart          # غلاف النتيجة
│  │  │  ├─ connection_settings.dart # حفظ IP/البورت
│  │  │  ├─ connection_settings_dialog.dart  # نافذة إعدادات الاتصال
│  │  │  └─ session.dart             # هوية الطفل الحالي على السيرفر
│  │  ├─ data/               # ⭐ النماذج والريبو
│  │  │  ├─ models/  (child, game_progress, scores)
│  │  │  └─ repositories/ (child, progress, scores)
│  │  ├─ theme/, utils/, widgets/
│  │  └─ utils/
│  │     ├─ score_manager.dart     # ⭐ محوّل: API-first + كاش محلي
│  │     └─ progress_manager.dart  # ⭐ محوّل: API-first + كاش محلي
│  └─ features/             # كل الشاشات (ألعاب/دروس/بوابة آباء/إعدادات...)
├─ backend/                 # ⭐ باك إند PHP (يُنسخ إلى xampp/htdocs/edufun)
│  ├─ db/edufun_schema.sql  # مخطّط القاعدة + بيانات أوّلية (12 لعبة + مجالات)
│  └─ api/                  # ping + CRUD (children/progress/scores/assessment/games)
└─ plans/                   # وثائق الخطة الكاملة (8 ملفات)
```

> التفاصيل الكاملة لكل قرار معماري في `plans/`.

---

## التشغيل السريع

### 1) الباك إند على XAMPP

1. ثبّت XAMPP وشغّل **Apache** و **MySQL**.
2. انسخ محتوى `backend/` إلى `C:\xampp\htdocs\edufun\` لتصبح المسارات:
   ```
   C:\xampp\htdocs\edufun\api\ping.php
   C:\xampp\htdocs\edufun\db\edufun_schema.sql
   ```
3. أنشئ القاعدة: افتح `http://localhost/phpmyadmin` ← **Import** ← اختر
   `backend/db/edufun_schema.sql` ← **Go**.
4. تحقّق: افتح `http://localhost/edufun/api/ping.php` في المتصفح — يجب أن
   يرجع:
   ```json
   {"success":true,"message":"الاتصال ناجح ✅","data":{...}}
   ```

### 2) تطبيق فلاتر

```bash
flutter pub get
flutter run
```

أول ما يفتح التطبيق، اضغط **زرّ السحابة العائم ☁️** (FloatingActionButton) في
الشاشة الرئيسية واضبط:

| المُشغِّل | IP يُكتب | البورت |
|----------|---------|--------|
| متصفّح/سطح مكتب على اللابتوب | `localhost` | `80` |
| محاكي أندرويد | `10.0.2.2` | `80` |
| هاتف أندرويد حقيقي (Wi‑Fi) | IP اللابتوب (مثل `192.168.1.20`) | `80` |
| محاكي iOS | `localhost` | `80` |

ثم اضغط **اختبار الاتصال** ← يجب أن يظهر «الاتصال ناجح ✅» ← **حفظ**.

> **لو فشل الاتصال من هاتف حقيقي رغم صحة الـ IP:** افتح بورت 80 في جدار
> Windows الناري (PowerShell كمسؤول):
> ```powershell
> New-NetFirewallRule -DisplayName "Apache HTTP 80" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
> ```

---

## كيف يعمل التكامل مع السيرفر؟

- **النجوم (`global_stars` سابقاً):** تُقرأ من `children.total_stars` عبر
  `GET /children/?id=`. عند الفشل، تُقرأ من الكاش المحلي.
- **تقدّم الألعاب (`game_done_*` سابقاً):** `ProgressManager.markGameCompleted()`
  يرسل `POST /progress/` ويزيد النجوم **بالفرق فقط** (يمنع تضخّمها عند إعادة
  اللعب). الكاش المحلي يبقى بديلاً أوفلاين.
- **درجات التقييم:** `POST /assessment/` يكتب جدول `assessments` ويُزامن
  `child_scores` دفعة واحدة.
- **بوابة الآباء:** تقرأ `GET /scores/?child_id=` حيّاً، مع بديل محلي.
- **هوية الطفل:** عند أول اتصال نُنشئ/نختار طفلاً افتراضياً على السيرفر
  ونحفظ معرّفه في `SharedPreferences` (مفتاح `server_child_id`). كل الطلبات
  اللاحقة تستخدمه.

كل ذلك **دون تغيير أي شاشة** — فقط أجسام `ScoreManager`/`ProgressManager`
تغيّرت (نفس أسماء الدوال)، فالتطبيق يبقى يعمل أوفلاين عند توقّف السيرفر.

---

## المسارات (Endpoints)

القاعدة: `http://<IP>:<PORT>/edufun/api`

| العملية | الطريقة | المسار |
|---------|---------|--------|
| فحص اتصال | GET | `/ping.php` |
| الأطفال | GET/POST/PUT/DELETE | `/children/` |
| التقدّم | GET/POST | `/progress/` |
| الدرجات | GET/PUT | `/scores/` |
| التقييم | GET/POST | `/assessment/` |
| الألعاب | GET/POST/PUT/DELETE | `/games/` |

التوثيق الكامل في `plans/04-api-documentation.md`.

---

## استكشاف الأخطاء

| العَرَض | الحل |
|--------|------|
| `ping.php` يعمل على اللابتوب لا على الهاتف | افتح بورت 80 في جدار Windows الناري |
| فشل الاتصال من المحاكي | استخدم `10.0.2.2` بدل `localhost` |
| `ERR_CLEARTEXT_NOT_PERMITTED` | `android:usesCleartextTraffic="true"` (مُفعّل افتراضياً هنا) |
| حروف عربية «؟؟؟» | ترميز `utf8mb4` (مُعالَج في `database.php`) |
| التطبيق لا ينهار عند توقّف السيرفر | ✅ هذا متعمّد — يعمل بالكاش المحلي (وضع البديل) |
