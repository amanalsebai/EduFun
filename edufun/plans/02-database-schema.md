# 02 — تصميم قاعدة بيانات MySQL

نموذج البيانات مشتقّ مباشرةً من الكيانات الموجودة في التطبيق:

- الأطفال (العمر، النجوم) ← من `child_age` و `global_stars`.
- الألعاب مرتبة حسب العمر ← من `ProgressManager.gamesByAge`.
- تقدّم الطفل في كل لعبة ← من `game_done_<gameId>`.
- درجات التقييم ← من `score_math` / `score_language` / `score_logic`.

## 1. مخطّط العلاقات (ERD مبسّط)

```
children ───< game_progress >─── games
   │                                │
   │                                └──< subjects (math|language|logic)
   ├───< child_scores >─── subjects
   └───< assessments
```

- `children` 1—N `game_progress` (لكل طفل عدة سجلات تقدّم).
- `games` N—1 `subjects` (كل لعبة تتبع مجالاً واحداً).
- `children` 1—N `child_scores` (درجة لكل مجال).
- `children` 1—N `assessments` (سجلّ تقييم لكل محاولة).

## 2. الجداول

### `children` — الأطفال

| الحقل | النوع | ملاحظات |
|------|------|---------|
| id | INT PK AI | المعرّف |
| name | VARCHAR(100) | اسم الطفل |
| age | TINYINT | 6..9 |
| total_stars | INT default 0 | يقابل `global_stars` |
| created_at | TIMESTAMP | |
| updated_at | TIMESTAMP | |

### `subjects` — المجالات

| الحقل | النوع | ملاحظات |
|------|------|---------|
| id | INT PK AI | |
| code | VARCHAR(20) UNIQUE | `math` / `language` / `logic` |
| name_ar | VARCHAR(50) | الاسم بالعربية |

### `games` — كتالوج الألعاب

| الحقل | النوع | ملاحظات |
|------|------|---------|
| id | INT PK AI | |
| game_code | VARCHAR(40) UNIQUE | `word_game`, `color_matching`… |
| title_ar | VARCHAR(100) | عنوان اللعبة |
| subject_id | INT FK | يتبع subjects |
| min_age | TINYINT | العمر المستهدف 6..9 |

### `game_progress` — تقدّم الطفل في كل لعبة

| الحقل | النوع | ملاحظات |
|------|------|---------|
| id | INT PK AI | |
| child_id | INT FK | |
| game_code | VARCHAR(40) | |
| completed | TINYINT(1) default 0 | يقابل `game_done_<id>` |
| stars_earned | INT default 0 | |
| completed_at | TIMESTAMP NULL | |
| | | UNIQUE(child_id, game_code) |

### `child_scores` — درجات المجالات

| الحقل | النوع | ملاحظات |
|------|------|---------|
| id | INT PK AI | |
| child_id | INT FK | |
| subject_id | INT FK | |
| score | INT default 0 | |
| | | UNIQUE(child_id, subject_id) |

### `assessments` — التقييم المبدئي

| الحقل | النوع | ملاحظات |
|------|------|---------|
| id | INT PK AI | |
| child_id | INT FK | |
| math_score | INT | |
| language_score | INT | |
| logic_score | INT | |
| taken_at | TIMESTAMP | |

---

## 3. سكربت الإنشاء الكامل `edufun_schema.sql`

> ضعه في `xampp/htdocs/edufun/db/edufun_schema.sql` ثم استورده عبر phpMyAdmin
> أو نفّذه من سطر الأوامر. الشرح في الملف 07.

```sql
-- إنشاء القاعدة بترميز يدعم العربية
CREATE DATABASE IF NOT EXISTS edufun_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE edufun_db;

-- 1) الأطفال
CREATE TABLE IF NOT EXISTS children (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  age         TINYINT NOT NULL,
  total_stars INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) المجالات
CREATE TABLE IF NOT EXISTS subjects (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  code    VARCHAR(20) NOT NULL UNIQUE,
  name_ar VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3) الألعاب
CREATE TABLE IF NOT EXISTS games (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  game_code  VARCHAR(40) NOT NULL UNIQUE,
  title_ar   VARCHAR(100) NOT NULL,
  subject_id INT NOT NULL,
  min_age    TINYINT NOT NULL,
  CONSTRAINT fk_games_subject FOREIGN KEY (subject_id)
    REFERENCES subjects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) تقدّم الألعاب
CREATE TABLE IF NOT EXISTS game_progress (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  child_id     INT NOT NULL,
  game_code    VARCHAR(40) NOT NULL,
  completed    TINYINT(1) NOT NULL DEFAULT 0,
  stars_earned INT NOT NULL DEFAULT 0,
  completed_at TIMESTAMP NULL,
  UNIQUE KEY uq_child_game (child_id, game_code),
  CONSTRAINT fk_progress_child FOREIGN KEY (child_id)
    REFERENCES children(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5) درجات المجالات
CREATE TABLE IF NOT EXISTS child_scores (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  child_id   INT NOT NULL,
  subject_id INT NOT NULL,
  score      INT NOT NULL DEFAULT 0,
  UNIQUE KEY uq_child_subject (child_id, subject_id),
  CONSTRAINT fk_scores_child FOREIGN KEY (child_id)
    REFERENCES children(id) ON DELETE CASCADE,
  CONSTRAINT fk_scores_subject FOREIGN KEY (subject_id)
    REFERENCES subjects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6) التقييمات
CREATE TABLE IF NOT EXISTS assessments (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  child_id       INT NOT NULL,
  math_score     INT NOT NULL DEFAULT 0,
  language_score INT NOT NULL DEFAULT 0,
  logic_score    INT NOT NULL DEFAULT 0,
  taken_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_assess_child FOREIGN KEY (child_id)
    REFERENCES children(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 4. بيانات أوّلية (Seed) — تطابق التطبيق الحالي

```sql
USE edufun_db;

-- المجالات الثلاثة
INSERT INTO subjects (code, name_ar) VALUES
  ('math', 'الرياضيات'),
  ('language', 'اللغة'),
  ('logic', 'المنطق')
ON DUPLICATE KEY UPDATE name_ar = VALUES(name_ar);

-- الألعاب مطابقة لـ ProgressManager.gamesByAge في التطبيق
-- العمر 6
INSERT INTO games (game_code, title_ar, subject_id, min_age) VALUES
  ('word_game',      'ترتيب الكلمات',  (SELECT id FROM subjects WHERE code='language'), 6),
  ('color_matching', 'مطابقة الألوان', (SELECT id FROM subjects WHERE code='logic'),    6),
  ('addition_game',  'لعبة الجمع',     (SELECT id FROM subjects WHERE code='math'),     6),
-- العمر 7
  ('sentence_game',  'تكوين الجُمل',   (SELECT id FROM subjects WHERE code='language'), 7),
  ('ar_en_matching', 'مطابقة عربي-إنجليزي', (SELECT id FROM subjects WHERE code='logic'), 7),
  ('advanced_math',  'رياضيات متقدمة', (SELECT id FROM subjects WHERE code='math'),     7),
-- العمر 8
  ('english_spelling','تهجئة إنجليزية', (SELECT id FROM subjects WHERE code='language'), 8),
  ('math_adventure', 'مغامرة الرياضيات',(SELECT id FROM subjects WHERE code='math'),    8),
  ('grammar_matching','توصيل الإعراب',  (SELECT id FROM subjects WHERE code='language'), 8),
-- العمر 9
  ('crossmath',      'الرياضيات المتقاطعة',(SELECT id FROM subjects WHERE code='math'), 9),
  ('error_hunter',   'صائد الأخطاء',   (SELECT id FROM subjects WHERE code='language'), 9),
  ('question_builder','بناء الأسئلة',  (SELECT id FROM subjects WHERE code='logic'),    9)
ON DUPLICATE KEY UPDATE title_ar = VALUES(title_ar);

-- طفل تجريبي
INSERT INTO children (name, age, total_stars) VALUES ('طفل تجريبي', 6, 0);
```

> ملاحظة الترميز: استخدم دائماً `utf8mb4` لأن الأسماء والعناوين عربية. إذا ظهرت
> حروف «؟؟؟» فالسبب غالباً ترميز الاتصال — يُحلّ في `database.php` (الملف 03)
> عبر `SET NAMES utf8mb4`.
