# 04 — توثيق الـ API

## معلومات عامة

- **Base URL:** `http://<IP>:<PORT>/edufun/api`
  - من نفس اللابتوب: `http://localhost:80/edufun/api`
  - من محاكي أندرويد: `http://10.0.2.2:80/edufun/api`
  - من هاتف حقيقي: `http://192.168.x.x:80/edufun/api` (IP اللابتوب على الواي‑فاي)
- **الترميز:** UTF-8، نوع المحتوى `application/json`.
- **المصادقة:** لا يوجد في النسخة الأولى (تطوير محلي).

### شكل الاستجابة الموحّد

كل استجابة تتبع نفس الغلاف:

```json
{
  "success": true,
  "message": "",
  "data": { }
}
```

- `success` (bool): نجاح/فشل العملية.
- `message` (string): رسالة للمستخدم/المطوّر (عربية).
- `data` (object|array|null): الحمولة الفعلية.

### رموز الحالة (HTTP Status)

| الرمز | المعنى |
|------|--------|
| 200 | نجاح (قراءة/تحديث/حذف) |
| 201 | تم الإنشاء |
| 400 | مدخلات ناقصة/غير صالحة |
| 404 | المورد غير موجود |
| 500 | خطأ في السيرفر أو قاعدة البيانات |

---

## 0) فحص الاتصال — Ping

يستخدمه زر الاتصال العائم في فلاتر للتأكّد أن الـ IP/البورت صحيحان.

```
GET /ping.php
```

**استجابة 200:**
```json
{
  "success": true,
  "message": "الاتصال ناجح ✅",
  "data": { "server": "edufun", "time": "2026-06-20T12:00:00+00:00" }
}
```

---

## 1) الأطفال — Children (CRUD)

### قراءة كل الأطفال
```
GET /children/
```
```json
{ "success": true, "message": "", "data": [
  { "id": 1, "name": "طفل تجريبي", "age": 6, "total_stars": 12,
    "created_at": "2026-06-20 12:00:00", "updated_at": "2026-06-20 12:00:00" }
]}
```

### قراءة طفل واحد
```
GET /children/?id=1
```

### إنشاء طفل
```
POST /children/
Content-Type: application/json
```
**الجسم:**
```json
{ "name": "سارة", "age": 7, "total_stars": 0 }
```
**استجابة 201:**
```json
{ "success": true, "message": "تم إنشاء الطفل",
  "data": { "id": 2, "name": "سارة", "age": 7, "total_stars": 0 } }
```

### تعديل طفل
```
PUT /children/?id=2
```
```json
{ "age": 8, "total_stars": 25 }
```
> الحقول اختيارية؛ المرسَل فقط يُحدَّث (الباقي يبقى كما هو).

### حذف طفل
```
DELETE /children/?id=2
```
**استجابة 200:** `{ "success": true, "message": "تم الحذف", "data": null }`

---

## 2) التقدّم — Progress

### قراءة تقدّم طفل
```
GET /progress/?child_id=1
```
```json
{ "success": true, "data": [
  { "id": 5, "child_id": 1, "game_code": "word_game",
    "completed": 1, "stars_earned": 3, "completed_at": "2026-06-20 12:10:00" }
]}
```

### تسجيل فوز بلعبة (يزيد النجوم تلقائياً)
```
POST /progress/
```
```json
{ "child_id": 1, "game_code": "word_game", "stars": 3 }
```
**استجابة 201:**
```json
{ "success": true, "message": "تم الإنشاء",
  "data": { "child_id": 1, "game_code": "word_game" } }
```

> يقابل `ProgressManager.markGameCompleted()` + `ScoreManager.addStars()` معاً.
> أكواد الألعاب (`game_code`) هي نفسها في التطبيق:
> `word_game, color_matching, addition_game, sentence_game, ar_en_matching,`
> `advanced_math, english_spelling, math_adventure, grammar_matching,`
> `crossmath, error_hunter, question_builder`.

---

## 3) الدرجات — Scores

### قراءة درجات طفل
```
GET /scores/?child_id=1
```
```json
{ "success": true, "data": {
  "math": 4, "language": 2, "logic": 5
}}
```

### تحديث الدرجات
```
PUT /scores/?child_id=1
```
```json
{ "math": 4, "language": 2, "logic": 5 }
```
> يقابل المفاتيح `score_math` / `score_language` / `score_logic` الحالية في
> `ParentPortalScreen`.

---

## 4) التقييم — Assessment

### حفظ نتيجة تقييم
```
POST /assessment/
```
```json
{ "child_id": 1, "math_score": 4, "language_score": 2, "logic_score": 5 }
```

### قراءة آخر تقييم
```
GET /assessment/?child_id=1
```
```json
{ "success": true, "data": {
  "id": 9, "child_id": 1, "math_score": 4, "language_score": 2,
  "logic_score": 5, "taken_at": "2026-06-20 12:30:00"
}}
```

---

## 5) كتالوج الألعاب — Games

### قراءة كل الألعاب
```
GET /games/
GET /games/?min_age=8        # تصفية حسب العمر
```
```json
{ "success": true, "data": [
  { "id": 1, "game_code": "word_game", "title_ar": "ترتيب الكلمات",
    "subject_id": 2, "min_age": 6 }
]}
```

> العمليات POST/PUT/DELETE متاحة لإدارة الكتالوج (نفس قالب children) وليست
> ضرورية للتطبيق نفسه.

---

## جدول مرجعي سريع

| العملية | الطريقة | المسار | الجسم/المعامل |
|---------|---------|--------|----------------|
| فحص اتصال | GET | `/ping.php` | — |
| كل الأطفال | GET | `/children/` | — |
| طفل واحد | GET | `/children/?id=` | — |
| إنشاء طفل | POST | `/children/` | name, age |
| تعديل طفل | PUT | `/children/?id=` | الحقول |
| حذف طفل | DELETE | `/children/?id=` | — |
| تقدّم طفل | GET | `/progress/?child_id=` | — |
| تسجيل لعبة | POST | `/progress/` | child_id, game_code, stars |
| درجات طفل | GET | `/scores/?child_id=` | — |
| تحديث درجات | PUT | `/scores/?child_id=` | math, language, logic |
| حفظ تقييم | POST | `/assessment/` | child_id + 3 درجات |
| آخر تقييم | GET | `/assessment/?child_id=` | — |
| الألعاب | GET | `/games/` | min_age? |

---

## اختبار سريع بـ curl

```bash
# فحص الاتصال
curl http://localhost/edufun/api/ping.php

# إنشاء طفل
curl -X POST http://localhost/edufun/api/children/ \
  -H "Content-Type: application/json" \
  -d '{"name":"سارة","age":7}'

# تسجيل فوز بلعبة
curl -X POST http://localhost/edufun/api/progress/ \
  -H "Content-Type: application/json" \
  -d '{"child_id":1,"game_code":"word_game","stars":3}'
```
