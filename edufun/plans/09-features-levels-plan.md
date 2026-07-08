# الخطة 09 — الصوتيات، البطاقات التعليمية، نظام النقاط، والمراحل من الباك إند

> **المشروع المستهدف:** `Desktop/wpu/EduFun/edufun` (النسخة المربوطة بالباك إند PHP/MySQL).
> النسخة `untitled1` تُستخدم فقط كمصدر لنقل ميزة الصوت منها.

---

## المرحلة 0 — نقل الموسيقى والتأثيرات الصوتية (من untitled1)

الميزة موجودة جاهزة في `untitled1` (commit: audio manager + background music + win sound). ننقلها إلى `edufun`:

1. **pubspec.yaml**: إضافة `audioplayers: ^6.0.0` تحت dependencies، وإضافة `- assets/audio/` تحت assets.
2. **نسخ** `untitled1/lib/core/utils/audio_manager.dart` → `edufun/lib/core/utils/audio_manager.dart`.
3. **⚠️ ملفات الصوت**: الموجود في `untitled1/assets/audio/` هو اختصارات ويندوز (`background.mp3.lnk`, `win_sound.mp3.lnk`) — **لن تعمل كـ asset في Flutter**. يجب وضع ملفات mp3 الحقيقية في `edufun/assets/audio/background.mp3` و `win_sound.mp3`.
4. **الربط في الكود** (بنفس أسلوب untitled1):
   - `main.dart`: تشغيل `AudioManager.playBackgroundMusic()` عند الإقلاع.
   - `settings_screen.dart`: مفتاحا تبديل (موسيقى / مؤثرات) يكتبان `music_enabled` و `sound_enabled` في SharedPreferences، مع إيقاف/تشغيل فوري.
   - كل شاشات الألعاب الـ 12 (`features/games/**`): استدعاء `AudioManager.playWinSound()` عند الفوز (نفس نقطة استدعاء `ProgressManager.markGameCompleted`).
5. **إضافات مقترحة**: صوت خطأ/محاولة خاطئة (`wrong.mp3`) وصوت نقرة للبطاقات (`flip.mp3`) — نفس النمط في `AudioManager`.

---

## المرحلة 1 — تحديث البطاقات التعليمية

### 1.أ — بطاقات عمر 6–7 (`flashcards_screen_6_to_7.dart`)

التصنيفات الحالية: زوجي/فردي، مضاعفات (بطاقتان فقط: 2 و5)، أكبر/أصغر (بطاقتان).

| التصنيف | التعديل |
|---|---|
| مضاعفات الأعداد | توليد **9 بطاقات: مضاعفات 2 حتى 10** — كل بطاقة: الوجه "مضاعفات العدد n؟"، الخلف أول 5 مضاعفات + تلميح "نزيد n في كل مرة!". تُولَّد بحلقة بدل النسخ اليدوي. |
| الأكبر والأصغر | إبقاء بطاقتي التعريف + إضافة **بطاقات أمثلة**: (7 ؟ 3)، (12 ؟ 15)، (9 ؟ 9 → التساوي =)، مع شرح "التمساح يفتح فمه للعدد الأكبر". |
| زوجي/فردي | كما هي. |

### 1.ب — بطاقات عمر 8–9 (`flashcards_screen_8_to_9.dart`)

| التصنيف | التعديل |
|---|---|
| جداول الضرب | **8 بطاقات: جدول كامل لكل عدد من 2 إلى 9**. كل بطاقة تعرض على ظهرها الجدول كاملاً (n×1 حتى n×10). ظهر البطاقة الحالي (`flip_card.dart`) مصمم لسطرين نص — نضيف وضع عرض جديد للبطاقة (خلف قابل للتمرير/جدول مصغّر) أو شاشة تفصيلية تفتح عند الضغط. |
| أساسيات القسمة (جديد) | تصنيف جديد: بطاقات "ما هي القسمة؟" (توزيع بالتساوي)، العلاقة بالضرب (12÷3 → فكّر 3×؟=12)، أمثلة محلولة خطوة بخطوة (مثلاً 15÷5 بطريقة التوزيع)، القسمة على 1 وعلى نفس العدد. |
| أساسيات الإعراب (جديد/توسعة) | بطاقات: ما هو الفعل/الفاعل/المفعول به، علامات الرفع والنصب الأساسية، مع أمثلة معربة ("كتبَ الطالبُ الدرسَ" — إعراب كل كلمة على بطاقة). |

**اقتراح معماري:** فصل محتوى البطاقات عن الواجهة في ملف بيانات `lib/features/flashcards/data/flashcards_data.dart` (قوائم ثابتة لكل تصنيف) بدل تضمينها داخل الـ widget — يسهّل لاحقاً نقلها لجدول `flashcards` في القاعدة وإدارتها من لوحة admin (خطوة اختيارية مؤجلة).

---

## المرحلة 2 — نظام النقاط وفتح مستوى العمر التالي

**المطلوب:** مستخدم جديد يبدأ بـ 0 نقطة، ومستوى العمر التالي لا يُفتح إلا بإكمال كل مراحل عمره — **بحكم من السيرفر**.

الوضع الحالي: `children.total_stars` يبدأ 0 (سليم)، لكن قرار "اكتمل العمر" يُحسب محلياً من SharedPreferences (`ProgressManager.isAgeCompleted`).

1. **تصفير حقيقي للمستخدم الجديد:** عند `Session.registerNewChild()` (في `name_input_screen.dart` / `session.dart`) يجب **مسح كل مفاتيح** `game_done_*` و `level_done_*` وكاش النجوم من SharedPreferences — حالياً الطفل الجديد على نفس الجهاز يرث تقدم الطفل السابق.
2. **نقطة الحقيقة على السيرفر:** endpoint جديد `GET /api/children/{id}/unlocks` يعيد:
   ```json
   { "ages": { "6": {"completed": 3, "total": 3, "unlocked": true},
               "7": {"completed": 1, "total": 3, "unlocked": true},
               "8": {"completed": 0, "total": 3, "unlocked": false}, ... },
     "total_stars": 150 }
   ```
   منطق الفتح: العمر الأساسي للطفل مفتوح دائماً + كل عمر تالٍ يُفتح فقط إذا اكتمل الذي قبله (يُحسب من `game_progress`/`level_progress`).
3. **فلاتر:** `ProgressManager.isAgeCompleted/nextAgeIfUnlocked` تسأل السيرفر أولاً (مع الكاش المحلي fallback عند الانقطاع — نفس نمط `markGameCompleted` الحالي). `NextLevelUnlockCard` وشاشات الأعمار الأربع تقرأ من هذه النتيجة.
4. **حماية على السيرفر:** رفض `POST /progress/` (أو levels) للعبة من عمر غير مفتوح للطفل → `403`، حتى لا يتجاوز العميل القفل.

---

## المرحلة 3 — نظام المراحل لكل لعبة (Backend-driven)

**الهدف:** كل لعبة من الألعاب الـ 12 تصبح متعددة المراحل، تعريف المراحل وتقدمها من قاعدة البيانات.

### 3.أ — قاعدة البيانات (ملف migration جديد `db/edufun_levels.sql`)

```sql
-- تعريف المراحل لكل لعبة (يُدار من لوحة admin)
CREATE TABLE IF NOT EXISTS game_levels (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  game_code    VARCHAR(40) NOT NULL,
  level_number TINYINT NOT NULL,
  title_ar     VARCHAR(100) NOT NULL DEFAULT '',
  stars_reward INT NOT NULL DEFAULT 20,
  config       JSON NULL,             -- إعدادات المرحلة (صعوبة/أسئلة/نطاق أرقام)
  UNIQUE KEY uq_game_level (game_code, level_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- تقدم الطفل على مستوى المرحلة
CREATE TABLE IF NOT EXISTS level_progress (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  child_id     INT NOT NULL,
  game_code    VARCHAR(40) NOT NULL,
  level_number TINYINT NOT NULL,
  completed    TINYINT(1) NOT NULL DEFAULT 0,
  stars_earned INT NOT NULL DEFAULT 0,
  completed_at TIMESTAMP NULL,
  UNIQUE KEY uq_child_level (child_id, game_code, level_number),
  CONSTRAINT fk_lvl_child FOREIGN KEY (child_id)
    REFERENCES children(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

+ Seed: 3 مراحل لكل لعبة (سهل/متوسط/صعب) مع `config` مناسب لكل لعبة (مثلاً للعبة الجمع: نطاق الأرقام 1–5 / 1–10 / 1–20؛ لجداول الضرب: الجداول المطلوبة).

**إعادة تعريف "اكتملت اللعبة":** اللعبة مكتملة = كل مراحلها مكتملة. جدول `game_progress` الحالي يبقى كملخص، ويُحدَّث تلقائياً من منطق levels على السيرفر (توافقية للخلف مع الكود الحالي).

### 3.ب — API جديد `api/levels/index.php`

| Method | Endpoint | الوظيفة |
|---|---|---|
| GET | `/levels/?game_code=X&child_id=N` | مراحل اللعبة + حالة كل مرحلة (مكتملة/مفتوحة/مقفلة). المرحلة n مفتوحة إذا n=1 أو اكتملت n−1. |
| POST | `/levels/complete` | body: `{child_id, game_code, level_number, stars}` — يتحقق أن المرحلة مفتوحة والعمر مفتوح، يسجل في `level_progress`، يزيد النجوم **بالفرق فقط** (نفس منطق progress الحالي)، وإذا اكتملت كل المراحل يعلّم `game_progress.completed=1`. يعيد `total_stars` والحالة الجديدة. |

+ تحديث لوحة `admin/` بصفحة CRUD للمراحل (نفس نمط صفحات games/videos الحالية عبر `inc.php`).

### 3.ج — تعديلات فلاتر

1. **موديل + مستودع:** `core/data/models/game_level.dart`، `core/data/repositories/level_repository.dart` (نفس نمط `progress_repository.dart`).
2. **شاشة اختيار المراحل:** `features/games/widgets/level_select_screen.dart` — شاشة عامة (خريطة مراحل بأرقام ونجوم وقفل) تُفتح من بطاقة أي لعبة، تجلب المراحل من `/levels/` وتمرر `config` للعبة عند الدخول.
3. **تمرير المرحلة للألعاب:** كل شاشة لعبة تستقبل `GameLevel level` وتولّد أسئلتها من `level.config` بدل القوائم الثابتة (تعديل تدريجي: نبدأ بألعاب الرياضيات لأن التوليد فيها برمجي سهل، ثم اللغة/المنطق حيث الأسئلة من config كقوائم).
4. **ProgressManager:** دالة جديدة `markLevelCompleted(gameId, level, stars)` تستدعي `/levels/complete` (مع fallback محلي offline بمفاتيح `level_done_<game>_<n>`) — وتبقى `markGameCompleted` تعمل حتى انتهاء ترحيل كل الشاشات.
5. **النجوم:** تتحول من 50/لعبة إلى `stars_reward`/مرحلة (مثلاً 20×3 مراحل) — السيرفر هو الحكم في المجموع.

---

## المرحلة 4 — النشر والاختبار

1. **الاستيراد (⚠️ gotcha معروف):** استيراد أي SQL يجب أن يكون بـ:
   ```powershell
   & "C:\xampp\mysql\bin\mysql.exe" -u root --default-character-set=utf8mb4 edufun_db < db\edufun_levels.sql
   ```
   بدون `--default-character-set=utf8mb4` يتخرب النص العربي. ولا تمرر نصاً عربياً inline في Git Bash.
2. **الباك إند في مكانين:** التعديل في `edufun/backend/` (المصدر)، ثم نسخ إلى `C:\xampp\htdocs\edufun\` (النشر). يجب إبقاؤهما متطابقين.
3. **اختبارات القبول:**
   - طفل جديد → نقاط 0، عمر 7/8/9 مقفل، لا يرث تقدم طفل سابق على نفس الجهاز.
   - إكمال مراحل لعبة → اللعبة تُعلَّم مكتملة؛ إكمال ألعاب العمر الثلاث → العمر التالي يُفتح (والسيرفر يرفض اللعب بعمر مقفل).
   - النجوم لا تتضاعف عند إعادة لعب مرحلة مكتملة.
   - الوضع offline: اللعب يستمر محلياً ويتزامن عند عودة الاتصال.
   - الموسيقى تعمل وتُطفأ من الإعدادات، وصوت الفوز يصدر في كل الألعاب.
   - البطاقات الجديدة (مضاعفات 2–10، جداول 2–9، القسمة، الإعراب) تعرض عربياً سليماً على جهاز حقيقي.

## ترتيب التنفيذ المقترح

| # | المرحلة | الاعتمادية |
|---|---|---|
| 1 | الصوت (مرحلة 0) | مستقلة — سريعة |
| 2 | البطاقات (مرحلة 1) | مستقلة — بدون باك إند |
| 3 | قاعدة البيانات + API المراحل (3.أ + 3.ب) | أساس لما بعدها |
| 4 | فلاتر: المراحل + شاشة الاختيار (3.ج) | تعتمد على 3 |
| 5 | النقاط وفتح الأعمار من السيرفر (مرحلة 2) | تعتمد على 3–4 |
| 6 | النشر والاختبار الشامل (مرحلة 4) | الأخيرة |
