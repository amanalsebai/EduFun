-- =====================================================================
--  EduFun — مخطّط قاعدة البيانات (MySQL / MariaDB على XAMPP)
--  الاستيراد:  phpMyAdmin ← Import  أو  mysql -u root < edufun_schema.sql
-- =====================================================================

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

-- 3) الألعاب (الكتالوج)
CREATE TABLE IF NOT EXISTS games (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  game_code  VARCHAR(40) NOT NULL UNIQUE,
  title_ar   VARCHAR(100) NOT NULL,
  subject_id INT NOT NULL,
  min_age    TINYINT NOT NULL,
  CONSTRAINT fk_games_subject FOREIGN KEY (subject_id)
    REFERENCES subjects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) تقدّم الطفل في كل لعبة
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

-- 5) درجات المجالات لكل طفل
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

-- 6) التقييمات المبدئية
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

-- =====================================================================
--  بيانات أوّلية (Seed)
-- =====================================================================

-- المجالات الثلاثة
INSERT INTO subjects (code, name_ar) VALUES
  ('math', 'الرياضيات'),
  ('language', 'اللغة'),
  ('logic', 'المنطق')
ON DUPLICATE KEY UPDATE name_ar = VALUES(name_ar);

-- الألعاب (مطابقة لـ ProgressManager.gamesByAge في فلاتر)
INSERT INTO games (game_code, title_ar, subject_id, min_age) VALUES
  ('word_game',       'ترتيب الكلمات',         (SELECT id FROM subjects WHERE code='language'), 6),
  ('color_matching',  'مطابقة الألوان',        (SELECT id FROM subjects WHERE code='logic'),    6),
  ('addition_game',   'لعبة الجمع',            (SELECT id FROM subjects WHERE code='math'),     6),
  ('sentence_game',   'تكوين الجُمل',          (SELECT id FROM subjects WHERE code='language'), 7),
  ('ar_en_matching',  'مطابقة عربي-إنجليزي',   (SELECT id FROM subjects WHERE code='logic'),    7),
  ('advanced_math',   'رياضيات متقدمة',        (SELECT id FROM subjects WHERE code='math'),     7),
  ('english_spelling','تهجئة إنجليزية',        (SELECT id FROM subjects WHERE code='language'), 8),
  ('math_adventure',  'مغامرة الرياضيات',      (SELECT id FROM subjects WHERE code='math'),     8),
  ('grammar_matching','توصيل الإعراب',         (SELECT id FROM subjects WHERE code='language'), 8),
  ('crossmath',       'الرياضيات المتقاطعة',   (SELECT id FROM subjects WHERE code='math'),     9),
  ('error_hunter',    'صائد الأخطاء',          (SELECT id FROM subjects WHERE code='language'), 9),
  ('question_builder','بناء الأسئلة',          (SELECT id FROM subjects WHERE code='logic'),    9)
ON DUPLICATE KEY UPDATE title_ar = VALUES(title_ar);

-- طفل تجريبي افتراضي (id = 1) ليُستخدم عند أول تشغيل للتطبيق
INSERT INTO children (name, age, total_stars) VALUES ('بطلنا الصغير', 6, 0);

-- =====================================================================
--  جداول المحتوى القابل للإدارة (تُدار من لوحة admin/)
--  البِنية هنا، والبيانات الأوّلية (seed) في:  db/edufun_content.sql
-- =====================================================================

-- 7) مكتبة الفيديوهات (الدروس)
CREATE TABLE IF NOT EXISTS videos (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  subject_code VARCHAR(20)  NOT NULL,                 -- math / language / logic
  title        VARCHAR(200) NOT NULL,
  channel      VARCHAR(120) NOT NULL DEFAULT '',
  url          VARCHAR(300) NOT NULL,
  thumbnail    VARCHAR(300) NOT NULL DEFAULT '',
  min_age      TINYINT      NOT NULL DEFAULT 6,
  sort_order   INT          NOT NULL DEFAULT 0,
  created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_video_url (url)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8) أسئلة التقييم المبدئي
CREATE TABLE IF NOT EXISTS assessment_questions (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  age           TINYINT      NOT NULL,
  category      VARCHAR(20)  NOT NULL,                -- math / language / logic
  question      VARCHAR(300) NOT NULL,
  option_a      VARCHAR(120) NOT NULL,
  option_b      VARCHAR(120) NOT NULL,
  option_c      VARCHAR(120) NOT NULL DEFAULT '',
  option_d      VARCHAR(120) NOT NULL DEFAULT '',
  correct_index TINYINT      NOT NULL DEFAULT 0,       -- 0..3
  sort_order    INT          NOT NULL DEFAULT 0,
  created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_q_slot (age, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
